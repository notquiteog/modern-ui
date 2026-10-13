-- Compact, pixel-aligned charcoal surfaces with restrained emerald accents.
-- Native-paper seams retain their own ink contract; custom surfaces use pale ink.
local M={apiVersion=1,paper={.075,.095,.105,1},ink={.94,.97,.95,1},
 nativeInk={.13,.18,.18,1},edge={.30,.38,.39,1},selected={.09,.32,.27,1}}
M.commands={fight={.67,.12,.16,1},pokemon={.12,.36,.24,1},bag={.66,.38,.12,1},run={.16,.31,.55,1}}
local function cutBox(x,y,w,h,cut)
 return {x+cut,y,x+w,y,x+w,y+h-cut,x+w-cut,y+h,x,y+h,x,y+cut}
end
function M.panel(x,y,w,h,selected,style)
 local G=love.graphics;local cut=math.min(3,h/4)
 G.setColor(.015,.025,.025,.45);G.polygon('fill',cutBox(x,y+1,w,h,cut))
 G.setColor(unpack(M.edge));G.polygon('fill',cutBox(x,y,w,h,cut))
 G.setColor(unpack(selected and M.selected or style and style.paper or M.paper))
 G.polygon('fill',cutBox(x+1,y+1,w-2,h-2,math.max(1,cut-1)))
 G.setLineWidth(1);G.setColor(.47,.58,.57,1);G.line(x+cut,y+1,x+w-2,y+1)
end
-- Keep a pale content well wherever the engine still owns font palettes and
-- text-wipe rectangles. Dark edges and emerald accents unify these delegates.
function M.interfacePanel(x,y,w,h,monochrome,kind)
 local g=love.graphics;x=math.floor(x);y=math.floor(y);w=math.floor(w);h=math.floor(h)
 g.setColor(monochrome and 0 or .075,monochrome and 0 or .095,monochrome and 0 or .105,1)
 g.rectangle('fill',x+1,y,w-2,h);g.rectangle('fill',x,y+1,w,h-2)
 g.setColor(1,1,1,1);g.rectangle('fill',x+2,y+2,w-4,h-4)
 if not monochrome then
  g.setColor(.29,.56,.45,1);g.rectangle('fill',x+2,y+1,w-4,1)
  g.setColor(.15,.31,.27,1);g.rectangle('fill',x+2,y+h-2,w-4,1)
 end
end
function M.partyCard(x,y,w,h,selected,empty)
 M.panel(x,y,w,h,selected,{paper=empty and{.055,.075,.08,1}or M.paper})
 if selected then
  love.graphics.setColor(.56,.88,.70,1)
  love.graphics.rectangle('fill',x+1,y+3,2,h-6)
 end
end
function M.statusCard(x,y,w,h,tip,selected,style)
 local G=love.graphics
 tip=math.max(x+6,math.min(x+w-6,tip or x+w/2))
 G.setColor(unpack(M.edge));G.polygon('fill',{tip-4,y+h-1,tip+4,y+h-1,tip,y+h+4})
 G.setColor(unpack(style and style.paper or M.paper));G.polygon('fill',{tip-2.5,y+h-1,tip+2.5,y+h-1,tip,y+h+2.5})
 M.panel(x,y,w,h,false,style)
 if selected then
  G.setLineWidth(1);G.setColor(.70,1,.78,1)
  G.polygon('line',cutBox(x+.5,y+.5,w-1,h-1,3))
  G.polygon('fill',{tip-3,y+h,tip+3,y+h,tip,y+h+3})
 end
end
function M.button(x,y,w,h,kind,selected,flip)
 local G=love.graphics;local c=M.commands[kind]or {.22,.34,.52,1}
 local cut=4
 local p=flip and {x,y,x+w-cut,y,x+w,y+cut,x+w,y+h,x+cut,y+h,x,y+h-cut}
  or {x+cut,y,x+w,y,x+w,y+h-cut,x+w-cut,y+h,x,y+h,x,y+cut}
 G.setColor(.16,.17,.15,1);G.polygon('fill',p)
 G.setLineWidth(selected and 1.2 or .65)
 G.setColor(c[1],c[2],c[3],1);G.polygon('fill',p)
 G.setColor(selected and 1 or .32,selected and .94 or .35,selected and .78 or .29,1);G.polygon('line',p)
 G.setColor(1,1,1,.18);G.line(x+cut,y+2,x+w-3,y+2)
 -- Original restrained emblems: readable even without hue discrimination.
 local cx,cy=x+w-13,y+h/2
 G.setColor(1,1,1,.18);G.setLineWidth(1.5)
 if kind=='pokemon' then
  G.circle('line',cx,cy,6);G.line(cx-6,cy,cx+6,cy);G.circle('fill',cx,cy,2)
 elseif kind=='bag' then
  G.rectangle('line',cx-5,cy-4,10,9,1,1);G.arc('line','open',cx,cy-4,3,math.pi,2*math.pi)
 elseif kind=='fight' then
  G.polygon('fill',{cx-6,cy+5,cx-2,cy-5,cx+2,cy-1,cx+6,cy-5,cx+2,cy+5})
 elseif kind=='run' then
  G.line(cx-6,cy,cx+6,cy,cx+2,cy-4);G.line(cx+6,cy,cx+2,cy+4)
 end
 if selected then
  G.setColor(1,.95,.78,1);G.polygon('fill',{x+2,y+h/2-2,x+5,y+h/2,x+2,y+h/2+2})
 end
end
-- Pixel symbols avoid missing gender glyphs in the bundled text face.
function M.gender(value,x,y)
 local male=value=='M'or value=='male'or value=='♂'
 local female=value=='F'or value=='female'or value=='♀'
 if not male and not female then return end
 local g=love.graphics;g.setColor(unpack(M.ink));g.setLineWidth(.8)
 g.circle('line',x+2,y+3,1.7)
 if male then g.line(x+3,y+2,x+6,y-1,x+3,y-1);g.line(x+6,y-1,x+6,y+2)
 else g.line(x+2,y+5,x+2,y+8);g.line(x,y+6,x+4,y+6)end
end
function M.caught(x,y)
 local g=love.graphics;g.setColor(unpack(M.ink));g.setLineWidth(.8)
 g.circle('line',x+3,y+3,2.6);g.line(x,y+3,x+6,y+3);g.circle('fill',x+3,y+3,.8)
end
function M.hpColor(fraction)
 if fraction>.5 then return .09,.73,.21,1 end
 if fraction>.2 then return .93,.65,.23,1 end
 return .87,.29,.28,1
end
function M.scale(w,h)return math.max(.5,math.min(4,w/320,h/240))end
function M.aboveHead(x,y,w,h,viewW,viewH)
 return math.max(3,math.min(viewW-w-3,x-w/2)),math.max(3,math.min(viewH-h-9,y-h-10))
end
-- Keep paired status cards apart while retaining each sprite's own pointer.
-- Layout uses the projected heads, so it also follows native battle motion.
function M.layoutStatusCards(items,viewW,viewH)
 local placed={}
 for _,item in ipairs(items)do
  local x,y=M.aboveHead(item.x,item.y,item.w,item.h,viewW,viewH)
  placed[item.id]={x=x,y=y,w=item.w,h=item.h,tip=item.x}
 end
 for side=0,1 do
  local group={}
  for _,item in ipairs(items)do if item.id%2==side then group[#group+1]=item end end
  table.sort(group,function(a,b)return a.x==b.x and a.id<b.id or a.x<b.x end)
  for i=2,#group do
   local a,b=placed[group[i-1].id],placed[group[i].id]
   if a.y<b.y+b.h+6 and b.y<a.y+a.h+6 and a.x+a.w+5>b.x then
    if a.w+b.w+11<=viewW then
     local middle=(a.x+a.w+b.x)/2
     local left=math.max(3,math.min(viewW-a.w-b.w-8,middle-a.w-2.5))
     a.x=left;b.x=left+a.w+5
    else
     -- Very narrow screens: keep both cards above their sprites.
     b.y=math.max(3,a.y-b.h-9)
     if b.y+b.h+6>a.y then a.y=b.y+b.h+9 end
    end
   end
  end
 end
 -- Opposing teams can also converge during a camera pan or at the screen
 -- edge. Resolve across every slot, not just same-side doubles partners.
 local order={};for _,item in ipairs(items)do order[#order+1]=item end
 table.sort(order,function(a,b)
  local pa,pb=placed[a.id],placed[b.id]
  if pa.x~=pb.x then return pa.x<pb.x end
  if pa.y~=pb.y then return pa.y<pb.y end
  return a.id<b.id
 end)
 local settled={}
 local function overlaps(x,y,w,h,p)
  return x<p.x+p.w+5 and p.x<x+w+5 and y<p.y+p.h+7 and p.y<y+h+7
 end
 for _,item in ipairs(order)do
  local card=placed[item.id];local xs,ys={card.x},{card.y}
  for _,p in ipairs(settled)do
   xs[#xs+1]=p.x-card.w-5;xs[#xs+1]=p.x+p.w+5
   ys[#ys+1]=p.y-card.h-7;ys[#ys+1]=p.y+p.h+7
  end
  local best,cost
  for _,cx in ipairs(xs)do for _,cy in ipairs(ys)do
   local x=math.max(3,math.min(viewW-card.w-3,cx))
   local y=math.max(3,math.min(viewH-card.h-9,cy));local clear=true
   for _,p in ipairs(settled)do if overlaps(x,y,card.w,card.h,p)then clear=false;break end end
   -- Prefer moving above or beside a head; a downward repair may cover it.
   local d=(x-card.x)^2+(y-card.y)^2+(y>card.y and 100000 or 0)
   if clear and (not cost or d<cost)then best={x,y};cost=d end
  end end
  if best then card.x,card.y=best[1],best[2]end
  settled[#settled+1]=card
 end
 return placed
end
-- Use the engine's bundled pixel face directly at its design grid. Text is
-- composited at window resolution, outside the world/attack effect canvases.
local face,faceScale
function M.text(value,x,y,width,color,command)
 local G=love.graphics
 if not face then
  local ok,f=pcall(G.newFont,'assets/fonts/plainpixel/PlainPixel-Regular.ttf',15,'mono',1)
  face=ok and f or G.newFont(7);faceScale=ok and .5 or 1
  if face.setFilter then face:setFilter('nearest','nearest')end
 end
 local size=faceScale*(command and 1.5 or 1)
 local sx=size*1.5
 local str=tostring(value or ''):gsub('<PK><MN>','PKMN'):gsub('<LV>','Lv.'):gsub('<[^>]+>','')
 -- Fit complete names and numeric values; truncating Lv.35 to Lv.3 is wrong.
 local measured=face:getWidth(str)
 if width and measured>0 then sx=math.min(sx,math.max(0,width-.5)/measured)end
 if command and width then x=x+math.max(0,(width-face:getWidth(str)*sx)/2)end
 -- PlainPixel's em includes a blank ascent above its ink; align ink, not em.
 y=y-(command and 2.5 or 4)
 G.setFont(face);G.setColor(unpack(color or M.ink))
 G.print(str,math.floor(x+.5),math.floor(y+.5),0,sx,size)
 if command then G.print(str,math.floor(x+.5)+.4,math.floor(y+.5),0,sx,size)end
 return face:getWidth(str)*sx
end
function M.commandHub(x,y)
 local G=love.graphics
 G.setColor(.16,.17,.16,1)
 G.polygon('fill',{x,y-8,x+8,y,x,y+8,x-8,y})
 G.setColor(.07,.08,.07,1);G.setLineWidth(.6)
 G.polygon('line',{x,y-8,x+8,y,x,y+8,x-8,y})
end
return M
