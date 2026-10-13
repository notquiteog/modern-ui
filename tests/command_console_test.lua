local polygons,rects,texts,colors={},{},{},{}
love={graphics={setColor=function(...)colors[#colors+1]={...}end,polygon=function(mode,p)polygons[#polygons+1]={mode=mode,p=p}end,
 rectangle=function(mode,x,y,w,h)rects[#rects+1]={x,y,w,h}end,setLineWidth=function()end,line=function()end,
 newFont=function()return{setFilter=function()end,getWidth=function(_,s)return #s*6 end}end,setFont=function()end,
 print=function(s,x,y,rot,sx,sy)texts[#texts+1]={s=s,x=x,sx=sx,sy=sy}end}}
local T=assert(loadfile('lib/Theme.lua'))()
local m=T.commandMetrics();assert(m.height==46 and m.row==22 and m.cell==17)
T.commandHub(82,m.hub,m.height)
assert(#polygons[1].p==12 and polygons[1].p[3]==164,'commands reverted to diamond hub')
for i,kind in ipairs({'fight','pokemon','bag','run'})do
 local x,y=3+(i-1)%2*82,3+math.floor((i-1)/2)*m.row
 T.button(x,y,76,m.cell,kind,i==1,i%2==0)
 T.text(kind,x+5,y+5,66,{1,1,1,1},true)
end
assert(#texts==4,'command text is double-painted')
assert(texts[1].x==8 and texts[1].sx<1,'labels lost compact left-aligned hierarchy')
for _,r in ipairs(rects)do assert(r[1]>=3 and r[1]+r[3]<=161 and r[2]>=3 and r[2]+r[4]<=42,'cell escaped native hit area')end
print('PASS shared command console, original hit regions, single-pass compact labels')

T.text('PKMN',8,8,66,nil,true);assert(texts[#texts].s=='POKEMON')
T.text('ITEMS',8,8,66,nil,true);assert(texts[#texts].s=='BAG')
