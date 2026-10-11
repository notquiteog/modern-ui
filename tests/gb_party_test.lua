local install=assert(loadfile('lib/GBParty.lua'))()
local current,hook,paint,on,native,push,pop,texts
local g=setmetatable({getDimensions=function()return 1024,768 end,push=function()push=push+1 end,pop=function()pop=pop+1 end},{__index=function()return function()end end})
love={graphics=g}
for gen=1,2 do
 paint,native,push,pop,on=0,0,0,0,true;texts={}
 package.loaded['src.core.GameVersion']={generation=function()return gen end}
 package.loaded['src.core.Strings']=function(v)return v end
 package.loaded['src.ui.LevelDisplay']={visible=function()return false end}
 local Party={drawIcon=function()end,rowFor=function(mon)return{name=mon.species}end}
 package.loaded[gen==1 and'src.ui.PartyMenu'or'src.ui.gen2.PartyMenu']=Party
 local mon={species='PIKACHU',level=5,hp=15,maxHp=20,stats={hp=20}}
 local screen=setmetatable({party={mon},index=1,prompt='Choose.',bottomMessage=function()return'Choose.'end,
 drawIcon=function()end,shownHpFor=function()return 15 end,iconBob=function()return 0 end,isCancel=function()return false end},Party)
 current=screen
 local game={data={pokemon={PIKACHU={name='PIKACHU',tmhm={'SURF'},evolutions={{method='ITEM',item='THUNDER_STONE'}}}}},save={party={mon}},stack={top=function()return current end}}
 local Theme={text=function(t)texts[t]=true end,partyCard=function()paint=paint+1 end,interfacePanel=function()end,hpColor=function()return 0,1,0,1 end,ink={}}
 local undo=install({hooks={wrap=function(_,key,fn)assert(key=='render.hud');hook=fn end}},Theme,function()return on end)
 local function draw()hook(function()native=native+1;return'native'end,game,{})end
 draw();assert(paint>0 and native==1,'native render chain lost')
 assert(mon.hp==15 and screen.index==1,'render mutated gameplay')
 local before=paint;screen.itemUse=true;draw();assert(paint>before,'item selection retained native-only roster');screen.itemUse=nil
 screen.tmhm={move='SURF'};screen.tmhmAble=function()return'ABLE'end;texts={};draw();assert(texts.ABLE,'native TM eligibility missing');screen.tmhm=nil
 screen.evoStone='THUNDER_STONE';texts={};draw();assert(texts.ABLE,'stone eligibility missing');screen.evoStone=nil
 if gen==1 then
  screen.heal={mon=mon,shown=8,px=19};texts={};draw();assert(texts['8/20'] and mon.hp==15,'healing animation changed HP');screen.heal=nil
 else
  screen.itemResult={text='First\nSecond\nThird'};screen.itemResultClimbing=function()return false end;texts={};draw();assert(texts.First and texts.Second and texts.Third,'native item message truncated');screen.itemResult=nil
 end
 before=paint
 screen.gridNavigation=function()return true end;draw();assert(paint==before,'companion grid was overpainted');screen.gridNavigation=nil
 current={};draw();assert(paint==before,'overlay leaked above modal');current=screen
 on=false;draw();assert(paint==before,'OFF changed native view');on=true
 undo();draw();assert(paint==before,'unload retained overlay');assert(push==pop,'graphics state leaked')
end
print('PASS GB roster original input/state, native modal/item/OFF/unload fallback')
