local install=assert(loadfile('lib/NativePanels.lua'))()
local enabled=true;local native,panels,pushes,pops=0,{},0,0
love={graphics={push=function()pushes=pushes+1 end,pop=function()pops=pops+1 end}}
local theme={interfacePanel=function(...)panels[#panels+1]={...}end}
for gen=1,3 do
 package.loaded['src.core.GameVersion']={generation=function()return gen end}
 local f=function()native=native+1;return 'native'end
 local Font={drawBox=f};local C={stdFrame=f,fixedStdFrame=f,userFrame=f,dialogueFrame=f,dialogueWindow=function()return 2,15,26,4 end}
 package.loaded['src.render.Font']=Font;package.loaded['src.ui.game3.chrome']=C
 local mod={exports={}};enabled=true;local undo=install(mod,theme,function()return enabled end)
 if gen<3 then Font.drawBox(1,2,10,5)else C.stdFrame(1,2,10,5);C.dialogueFrame()end
 local p=panels[#panels];assert(p[5]==(gen<3),'generation palette')
 if gen==3 then assert(p[1]==8 and p[2]==112 and p[3]==224 and p[4]==48,'dialogue bounds')end
 enabled=false;local n=native;assert((gen<3 and Font.drawBox(1,2,10,5)or C.stdFrame(1,2,10,5))=='native'and native==n+1,'OFF native fallback')
 assert(not mod.exports.interface.drawPanel(0,0,20,20),'OFF optional integration')
 enabled=true;assert(mod.exports.interface.drawPanel(0,0,20,20,'quest'),'public optional panel')
 local retained=gen<3 and Font.drawBox or C.stdFrame;undo();n=native;retained(1,2,10,5);assert(native==n+1,'retained wrapper unload')
 assert(not mod.exports.interface.enabled(),'unloaded API disabled')
end
assert(pushes==pops,'graphics state restored')
print('PASS shared panels across generations, bounds, optional API, OFF and unload')
