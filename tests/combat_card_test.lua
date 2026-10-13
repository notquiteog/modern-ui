local polygons,rects,texts={}, {},{}
love={graphics={setColor=function()end,polygon=function(mode,p)if mode=='fill'then polygons[#polygons+1]=p end end,
 rectangle=function(mode,x,y,w,h)rects[#rects+1]={x=x,y=y,w=w,h=h}end,push=function()end,pop=function()end,translate=function()end,scale=function()end}}
local T=assert(loadfile('lib/Theme.lua'))()
T.text=function(v)texts[#texts+1]=tostring(v)end;T.gender=function(v)assert(v=='F')end;T.caught=function()end
local w,h=T.combatCardSize(false);assert(w==90 and h==18)
assert(T.combatCard(10,20,w,h,50,true,{name='VENUSAUR',level=100,gender='F',hp=21,maximum=100,status='PSN',caught=true}))
assert(polygons[2][1]~=polygons[2][#polygons[2]-1],'HP frame became rectangle')
assert(#rects==3 and rects[3].h==2,'HP rail must stay thin')
local joined=table.concat(texts,' ');assert(joined:find('VENUSAUR')and joined:find('Lv.100',1,true)and joined:find('PSN'))
polygons,rects,texts={},{},{}
w,h=T.combatCardSize(true);T.combatCard(0,0,w,h,40,false,{ally=true,name='NICKNAME',level=99,gender='F',hp=333,maximum=444,exp=.5})
assert(#polygons==6,'player extension is not a separate strip')
assert(table.concat(texts,' '):find('333 / 444',1,true),'numeric HP lost')
assert(rects[#rects].h==1 and rects[#rects].w==(w-37)*.5,'EXP lost')
print('PASS asymmetric layered rail, compact native fields, numeric HP and EXP')

T.combatCard(0,0,90,18,0,false,{name='ZERO',level=1,gender='F',hp=0,maximum=0});assert(rects[#rects].w==0,'zero max HP generated an invalid rail')
