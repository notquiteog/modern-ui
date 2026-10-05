local install=assert(loadfile('lib/NativeCommands.lua'))()
for gen=1,3 do
 local on,owned,draws,native=true,false,0,0
 local hooks={};local current;local wideSuppressed,wideThrow
 local g=setmetatable({getDimensions=function()return 1024,768 end,getCanvas=function()return {}end,
 newCanvas=function()return {setFilter=function()end}end},{__index=function()return function()end end})
 love={graphics=g}
 local mod={find=function()return {exports={battlePresentation={nativeHudOwned=function()return owned end}}}end,
 hooks={wrap=function(_,name,fn)hooks[name]=fn end}}
 local Theme={scale=function()return 3 end,commandHub=function()end,button=function()draws=draws+1 end,text=function()end}
 local state={drawBottom=function()native=native+1 end,drawTextArea=function()native=native+1 end}
 package.loaded['src.core.GameVersion']={generation=function()return gen end}
 package.loaded['src.core.Strings']=function(v)return v end
 package.loaded['src.battle.WideBattle']={draw=function(self)native=native+1;wideSuppressed=not self:bottomUIVisible();if wideThrow then error('wide draw failure')end end}
 package.loaded['src.ui.gen2.BattleState']=state;package.loaded['src.battle.BattleState']=state
 local chrome={drawPanel=function()native=native+1 end}
 local b={_phase='command',_st={}}
 local input
 local ui={_mode='menu',_menuIndex=1,draw=function()chrome.drawPanel('menu')end,
 handleInput=function(keys)input=keys:wasPressed('right')end}
 package.loaded['src.core.game3.battle.ui']=ui;package.loaded['src.core.game3.battle']=b
 package.loaded['src.ui.game3.battle_chrome']=chrome
 local overlay=false
 if gen==3 then
  package.loaded['src.ui.game3.party_menu']={isOpen=function()return overlay end}
  -- Mirror the real sandbox: require resolves public modules but package.loaded is empty.
  setfenv(install,setmetatable({package={loaded={}}},{__index=_G}))
 end
 local undo=install(mod,Theme,function()return on end)
 local s={phase='menu',menuIndex=1,bottomUIVisible=function()return true end,
 menuLabels=function()return {'FIGHT','PKMN','PACK','RUN'}end}
 current=s;local game={stack={top=function()return current end}}
 local function frame()
  if gen==3 then ui.draw()else state[gen==1 and 'drawTextArea' or 'drawBottom'](s)end
  hooks['render.hud'](function()end,game)
 end
 frame();assert(draws==4,'missing commands '..gen)
 if gen==3 then overlay=true;frame();assert(draws==4,'native Party screen received commands through sandbox');overlay=false;ui.draw()end
 if gen==1 then
  local Wide=package.loaded['src.battle.WideBattle'];local visibility=s.bottomUIVisible
  Wide.draw(s);assert(wideSuppressed and s.bottomUIVisible==visibility,'wide commands or visibility restoration missing')
  wideThrow=true;assert(not pcall(Wide.draw,s) and s.bottomUIVisible==visibility,'wide failure leaked visibility override');wideThrow=false
 end
 if gen==3 then
  ui.handleInput({wasPressed=function(_,key)return key=='down'end});assert(input,'Gen3 native index not transposed')
 end
 on=false;frame();assert(draws==4,'OFF still paints')
 on=true;owned=true;frame();assert(draws==4,'stage owns duplicate commands')
 owned=false;s.phase='messages';ui._mode='none';b._phase='turn';frame();assert(draws==4,'stale commands during animation')
 s.phase='menu';ui._mode='menu';b._phase='command';frame();assert(draws==8)
 undo();frame();assert(draws==8,'unloaded wrapper still paints')
 assert(native>0,'native fallback missing')
end
print('PASS commands in all engines, native input mapping, OFF/stage ownership, attack transition, unload')
