local noop=function()end;local seen={};local released=0;local enabled=true;local current
local source={getDimensions=function()return 80,56 end}
local K={image=function(path)return source end};local originalImage=K.image
local C={drawBg=noop,manifest=function()return{panels={large={variants={['3']='base',['7']='selected'}}}}end}
C.drawParty=function()seen[#seen+1]=K.image('base');seen[#seen+1]=K.image('selected');seen[#seen+1]=K.image('icon');return 42 end
local originalDraw=C.drawParty
package.loaded['src.core.GameVersion']={generation=function()return 3 end,get=function()return'ruby'end}
package.loaded['src.ui.game3.rs.party_chrome']=C;package.loaded['src.ui.game3.rse.scene_kit']=K
love={graphics={getCanvas=function()return current end,setCanvas=function(v)current=v end,push=noop,pop=noop,origin=noop,setShader=noop,setScissor=noop,setDepthMode=noop,clear=noop,setColor=noop,setLineWidth=noop,rectangle=noop,
newCanvas=function()return{setFilter=noop,release=function()released=released+1 end}end}}
local undo=assert(loadfile('lib/RSPartyCards.lua'))()({}, {partyCard=noop,paper={}},function()return enabled end)
assert(K.image('base')==source,'scoped substitution leaked')
assert(C.drawParty()==42);assert(seen[1]~=source and seen[2]~=source and seen[3]==source)
local cached=seen[1];seen={};C.drawParty();assert(seen[1]==cached)
enabled=false;seen={};C.drawParty();assert(seen[1]==source and seen[2]==source)
undo();assert(K.image==originalImage and C.drawParty==originalDraw and released==2)
print('PASS RS party native draw delegation, panel-only cache, OFF/unload and scope isolation')
