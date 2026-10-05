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
