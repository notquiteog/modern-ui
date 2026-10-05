local install=assert(loadfile('lib/NativeFrames.lua'))()
local panels,native,on,owns=0,0,true,false
love={graphics={push=function()end,pop=function()end,setShader=function()end}}
local mod={find=function()return owns and {exports={battlePresentation={nativeHudOwned=function()return true end}}}end}
local Theme={panel=function()panels=panels+1 end}
for gen=1,3 do
 package.loaded['src.core.GameVersion']={generation=function()return gen end}
 local state={drawHUDs=function()native=native+1 end,drawEnemyHud=function()native=native+1 end,drawPlayerHud=function()native=native+1 end}
 package.loaded['src.battle.BattleState']=state;package.loaded['src.ui.gen2.BattleState']=state
 love.graphics.newShader=function()return{}end
 love.graphics.setShader=function(shader)if shader then panels=panels+1 end end
 local image={getDimensions=function()return 100,40 end}
 local chrome={_playerBox=image,_enemyBox=image,drawPlayerBox=function()native=native+1 end,drawEnemyBox=function()native=native+1 end}
 package.loaded['src.ui.game3.battle_chrome']=chrome
 local hb={draw=function()native=native+1 end};package.loaded['src.core.game3.battle.healthbox']=hb
 local old=gen==3 and hb.draw or state.drawHUDs
 local undo=install(mod,Theme,function()return on end)
 local b={enemy={},player={},showEnemyHud=true,showPlayerHud=true,statusHUDVisible=function()return true end,
 growInScale=function()return false end,activeMon=function()return{}end,hudCleared=function()return false end}
 local function draw()if gen==3 then hb.draw(1,2)elseif gen==2 then state.drawEnemyHud(b)else state.drawHUDs(b,0)end end
 on=true;owns=false;local before=panels;draw();assert(panels>before,'standalone skin missing '..gen)
 on=false;before=panels;draw();assert(panels==before,'OFF changed native UI')
 on=true;owns=true;if gen<3 then draw();assert(panels==before,'projected HUD got duplicate native plate')end
 undo();assert((gen==3 and hb.draw or state.drawHUDs)==old,'uninstall lost original')
end
print('PASS standalone frames in 3 engines, OFF, optional stage ownership, uninstall')
