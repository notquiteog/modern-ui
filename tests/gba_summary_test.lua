local safe,firstOrigin
local function viewport(w,h)if safe then return unpack(safe)end;return 0,0,w,h end
local noop=function()end;local texts={};local drawCalls=0;local enabled=true;local hook
local mon={species=25,level=25,hp=42,maxHp=60,markings=3,moves={{id=1,pp=19}},maxPp={20},nickname='SPARK'}
local A={draw=function()drawCalls=drawCalls+1 end};local oldAnim=A.draw
local S={open=true,_party={mon},_cursor=1,_page=0,PAGE_MOVES_INFO=3,dexNoText=function()return'025'end,ballIdOf=function()return 0 end}
S.draw=function()A.draw({mon=mon},{},40,64)end;local oldDraw=S.draw
local P={isEgg=function(m)return m.isEgg end,displayName=function(m)return m.nickname end,speciesOf=function(m)return m.species end,
name=function()return'PIKACHU'end,types=function()return{13,13}end,hasHadPokerus=function()return false end,
growthRate=function()return 0 end,abilityId=function()return 9 end,abilityName=function()return'STATIC'end,
monFrontPic=function()return{image={},w=64,h=64}end,moveIdAt=function(m,i)return m.moves[i]and m.moves[i].id end,battleMove=function()return{pp=20,power=40,accuracy=100}end,movePp=function()return 20 end,moveName=function()return'THUNDERSHOCK'end}
local D={formatTrainerMemo=function()return{'Native trainer memo'}end,eggHatchText=function()return'An egg is close to hatching.'end,
gender=function()return'F'end,statusAilment=function()return 0 end,isShiny=function()return false end,
expProgress=function()return{totalExp=1234,expNeeded=321,progressPercent=.5}end,abilityDescription=function()return'Native ability description'end,
moveDescription=function()return'Native move description'end}
package.loaded['src.core.GameVersion']={generation=function()return 3 end,get=function()return'leafgreen'end}
package.loaded['src.ui.game3.summary_chrome']={manifest=function()return{}end}
package.loaded['src.ui.game3.summary_menu']=S;package.loaded['src.core.game3.pokemon']=P;package.loaded['src.core.game3.summary_data']=D
package.loaded['src.core.game3.rom_text']={plain=function(x)return x end};package.loaded['src.ui.game3.rse.scene_kit']={}
package.loaded['src.core.game3.mon_anim']=A;package.loaded['src.ui.game3.stack']={top=function()return{mod=S}end}
package.loaded['src.core.game3.items_data']={toNumericId=function()return 0 end}
package.loaded['src.core.game3.battle.types']={name=function()return'ELECTRIC'end}
package.loaded['src.core.game3.battle.ui']={ballQuad=function()return nil end}
love={graphics={getDimensions=function()return 1280,960 end}}
for _,k in ipairs({'push','pop','origin','setShader','setScissor','setDepthMode','setMeshCullMode','setStencilTest','setBlendMode','setColor','rectangle','translate','scale','draw','setLineWidth','circle','polygon'})do love.graphics[k]=noop end
love.graphics.translate=function(x,y)if not firstOrigin then firstOrigin={x,y}end end
local rasterReset=false;love.graphics.setMeshCullMode=function(mode)assert(mode=='none');rasterReset=true end
local undo=assert(loadfile('lib/GBASummary.lua'))()({hooks={wrap=function(_,_,f)hook=f end}},
 {viewport=viewport,text=function(s)table.insert(texts,s)end,panel=noop,hpColor=function()return 0,1,0,1 end,ink={}},function()return enabled end)
local function run()texts={};local before=drawCalls;assert(hook(function()S.draw();return 17 end,{session={}})==17);return table.concat(texts,'|'),drawCalls-before end
local t,n=run();assert(rasterReset);assert(t:find('PIKACHU',1,true)and t:find('Native trainer memo',1,true)and n==1)
safe={10,20,640,480};firstOrigin=nil;t=run();assert(firstOrigin[1]==10 and firstOrigin[2]==20,'GBA summary safe origin/scale')
safe={10,20,319,240};t,n=run();assert(t==''and n==1,'undersized GBA summary must stay native');safe=nil
S._page=1;t=run();assert(t:find('STATIC',1,true)and t:find('1234',1,true))
S._page=3;t=run();assert(t:find('19/20',1,true)and t:find('Native move description',1,true));assert(mon.moves[1].pp==19)
mon.isEgg=true;t=run();assert(t:find('?????',1,true)and not t:find('PIKACHU',1,true)and not t:find('STATIC',1,true))
enabled=false;t,n=run();assert(t==''and n==1)
undo();assert(A.draw==oldAnim and S.draw==oldDraw)
print('PASS GBA semantic fields, native controller delegation, PP, egg privacy, OFF/unload')
-- Emerald uses the native animation state in an isolated portrait target.
local released=false;local canvas={release=function()released=true end};local target
love.graphics.newCanvas=function(w,h)assert(w==88 and h==72);return canvas end
love.graphics.setCanvas=function(c)target=c end;love.graphics.clear=noop
package.loaded['src.core.GameVersion'].get=function()return'emerald'end
local sprite={mon=mon,frame=0};package.loaded['src.ui.game3.rse.summary_menu']={_st={monSprite=sprite},page=function()return 2 end,detail=function()return true end}
P.monPicSpecies=P.speciesOf;P.isShiny=function()return false end;A.framePic=function()return nil end
mon.isEgg=false;enabled=true;S._page=2
local stop=assert(loadfile('lib/GBASummary.lua'))()({hooks={wrap=function(_,_,f)hook=f end}},
 {viewport=viewport,text=function(s)table.insert(texts,s)end,panel=noop,hpColor=function()return 0,1,0,1 end,ink={}},function()return enabled end)
local before=drawCalls;run();assert(target==canvas and drawCalls==before+2 and sprite.frame==0);stop();assert(released)
print('PASS Emerald native animation isolation and cleanup')
