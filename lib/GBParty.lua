-- Presentation-only roster. Never replace the native party controller or callbacks.
return function(mod,Theme,enabled)
 local gen=require('src.core.GameVersion').generation()
 if gen>=3 then return function()end end
 local Party=require(gen==2 and 'src.ui.gen2.PartyMenu'or'src.ui.PartyMenu')
 local Strings=require('src.core.Strings');local active=true
 local function specialized(s)
  local items=type(s.submenu)=='table'and s.submenu.items or s.subItems
  return s.tmhm or s.evoStone or s.itemUse or s.heal or s.swapAnim or s.itemResult or s.softboiledFrom
   or(s.gridNavigation and s:gridNavigation())or(items and #items>10)
 end
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport)
  local s=game.stack and game.stack:top()
  if not active or not enabled()or getmetatable(s)~=Party or specialized(s)then return result end
  local G=love.graphics;local w,h=G.getDimensions()
  if w<256 or h<232 then return result end
  local party=s.party or game.save.party;if #party>6 then return result end;local scale=math.max(1,math.floor(math.min(w/256,h/232)))
  G.push('all');G.origin();G.setShader();G.setScissor();G.setDepthMode()
  local ok,err=pcall(function()
   G.setColor(.09,.15,.16,1);G.rectangle('fill',0,0,w,h)
   G.translate(math.floor((w-240*scale)/2),math.floor((h-220*scale)/2));G.scale(scale)
   Theme.text(Strings('POKéMON'),8,3,180,{1,1,1,1},true)
   for i,mon in ipairs(party)do
    local y=20+(i-1)*24;local selected=s.index==i
    Theme.partyCard(8,y,224,22,selected,false)
    G.setColor(1,1,1,1)
    if gen==2 then s:drawIcon(mon,13,y+3+s:iconBob(i))
    else Party.drawIcon(game,mon,13,y+3,selected,s.blink or 0)end
    G.setShader()
    local hp=gen==2 and s:shownHpFor(i,mon)or mon.hp
    local max=mon.maxHp or(mon.stats and mon.stats.hp)or 1
    local row=gen==2 and Party.rowFor(mon,hp,game.data.gen2Statuses)
    local def=game.data.pokemon[mon.species]or{}
    local name=row and row.name or mon.nickname or def.name or mon.species
    Theme.text(name,36,y+3,109,{1,1,1,1})
    if not mon.isEgg then
     local status
     if gen==2 then status=row.status else status=hp<=0 and'FNT'or mon.status and require('src.battle.Status').hudLabelFor(game.data.statuses,mon.status)end
     local levelVisible=gen~=1 or require('src.ui.LevelDisplay').visible(mon,'party',game)
     if levelVisible then Theme.text('Lv.'..tostring(mon.level or 1),150,y+3,38,{1,1,1,1})end
     if status then Theme.text(status,192,y+3,35,{1,1,1,1})end
     G.setColor(.04,.09,.09,1);G.rectangle('fill',36,y+14,112,3)
     local fraction=math.max(0,math.min(1,hp/math.max(1,max)))
     G.setColor(Theme.hpColor(fraction));G.rectangle('fill',36,y+14,math.floor(112*fraction),3)
     Theme.text(tostring(hp)..'/'..tostring(max),160,y+13,65,{1,1,1,1})
    end
    if s.switchFrom==i or s.swapFrom==i then Theme.text('>',2,y+7,6,{1,.84,.38,1})end
   end
   local prompt=gen==1 and s:bottomMessage()or s.prompt
   if gen==2 and s.switchFrom then prompt=Party.PROMPTS.moveTo end
   Theme.interfacePanel(8,194,224,26,false,'dialogue')
   local line=0;for t in tostring(Strings(prompt or'Choose a POKéMON.')):gmatch('[^\n]+')do
    Theme.text(t,13,199+line*10,214);line=line+1;if line==2 then break end
   end
   if gen==2 then
    Theme.partyCard(152,169,80,19,s:isCancel(),false);Theme.text(Strings('CANCEL'),158,174,68,{1,1,1,1},true)
   end
   local items=gen==2 and s.submenu and s.submenu.items or s.submenu and s.subItems
   local index=gen==2 and s.submenu and s.submenu.index or s.subIndex
   if items then
    local mh=#items*15+8;local my=191-mh
    Theme.interfacePanel(123,my,109,mh,false,'menu')
    for i,item in ipairs(items)do
     local y=my+5+(i-1)*15
     if i==index then G.setColor(.14,.39,.34,1);G.rectangle('fill',126,y-2,103,14)end
     Theme.text(item.label,131,y,95,i==index and{1,1,1,1}or Theme.ink)
    end
   end
  end)
  G.pop();if not ok then error(err,0)end
  return result
 end)
 return function()active=false end
end
