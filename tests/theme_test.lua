local text,scale
love={graphics={newFont=function()return {setFilter=function()end,getWidth=function(_,s)return #s*6 end}end,
 setFont=function()end,setColor=function()end,print=function(s,x,y,angle,sx)text=s;scale=sx end}}
local T=assert(loadfile('lib/Theme.lua'))()
T.text('Lv.100',0,0,21);assert(text=='Lv.100' and scale*36<=21,'level digits were truncated')
T.text('999 / 999',0,0,48);assert(text=='999 / 999','HP digits were truncated')
T.text('ÉTOURAPTOR',0,0,20);assert(text=='ÉTOURAPTOR','UTF-8 nickname was cut')
assert(T.scale(160,144)==.5,'small-window commands overflow')
local p=T.layoutStatusCards({{id=0,x=40,y=70,w=76,h=27},{id=2,x=45,y=72,w=76,h=27}},320,240)
assert(p[0].x+p[0].w<p[2].x,'allied cards overlap')
print('PASS complete numeric/nickname labels, small-window fit, paired cards')
-- Selected menus carry white labels; status cards keep dark labels. Their
-- focus treatment must not silently invert that contrast relationship.
local fills,color={},{}
love.graphics.setColor=function(...)color={...}end
love.graphics.rectangle=function(mode,x,y,w,h)if mode=='fill'then fills[#fills+1]=color end end
love.graphics.line=function()end;love.graphics.setLineWidth=function()end;love.graphics.polygon=function()end
T.panel(0,0,76,22,true)
local selected=fills[#fills];assert(selected[1]<.3 and selected[2]<.5,'white menu label lost dark selected paper')
T.statusCard(0,0,76,22,38,true)
local card=fills[#fills];assert(card[1]>.6 and card[2]>.6,'dark card label lost light paper')
print('PASS selected menu/card ink contrast')

local cluster={}
for id=0,3 do cluster[#cluster+1]={id=id,x=160,y=45,w=76,h=id%2==0 and 27 or 22}end
local layout=T.layoutStatusCards(cluster,320,240)
for i=0,3 do
 local a=layout[i];assert(a.x>=3 and a.x+a.w<=317 and a.y>=3 and a.y+a.h<=231)
 for j=i+1,3 do local b=layout[j];assert(a.x+a.w<=b.x or b.x+b.w<=a.x or a.y+a.h<=b.y or b.y+b.h<=a.y,'opposing cards overlap at a shared projected head')end
end
print('PASS all four projected cards remain distinct at camera-edge convergence')
