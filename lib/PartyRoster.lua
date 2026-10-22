-- Compact two-column inventory. Special native workflows retain their own
-- presentation; only roster navigation is remapped to the visible card grid.
return function(mod,T,enabled)
 if require('src.core.GameVersion').generation()~=3 then return function()end end
 local S=require('src.ui.game3.party_menu');local P=require('src.core.game3.pokemon')
 local R=require('src.core.game3.rom_text');local active=true
 local modes={list=true,switch=true,action=true,item_action=true}
 local function owns()
  local g=love.graphics;local sw,sh=g.getDimensions();local _,_,w,h=T.viewport(sw,sh)
  if w<132 or h<92 then return false end
  return active and enabled()and S.open and modes[S.mode]and not S._battle
   and not S._pokedude and not S._hpAnim and not S._multi and not S._chooseOrder
   and not require('src.ui.game3.summary_menu').isOpen()
 end
 local function text(value,x,y,w,color)return T.text(value,x,y,w,color)end
 local function pos(i)return 2+((i-1)%2)*119,3+math.floor((i-1)/2)*42 end
 local function drawRoster()
  local g=love.graphics;T.partyBackground(0,0,240,160)
  for i=1,6 do
   local m=S._party and S._party[i];local x,y=pos(i)
   T.partyCard(x,y,116,39,S.cursor==i,not m)
   if m then
    local icon=P.monIcon(m);g.setColor(1,1,1,1)
    if icon then
     local slot=S._oam and S._oam[i];local sprite=slot and slot.mon and require('src.core.game3.oam').get(slot.mon)
     local frame=sprite and sprite.data and sprite.data[2]
      or((tonumber(m.hp)or 0)>0 and math.floor(love.timer.getTime()*4)%2 or 0)
     g.draw(icon.image,icon.quads[frame]or icon.quads[0],x+5,y+3,0,.75,.75)
    end
    text(P.displayName(m),x+30,y+5,76)
    if not P.isEgg(m)then
     local gender=m.gender or P.gender(m.species,m.personality)
     g.push();g.translate(x+107,y+6);g.scale(.65);T.gender(gender,0,0,gender=='F'and{1,.40,.58,1}or{.22,.83,1,1});g.pop()
     local hp=tonumber(m.hp)or 0;local maximum=math.max(1,tonumber(m.maxHp or m.maxhp)or 1)
     local f=math.max(0,math.min(1,hp/maximum))
     text('HP',x+31,y+17,12,{.39,1,.69,1})
     g.setColor(.015,.06,.07,1);g.rectangle('fill',x+45,y+17,63,4)
     g.setColor(T.hpColor(f));g.rectangle('fill',x+46,y+18,math.floor(61*f),2)
     local status=require('src.core.game3.summary_data').statusAilment(m)
     local level=require('src.ui.LevelDisplay').visible(m,'party',S._session and S._session.game)
     if level and(status==0 or status==6)then text('Lv.'..tostring(m.level or 1),x+6,y+30,31)end
     text(hp..' / '..maximum,x+48,y+29,61)
     if hp<=0 then text('FNT',x+6,y+30,24,{1,.64,.51,1})
     elseif status and status>0 then
      local label=({[1]='PSN',[2]='PAR',[3]='SLP',[4]='FRZ',[5]='BRN',[6]='PKRS'})[status]
      if label then text(label,x+6,y+30,24,{1,.77,.42,1})end
     end
     if (tonumber(m.item or m.heldItem)or 0)>0 then
      g.setColor(1,.81,.39,1);g.rectangle('fill',x+26,y+23,4,4)
     end
    end
    if S.switchFrom==i then text('MOVE',x+31,y+5,30,{1,.85,.42,1})end
   end
  end
  local prompt=S._rsPrompt and S._rsPrompt.text
   or R.plain(S.mode=='switch'and'gText_MoveToWhere'or'gText_ChoosePokemon')
  T.panel(2,132,174,26,false);text(prompt,7,141,164)
  T.partyCard(180,132,58,26,S.cursor==7,false);text('CANCEL',187,141,45)
  if S.mode=='action'or S.mode=='item_action'then
   local actions=S.mode=='action'and S.ACTIONS or S.ITEM_ACTIONS
   local index=S.mode=='action'and S.actionCursor or S.itemActionCursor
   local labels=S._actionTextsFor(actions or{});local h=#labels*15+8;local y=158-h
   T.panel(126,y,112,h,false)
   for i,label in ipairs(labels)do
    local row=y+4+(i-1)*15
    if i==index then T.partyCard(129,row,106,14,true,false)end
    text(label,137,row+4,94)
   end
  end
 end
 local originalInput=S.handleInput
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport)
  if owns()then
   local g=love.graphics;local sw,sh=g.getDimensions();local x,y,w,h=T.viewport(sw,sh)
   local scale=math.min(4,(w-12)/240,(h-12)/160)
   if scale>=.5 then
    g.push('all');g.origin();g.setShader();g.setDepthMode();g.setScissor(x,y,w,h)
    local ok,err=pcall(function()
     T.partyBackground(x,y,w,h)
     g.translate(x+(w-240*scale)/2,y+(h-160*scale)/2);g.scale(scale)
     drawRoster()
    end);g.pop();if not ok then error(err,0)end
   end
  end
  return result
 end)
 local input=function(buttons,...)
  if not owns()or(S.mode~='list'and S.mode~='switch')then return originalInput(buttons,...)end
  local dir
  for _,key in ipairs({'up','down','left','right'})do if buttons:wasPressed(key)then dir=key;break end end
  if not dir then return originalInput(buttons,...)end
  local cur=S.cursor;local n=#(S._party or{});local target=cur
  if cur==7 then target=dir=='up'and n or 1
  elseif dir=='left'then if cur%2==0 then target=cur-1 end
  elseif dir=='right'then if cur%2==1 and cur<n then target=cur+1 end
  elseif dir=='up'then target=cur>2 and cur-2 or 7
  else target=cur+2<=n and cur+2 or 7 end
  S.cursor=target
  -- Proxy only direction presses; confirmation/cancel and all other input
  -- still flow through the original controller (including virtual buttons).
  local proxy=setmetatable({wasPressed=function(_,key)
   if key=='up'or key=='down'or key=='left'or key=='right'then return false end
   return buttons:wasPressed(key)
  end},{__index=buttons})
  return originalInput(proxy,...)
 end
 S.handleInput=input
 return function()active=false;if S.handleInput==input then S.handleInput=originalInput end end
end
