local noop=function()end;local native=0;local rendered=0;local enabled=true
local C={ensure=noop};for _,k in ipairs({'drawBackground','drawInterfaceFrame','drawWaveforms','drawTopButtons','textColors'})do C[k]=function()native=native+1;return'native'end end
local saved={};for k,v in pairs(C)do saved[k]=v end
local B={open=true};package.loaded['src.core.GameVersion']={generation=function()return 3 end,get=function()return'emerald'end}
package.loaded['src.ui.game3.pc_chrome']=C;package.loaded['src.ui.game3.box_storage_ui']=B
love={graphics={push=noop,pop=noop,setColor=noop,setLineWidth=noop,rectangle=function()rendered=rendered+1 end}}
local undo=assert(loadfile('lib/GBAStorageCards.lua'))()({}, {panel=noop,text=noop,partyCard=noop,ink={.2,.2,.2,1}},function()return enabled end)
local loaded=0;local img={}
 package.loaded['src.render.Assets']={image=function(path)assert(path=='data/generated/native-bar.png');loaded=loaded+1;return img end}
 C._manifest={pcScreenEffect={bar={png='data/generated/native-bar.png'}}}
 C.ensure();C.ensure();assert(loaded==1 and C._pcScreenBarImg==img)
 C.drawBackground();C.drawInterfaceFrame();C.drawTopButtons('party');assert(native==0 and rendered>0)
local a,b,c=C.textColors();assert(a.fg[1]==.2 and b.fg[3]==.61 and c.fg[1]==.63)
enabled=false;assert(C.textColors()=='native');enabled=true;B.open=false;C.drawBackground();assert(native==2)
undo();for k,v in pairs(saved)do assert(C[k]==v)end
print('PASS GBA storage scoped palettes, OFF, other screens and unload')
