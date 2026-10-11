-- Crystal's PC controller supplies live rows, insertion state and messages.
-- This renderer never changes the party, boxes, selection or release flow.
return function(mod,Theme,enabled)
 if require('src.core.GameVersion').generation()~=2 then return function()end end
 local Box=require('src.ui.gen2.BoxMenu');local Strings=require('src.core.Strings')
 local CommonText=require('src.core.gen2.CommonText');local active=true
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport);local s=game.stack and game.stack:top()
  if not active or not enabled()or getmetatable(s)~=Box then return result end
  local G=love.graphics;local w,h=G.getDimensions();local scale=math.floor(math.min(w/280,h/220));if scale<1 then return result end
  G.push('all');local ok,err=pcall(function()
   G.origin();G.setShader();G.setScissor();G.setDepthMode();G.setColor(.075,.12,.13,1);G.rectangle('fill',0,0,w,h)
   G.translate(math.floor((w-280*scale)/2),math.floor((h-220*scale)/2));G.scale(scale)
   Theme.text(s:title(),8,8,264,{.88,.95,.93,1},true)
   Theme.panel(8,28,88,136,false);Theme.panel(104,28,168,136,false)
   local m=not s.panelCleared and s:panelMon()or nil
   if m then
    G.push();G.translate(16,8);if m.isEgg then s:drawEggPic(m)else s:drawPic(m)end;G.pop();G.setShader()
    if not m.isEgg then
     Theme.text(m.nickname or m.name or m.species,16,106,72,Theme.ink)
     Theme.text('Lv.'..tostring(m.level or 1),16,124,72,Theme.ink)
     Theme.text(m.name or m.species,16,142,72,Theme.ink)
    else Theme.text(Strings('EGG'),16,116,72,Theme.ink)end
   end
   local list=s:list()
   for row=1,5 do local i=row+s.scroll;local mon=list[i];local y=34+(row-1)*24
    if i==s.index and s:selectionFrameVisible()then
     G.setColor(.77,.86,.69,1);G.rectangle('fill',110,y,156,22)
    elseif i==s.index and s.phase=='insert'then
     G.setColor(.34,.53,.30,1);G.rectangle('fill',110,y,156,2)
    end
    local label=mon and(mon.nickname or mon.name or mon.species or'?')or(s.phase~='insert'and i==s:total()and Strings('CANCEL'))
    if label then Theme.text(label,118,y+6,140,Theme.ink)end
   end
   Theme.panel(8,172,264,32,false)
   local lines=s.message and((CommonText.pages(s.message)or{})[s.messagePage or 1]or{})or{s:prompt()}
   for i,line in ipairs(lines)do Theme.text(line,16,178+(i-1)*12,248,Theme.ink)end
   if s.phase=='submenu'then
    local rows=s:submenuRows();Theme.panel(148,45,116,#rows*24+12,false)
    for i,label in ipairs(rows)do
     if i==s.submenuIndex then G.setColor(.77,.86,.69,1);G.rectangle('fill',152,51+(i-1)*24,108,22)end
     Theme.text(Strings(label),160,57+(i-1)*24,96,Theme.ink)
    end
   end
   Theme.text('A  SELECT     B  BACK',8,210,264,{.61,.74,.70,1})
  end);G.pop();if not ok then error(err,0)end;return result
 end)
 return function()active=false end
end
