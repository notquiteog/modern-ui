-- Bill's PC uses ordinary menus. Track its root, then present only its native
-- Menu/ListMenu descendants; confirmations, text and summaries retain ownership.
return function(mod,Theme,enabled)
 if require('src.core.GameVersion').generation()~=1 then return function()end end
 local Box=require('src.ui.BoxMenu');local Menu=require('src.ui.Menu');local List=require('src.ui.ListMenu')
 local Boxes=require('src.pokemon.Boxes');local roots=setmetatable({},{__mode='k'});local active=true
 local original=Box.new;local wrapped=function(...)local s=original(...);roots[s]=true;return s end;Box.new=wrapped
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport);if not active or not enabled()then return result end
  local stack=game.stack;local top=stack and stack:top();local root
  for i,s in ipairs(stack and stack.states or{})do if roots[s]then root=i;break end end
  if not root or(getmetatable(top)~=Menu and getmetatable(top)~=List)then return result end
  local G=love.graphics;local w,h=G.getDimensions();local scale=math.floor(math.min(w/300,h/236));if scale<1 then return result end
  G.push('all');local ok,err=pcall(function()
   G.origin();G.setShader();G.setScissor();G.setDepthMode();G.setColor(.075,.12,.13,1);G.rectangle('fill',0,0,w,h)
   G.translate(math.floor((w-300*scale)/2),math.floor((h-236*scale)/2));G.scale(scale)
   Theme.text('POKEMON STORAGE',8,8,284,{.88,.95,.93,1},true)
   local count=#((game.save.boxes or{})[game.save.currentBox or 1]or{})
   Theme.text('BOX '..tostring(game.save.currentBox or 1)..'   '..count..' / '..Boxes.CAPACITY,8,24,284,{.61,.74,.70,1})
   local s=top;local items=s.items or{};local scroll=s.scroll or 0
   local visible=getmetatable(s)==List and(s.itemBox and 4 or 7)or math.min(s.maxVisible or #items,7)
   if #items>visible and not s.maxVisible and getmetatable(s)==Menu then scroll=math.max(0,math.min(#items-visible,(s.index or 1)-visible))end
   Theme.panel(8,42,284,visible*22+12,false)
   for row=1,visible do local i=scroll+row;local item=items[i];if item then
    local y=48+(row-1)*22
    if i==s.index then G.setColor(.77,.86,.69,1);G.rectangle('fill',12,y,276,20)end
    Theme.text(item.label or'',20,y+5,item.sub and 196 or 264,Theme.ink)
    if s.kind=='pc_box_change'then
     Theme.text(tostring(#((game.save.boxes or{})[i]or{}))..' / '..Boxes.CAPACITY,220,y+5,64,Theme.ink)
    elseif item.sub then Theme.text(tostring(item.sub):gsub(':L','Lv.'),220,y+5,64,Theme.ink)end
   end end
   if s.footer then Theme.text(s.footer,12,208,276,{.88,.95,.93,1})end
   Theme.text('A  SELECT     B  BACK',8,225,284,{.61,.74,.70,1})
  end);G.pop();if not ok then error(err,0)end;return result
 end)
 return function()active=false;if Box.new==wrapped then Box.new=original end end
end
