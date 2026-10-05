-- Presentation only: commands are still chosen by each engine's original input
-- and battle controller. Draw at window resolution, after palette/attack passes.
return function(mod,Theme,enabled)
 local gen=require('src.core.GameVersion').generation()
 local active,screen,menu=true,nil,nil
 local restore={}
 local function stageOwns()
  local p=mod.find and mod.find('BATTLE_ART_VOXEL_FORK')
  local api=p and p.exports and p.exports.battlePresentation
  if api and type(api.nativeHudOwned)=='function' then
   local ok,value=pcall(api.nativeHudOwned);return ok and value==true
  end
  return false
 end
 local function allowed()return active and enabled() and not stageOwns()end
 local function wrap(owner,key,fn)
  local original=owner[key];if type(original)~='function'then return end
  local replacement=function(...)if not active then return original(...)end;return fn(original,...)end
  owner[key]=replacement
  restore[#restore+1]=function()if owner[key]==replacement then owner[key]=original end end
 end
 local function entries(labels)
  local out={};for i,label in ipairs(labels)do out[i]={name=label,kind=({'fight','pokemon','bag','run'})[i]}end
  return out
 end
 local ui,battle
 if gen<3 then
  local State=require(gen==2 and 'src.ui.gen2.BattleState' or 'src.battle.BattleState')
  local function capture(self)
   menu=nil;screen=self
   local partner=type(self.usesModernDoublesHud)=='function' and self:usesModernDoublesHud()
   if not allowed() or partner or self.doubles or self.battle and self.battle.doubles
    or self.safari or self.contest or self.demo or self.tutorial or not self:bottomUIVisible()
    or self.moveSwapIndex or (self.phase~='menu' and self.phase~=(gen==2 and 'moves' or 'moveSelect')) then return false end
   local Strings=require('src.core.Strings')
   if self.phase=='menu' then
    menu={mode='menu',index=self.menuIndex,entries=entries(gen==2 and self:menuLabels() or
     {Strings('FIGHT','battle'),'PKMN',Strings('ITEM','battle'),Strings('RUN','battle')})}
   else
    local moves=gen==2 and self:playerMoves() or self.player.curMoves
    local data=self.game and self.game.data or self.data
    local grid=gen==1 and self.moveGridNavigation and self:moveGridNavigation()
    menu={mode='moves',index=self.moveIndex,grid=grid,entries={}}
    for i=1,4 do
     local move=moves[i];local def=move and data.moves[move.id]
     local disabled=gen==1 and self.player.disabledSlot==i or gen==2 and move and self.battle:moveDisabled(self.battle.player,move.id)
     menu.entries[i]={name=move and (def and def.name or tostring(move.id))or '-',
      detail=move and (tostring(move.pp or 0)..'/'..tostring(move.maxPp or move.maxPP or def and (def.pp+(move.ppUps or 0)*math.floor(def.pp/5)) or move.pp or 0)..' PP')or ''}
     if i==self.moveIndex and def then
      menu.info=(disabled and 'DISABLED  'or '')..tostring(def.type or '')
     end
    end
   end
   return true
  end
  wrap(State,gen==2 and 'drawBottom' or 'drawTextArea',function(original,self,...)
   if not capture(self)then return original(self,...)end
  end)
  if gen==1 then
   -- WideBattle has its own local text painter. Its public visibility seam
   -- suppresses only that draw for this call; restore the instance even on error.
   local Wide=require('src.battle.WideBattle')
   wrap(Wide,'draw',function(original,self,...)
    if not capture(self)then return original(self,...)end
    local previous=rawget(self,'bottomUIVisible')
    self.bottomUIVisible=function()return false end
    local result={pcall(original,self,...)}
    self.bottomUIVisible=previous
    if not result[1]then error(result[2],0)end
    return unpack(result,2)
   end)
  end
 else
  ui=require('src.core.game3.battle.ui');battle=require('src.core.game3.battle')
  local Chrome=require('src.ui.game3.battle_chrome')
  wrap(ui,'handleInput',function(original,keys)
   if allowed() and menu and ui._mode=='menu' and keys and keys.wasPressed then
    local swap={up='left',down='right',left='up',right='down'}
    local proxy=setmetatable({},{__index=keys})
    proxy.wasPressed=function(_,key)return keys:wasPressed(swap[key]or key)end
    return original(proxy)
   end
   return original(keys)
  end)
  local ready,capturing
  -- The engine sandbox deliberately exposes an empty package.loaded table.
  -- Resolve supported native UI modules through require and cache the handles.
  local nativeScreens={}
  local function nativeScreen(name)
   if nativeScreens[name]==nil then
    local ok,screen=pcall(require,'src.ui.game3.'..name)
    if ok then nativeScreens[name]=screen end
   end
   return nativeScreens[name]
  end
  local function eligible()
   local st=battle._st
   if not allowed() or not st or st.safari or battle._phase~='command' or (ui._mode~='menu' and ui._mode~='moves' and ui._mode~='target') or ui._swap then return false end
   if ui.voiceoverDim and ui.voiceoverDim()>0 then return false end
   local msg=nativeScreen('message');if msg and msg.open then return false end
   for _,name in ipairs({'bag_menu','party_menu','summary_menu','help_system'})do
    local owner=nativeScreen(name)
    if owner and owner.isOpen and owner.isOpen()then return false end
   end
   return true
  end
  wrap(Chrome,'drawPanel',function(original,mode,...)
   if capturing and (mode=='menu' or mode=='moves') then
    ready=true
   end
   return original(mode,...)
  end)
  wrap(ui,'draw',function(original,...)
   menu=nil;ready=false;capturing=eligible()
   local result={pcall(original,...)};capturing=false
   if not result[1]then error(result[2],0)end
   if ready and eligible()then
    local G=love.graphics;G.push('all');G.origin();G.setShader();G.setScissor();G.setDepthMode()
    G.setBlendMode('replace','premultiplied');G.setColor(.91,.93,.95,1);G.rectangle('fill',0,112,240,48)
    G.pop()
    local Strings=require('src.core.Strings')
    if ui._mode=='menu' then
     local list=entries({Strings('FIGHT'),Strings('ITEMS'),Strings('PKMN'),Strings('RUN')})
     list[2].kind='bag';list[3].kind='pokemon'
     menu={mode='menu',index=ui._menuIndex,entries=list}
    else
     local st=battle._st;local id=ui.activeBattler();local b=st.battlers and st.battlers[id] or st.player
     local mon=b and b.mon;local Moves=require('src.core.game3.battle.moves')
     local Types=require('src.core.game3.battle.types')
     menu={mode='moves',index=ui._moveIndex,grid=true,entries={}}
     for i=1,4 do
      local move=mon and mon.moves and mon.moves[i];local def=move and Moves.get(move)
      menu.entries[i]={name=def and Moves.displayName(move)or '-',
       detail=def and (Types.name(def.type)..'  '..tostring(mon.pp and mon.pp[i]or 0)..'/'..tostring(mon.maxPp and mon.maxPp[i]or def.pp or 0)..' PP')or ''}
     end
     if ui._mode=='target' then
      local target=ui.targetCursor();local foe=st.battlers and st.battlers[target]
      menu.target=foe and ((target%2==1 and 'FOE 'or 'ALLY ')..require('src.core.game3.battle.state').displayName(foe))
     end
    end
   end
   return unpack(result,2)
  end)
 end
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport)
  if not menu or not allowed()then return result end
  if gen<3 then
   if not game.stack or game.stack:top()~=screen or (screen.phase~='menu' and screen.phase~=(gen==2 and 'moves' or 'moveSelect'))then return result end
  elseif battle._phase~='command' or (ui._mode~='menu' and ui._mode~='moves' and ui._mode~='target')then return result end
  local G=love.graphics;G.push('all');G.origin();G.setShader();G.setScissor();G.setDepthMode()
  local ok,err=pcall(function()
   local w,h=G.getDimensions();local k=Theme.scale(w,h);G.scale(k);w,h=w/k,h/k
   local x,y=w-168,h-62
   if menu.mode=='menu' then
    Theme.commandHub(x+82,y+29)
    for i,entry in ipairs(menu.entries)do
     local pos=gen==3 and ({1,3,2,4})[i]or i
     local bx,by=x+3+(pos-1)%2*82,y+3+math.floor((pos-1)/2)*30
     Theme.button(bx,by,76,22,entry.kind,menu.index==i,pos%2==0)
     Theme.text(entry.name,bx+5,by+5,66,{1,1,.96,1},true)
    end
   else
    Theme.panel(x+2,y+2,160,58)
    if menu.info then Theme.panel(x+2,y-11,160,12);Theme.text(menu.info,x+6,y-9,152)end
    if menu.target then Theme.panel(x+2,y-11,160,12);Theme.text('TARGET: '..menu.target,x+6,y-9,152)end
    for i,entry in ipairs(menu.entries)do
     local grid=menu.grid;local bx=x+6+(grid and (i-1)%2*78 or 0)
     local by=y+5+(grid and math.floor((i-1)/2)*26 or (i-1)*12)
     local selected=menu.index==i
     if selected then G.setColor(.14,.39,.34,1);G.rectangle('fill',bx-1,by-1,grid and 73 or 150,grid and 23 or 11)end
     local ink=selected and {1,1,1,1}or Theme.ink
     Theme.text(entry.name,bx,by,grid and 71 or 101,ink)
     Theme.text(entry.detail,grid and bx or bx+105,grid and by+11 or by,grid and 71 or 43,ink)
    end
   end
  end)
  G.pop();if not ok then error(err,0)end
  return result
 end)
 return function()active=false;menu=nil;screen=nil;for i=#restore,1,-1 do restore[i]()end end
end
