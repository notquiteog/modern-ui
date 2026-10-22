-- Compact, pixel-aligned charcoal surfaces with restrained emerald accents.
-- Native-paper seams retain their own ink contract; custom surfaces use pale ink.
local M={apiVersion=1,paper={.025,.075,.10,1},ink={.94,.97,.95,1},
 nativeInk={.13,.18,.18,1},edge={.12,.53,.64,1},selected={.035,.42,.35,1}}
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
-- Cyan chamfered roster cards: an inset health well and a bright selected
-- silhouette remain legible without relying on hue alone.
function M.partyCard(x,y,w,h,selected,empty)
 local g=love.graphics;local c=math.min(6,h/3)
 g.setColor(.005,.025,.04,1);g.polygon('fill',cutBox(x,y+1,w,h,c))
 g.setColor(unpack(selected and {.68,1,.88,1}or empty and {.10,.26,.31,1}or {.12,.76,.91,1}))
 g.polygon('fill',cutBox(x,y,w,h,c))
 g.setColor(unpack(selected and {.035,.48,.39,1}or empty and {.025,.065,.085,1}or {.025,.16,.21,1}))
 g.polygon('fill',cutBox(x+1,y+1,w-2,h-2,c-1))
 g.setColor(unpack(selected and {.06,.57,.45,1}or {.025,.20,.25,1}))
 g.polygon('fill',{x+c,y+2,x+w-2,y+2,x+w-2,y+h*.48,x+2,y+h*.48,x+2,y+c})
 if h>=28 then
  g.setColor(.01,.065,.09,.8);g.rectangle('fill',x+math.floor(w*.34),y+h-13,w-math.floor(w*.34)-2,10)
  g.setColor(.15,.62,.66,1);g.rectangle('fill',x+math.floor(w*.34),y+h-14,w-math.floor(w*.34)-2,1)
 end
 if selected then
  g.setColor(1,1,1,1);g.polygon('fill',{x+3,y+h/2-3,x+6,y+h/2,x+3,y+h/2+3})
 end
end
function M.partyBackground(x,y,w,h)
 local g=love.graphics;g.setColor(.015,.04,.065,1);g.rectangle('fill',x,y,w,h)
 g.setColor(.035,.085,.115,1)
 for row=0,math.ceil(h/12)do g.rectangle('fill',x,y+row*12,w,1)end
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
-- Semantic provider API: the title floats above a narrow asymmetric health
-- rail, while the player's numeric HP/EXP occupy a separate lower extension.
function M.combatCardSize(ally)return 90,ally and 25 or 18 end
function M.combatCard(x,y,w,h,tip,selected,c)
 local g=love.graphics;local left,right=x,x+w;local rail=y+8
 local border=selected and {.68,1,.76,1}or{.62,.68,.65,1}
 local p={left+5,rail,right,rail,right-4,rail+9,left+5,rail+9,left,rail+5}
 g.setColor(0,0,0,.65);g.polygon('fill',{left+5,rail+1,right+1,rail+1,right-3,rail+10,left+5,rail+10,left,rail+6})
 g.setColor(unpack(border));g.polygon('fill',p)
 g.setColor(.025,.035,.035,1);g.polygon('fill',{left+5,rail+1,right-1,rail+1,right-4,rail+8,left+5,rail+8,left+1,rail+5})
 g.setColor(.18,.22,.21,1);g.polygon('fill',{left+6,rail+2,right-2,rail+2,right-3,rail+4,left+3,rail+4})
 if c.ally then
  g.setColor(.46,.51,.49,1);g.polygon('fill',{left+22,rail+8,right-4,rail+8,right-7,y+h,left+28,y+h})
  g.setColor(.025,.035,.035,1);g.polygon('fill',{left+24,rail+9,right-5,rail+9,right-7,y+h-1,left+28,y+h-1})
 end
 local colorInk=c.hudColor=='COLOR'
 local titleInk=colorInk and M.nativeInk or M.ink
 local titleShadow=colorInk and {1,1,1,1}or{0,0,0,1}
 local function title(value,tx,ty,width,color)
  g.push();g.translate(.5,.5);M.text(value,tx,ty,width,titleShadow);g.pop()
  M.text(value,tx,ty,width,color or titleInk)
 end
 title(c.name,x+5,y,48);title('Lv.'..tostring(c.level),x+66,y,23)
 -- Header symbols remain separate from nicknames and the HP/status field.
 g.push('all');g.translate(x+58,y+1);g.scale(.72);M.gender(c.gender,.7,.7,{0,0,0,1});M.gender(c.gender,0,0,(c.gender=='F'or c.gender=='female'or c.gender=='♀')and{1,.37,.48,1}or{.22,.77,1,1});g.pop()
 if c.caught then g.push('all');g.translate(x-2,y+1);g.scale(.65);M.caught(0,0);g.pop()end
 M.text(c.status or 'HP',x+7,rail,16,c.status and{1,.78,.42,1}or{.94,.86,.35,1})
 local hp=math.floor(math.max(0,math.min(c.maximum,c.hp)));local fraction=hp/math.max(1,c.maximum)
 g.setColor(.61,.65,.61,1);g.rectangle('fill',x+24,rail+2,w-33,4)
 g.setColor(.015,.025,.025,1);g.rectangle('fill',x+25,rail+3,w-35,2)
 g.setColor(M.hpColor(fraction));g.rectangle('fill',x+25,rail+3,math.floor((w-35)*fraction),2)
 if c.ally then
  M.text(hp..' / '..c.maximum,x+35,rail+8,w-45)
  if c.exp~=nil then
   g.setColor(.22,.28,.27,1);g.rectangle('fill',x+29,y+h-2,w-37,1)
   g.setColor(.21,.70,.88,1);g.rectangle('fill',x+29,y+h-2,(w-37)*math.max(0,math.min(1,c.exp)),1)
  end
 end
 return true
end

-- Commands share one compact console; consumers retain native action order.
function M.commandMetrics(detail)return {height=detail and 54 or 46,row=detail and 26 or 22,cell=detail and 21 or 17,hub=detail and 27 or 23}end
--
-- active cells use a narrow mint rail instead of oversized coloured badges.
function M.button(x,y,w,h,kind,selected,flip)
 local g=love.graphics
 if selected then
  g.setColor(.10,.23,.23,1)
  g.polygon('fill',{x+3,y,x+w,y,x+w,y+h-3,x+w-3,y+h,x,y+h,x,y+3})
  g.setColor(.53,.90,.75,1);g.rectangle('fill',x,y+3,1,h-6)
  g.setLineWidth(.65);g.line(x+3,y+.5,x+w-.5,y+.5,x+w-.5,y+h-3)
  g.polygon('fill',{x+2,y+h/2-2,x+4,y+h/2,x+2,y+h/2+2})
 else
  g.setColor(.075,.105,.115,1);g.rectangle('fill',x,y,w,h)
  g.setColor(.20,.28,.29,1);g.setLineWidth(.5);g.line(x+3,y+h-.5,x+w-3,y+h-.5)
 end
end
-- Pixel symbols avoid missing gender glyphs in the bundled text face.
function M.gender(value,x,y,color)
 local male=value=='M'or value=='male'or value=='♂'
 local female=value=='F'or value=='female'or value=='♀'
 if not male and not female then return end
 local g=love.graphics;g.setColor(unpack(color or M.ink));g.setLineWidth(.8)
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
-- Public engine safe area already normalizes mobile DPI and viewport offsets.
-- Older engines and headless callers retain the complete drawable window.
function M.viewport(w,h)
 local ok,area=pcall(require,'src.core.SafeArea')
 if ok and type(area.rect)=='function'then
  local read,x,y,sw,sh=pcall(area.rect)
  if read and type(x)=='number'and type(y)=='number'and type(sw)=='number'and type(sh)=='number'
   and x>=0 and y>=0 and sw>0 and sh>0 and x+sw<=w+.5 and y+sh<=h+.5 then
   return x,y,sw,sh
  end
 end
 return 0,0,w,h
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
 local size=faceScale*(command and 1.15 or 1)
 local sx=size*1.5
 -- At less than one screen pixel per source pixel, nearest sampling erases
 -- entire glyph strokes. Preserve their coverage on small screens; integer
 -- enlargement keeps the existing crisp pixel face and bundled glyph coverage.
 if face.setFilter then
  local screenScale=1
  if G.transformPoint then
   local ax,ay=G.transformPoint(0,0);local bx,by=G.transformPoint(0,1)
   screenScale=math.sqrt((bx-ax)^2+(by-ay)^2)
  end
  local filter=size*screenScale<1 and 'linear'or'nearest'
  face:setFilter(filter,filter)
 end
 local str=tostring(value or ''):gsub('<PK><MN>','PKMN'):gsub('<LV>','Lv.'):gsub('<[^>]+>','')
 if command then str=({PKMN='POKEMON',ITEMS='BAG'})[str]or str end
 -- Fit complete names and numeric values; truncating Lv.35 to Lv.3 is wrong.
 local measured=face:getWidth(str)
 if width and measured>0 then sx=math.min(sx,math.max(0,width-.5)/measured)end
 -- PlainPixel's em includes a blank ascent above its ink; align ink, not em.
 y=y-(command and 2.5 or 4)
 G.setFont(face);G.setColor(unpack(color or M.ink))
 G.print(str,math.floor(x+.5),math.floor(y+.5),0,sx,size)
 return face:getWidth(str)*sx
end
function M.commandHub(x,y,height)
 local g=love.graphics;height=height or 60;local left,top=x-82,y-height/2
 local p={left+5,top,left+164,top,left+164,top+height-4,left+160,top+height,left,top+height,left,top+5}
 g.setColor(.02,.035,.04,.97);g.polygon('fill',p)
 g.setColor(.27,.37,.37,1);g.setLineWidth(.5);g.polygon('line',p)
 g.setColor(.19,.28,.29,1);g.setLineWidth(.5)
 g.line(x,top+4,x,top+height-4);g.line(left+5,y,left+159,y)
end
return M
