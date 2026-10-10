local install=assert(loadfile('lib/GBParty.lua'))()
local current,hook,paint,on,native,push,pop
local g=setmetatable({getDimensions=function()return 1024,768 end,push=function()push=push+1 end,pop=function()pop=pop+1 end},{__index=function()return function()end end})
love={graphics=g}
for gen=1,2 do
 paint,native,push,pop,on=0,0,0,0,true
 package.loaded['src.core.GameVersion']={generation=function()return gen end}
 package.loaded['src.core.Strings']=function(v)return v end
 package.loaded['src.ui.LevelDisplay']={visible=function()return false end}
 local Party={drawIcon=function()end,rowFor=function(mon)return{name=mon.species}end}
 package.loaded[gen==1 and'src.ui.PartyMenu'or'src.ui.gen2.PartyMenu']=Party
 local mon={species='PIKACHU',level=5,hp=15,maxHp=20,stats={hp=20}}
 local screen=setmetatable({party={mon},index=1,prompt='Choose.',bottomMessage=function()return'Choose.'end,
 drawIcon=function()end,shownHpFor=function()return 15 end,iconBob=function()return 0 end,isCancel=function()return false end},Party)
 current=screen
 local game={data={pokemon={PIKACHU={name='PIKACHU'}}},save={party={mon}},stack={top=function()return current end}}
 local Theme={text=function()end,partyCard=function()paint=paint+1 end,interfacePanel=function()end,hpColor=function()return 0,1,0,1 end,ink={}}
 local undo=install({hooks={wrap=function(_,key,fn)assert(key=='render.hud');hook=fn end}},Theme,function()return on end)
 local function draw()hook(function()native=native+1;return'native'end,game,{})end
 draw();assert(paint>0 and native==1,'native render chain lost')
 assert(mon.hp==15 and screen.index==1,'render mutated gameplay')
 local before=paint;screen.itemResult={};draw();assert(paint==before,'item flow replaced');screen.itemResult=nil
 screen.tmhm={};draw();assert(paint==before,'teaching flow replaced');screen.tmhm=nil
 screen.gridNavigation=function()return true end;draw();assert(paint==before,'companion grid was overpainted');screen.gridNavigation=nil
 current={};draw();assert(paint==before,'overlay leaked above modal');current=screen
 on=false;draw();assert(paint==before,'OFF changed native view');on=true
 undo();draw();assert(paint==before,'unload retained overlay');assert(push==pop,'graphics state leaked')
end
print('PASS GB roster original input/state, native modal/item/OFF/unload fallback')
