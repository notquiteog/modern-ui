-- Semantic layouts consume native fields without taking over navigation.
for gen=1,2 do
 local hooks={};local enabled=true;local text={};local noop=function()end
 local S={};S.__index=S
 package.loaded['src.core.GameVersion']={generation=function()return gen end}
 package.loaded[gen==1 and'src.ui.SummaryMenu'or'src.ui.gen2.SummaryMenu']=S
 package.loaded['src.core.Strings']=function(x)return x end
 package.loaded['src.ui.LevelDisplay']={visible=function()return true end}
 package.loaded['src.battle.Status']={hudLabelFor=function()return'OK'end}
 package.loaded['src.battle.TypeChart']={displayName=function(x)return x end}
 package.loaded['src.pokemon.Growth']={expForLevel=function()return 300 end}
 love={graphics={getDimensions=function()return 1024,960 end,push=noop,pop=noop,origin=noop,setShader=noop,setScissor=noop,setDepthMode=noop,setColor=noop,rectangle=noop,translate=noop,scale=noop}}
 local theme={text=function(v)table.insert(text,tostring(v))end,panel=noop,hpColor=function()return{}end}
 local mod={hooks={wrap=function(_,key,fn)hooks[key]=fn end}}
 local undo=assert(loadfile('lib/GBSummary.lua'))()(mod,theme,function()return enabled end)
 local mon={species='PIKACHU',nickname='SPARK',level=5,hp=8,stats={hp=10,attack=4,defense=4,speed=5,special=5},moves={},exp=125}
 local s=setmetatable({mon=mon,page=1,drawPic=noop,drawEggPic=noop,
 upperPlacements=function()return{{text='SPARK',x=8,y=2}}end,
 pinkPlacements=function()return{{text='électricité',x=1,y=10}}end,
 greenPlacements=function()return{{text='THUNDER',x=1,y=10}}end,
 bluePlacements=function()return{{text='TRAINER',x=1,y=10}}end,
 eggPlacements=function()return{{text='?????',x=8,y=3}}end,
 moveDetailPlacements=function()return{{text='┌ÉLECTRIC┐',x=1,y=3}}end},S)
 local game={stack={top=function()return s end},data={pokemon={PIKACHU={name='PIKACHU',types={'ELECTRIC'}}}},save={player={}}}
 local function draw()text={};assert(hooks['render.hud'](function()return 123 end,game)==123);return table.concat(text,'|')end
 assert(draw():find('SPARK',1,true));assert(s.page==1 and mon.hp==8)
 s.page=2;assert(draw():find('MOVES',1,true))
 if gen==2 then
  s.moveDetail=true;assert(draw():find('ÉLECTRIC',1,true));s.moveDetail=false
  s.mon.isEgg=true;local egg=draw();assert(egg:find('?????',1,true)and not egg:find('SPARK',1,true))
 end
 enabled=false;assert(draw()=='');enabled=true;undo();assert(draw()=='')
end
print('PASS semantic GB summaries: native fields, UTF-8, egg privacy, OFF/unload')
do
 local B={};B.__index=B;local hook;local enabled=true;local texts={};local noop=function()end
 package.loaded['src.core.GameVersion']={generation=function()return 2 end}
 package.loaded['src.ui.gen2.BoxMenu']=B
 package.loaded['src.core.gen2.CommonText']={pages=function()return{{'REFUSAL','KEEP THIS MON'}}end}
 local mon={species='PIKACHU',level=12}
 local s=setmetatable({index=1,scroll=0,drawPic=noop,drawEggPic=noop,title=function()return'BOX 1'end,
 panelMon=function()return mon end,list=function()return{mon}end,total=function()return 2 end,
 selectionFrameVisible=function()return true end,prompt=function()return'CHOOSE'end,
 submenuRows=function()return{'WITHDRAW','STATS','CANCEL'}end},B)
 local undo=assert(loadfile('lib/GBStorage.lua'))()({hooks={wrap=function(_,_,f)hook=f end}},
 {text=function(s)table.insert(texts,s)end,panel=noop,ink={}},function()return enabled end)
 local game={stack={top=function()return s end}}
 hook(noop,game);assert(table.concat(texts,'|'):find('PIKACHU'));assert(s.index==1)
 s.message='refusal';s.phase='submenu';s.submenuIndex=2;texts={};hook(noop,game)
 assert(table.concat(texts,'|'):find('KEEP THIS MON')and table.concat(texts,'|'):find('WITHDRAW'))
 mon.isEgg=true;s.phase=nil;s.message=nil;texts={};hook(noop,game)
 assert(not table.concat(texts,'|'):find('Lv.12',1,true),'egg stats leaked')
 enabled=false;texts={};hook(noop,game);assert(#texts==0);undo()
end
print('PASS semantic Crystal PC live rows, submenus, messages, egg privacy and OFF')
