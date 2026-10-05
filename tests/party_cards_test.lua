local install=assert(loadfile('lib/PartyCards.lua'))()
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
local Party={open=true};package.loaded['src.ui.game3.party_menu']=Party
package.loaded['src.core.game3.display']={W=240,H=160}
local native,draws=0,0;local f=function()native=native+1 end
local C={drawBg=f,drawSlot=f};package.loaded['src.ui.game3.party_chrome']=C
love={graphics={push=function()end,pop=function()end,setColor=function()end,rectangle=function()draws=draws+1 end}}
local cards={};local on=true;local undo=install({}, {partyCard=function(...)cards[#cards+1]={...}end},function()return on end)
C.drawSlot('main',1,2,true,false);local p=cards[1];assert(p[1]==8 and p[2]==16 and p[3]==80 and p[4]==56 and p[5]);assert(draws==1,'HP track absent')
C.drawSlot('wide',10,3,false,true);assert(#cards==2 and draws==1,'egg/description track painted')
for _,state in ipairs({'off','closed','summary','delegate'})do
 on=state~='off';Party.open=state~='closed';Party.mode=state=='summary'and'summary'or nil;C._nativeDelegate=state=='delegate'and{}or nil
 local n=native;C.drawSlot('main',1,2,true);assert(native==n+1,'native fallback '..state)
end
on=true;Party.open=true;Party.mode=nil;C._nativeDelegate=nil;local retained=C.drawSlot;undo();local n=native;retained('main',1,2,true);assert(native==n+1,'retained wrapper active after unload')
assert(C.drawSlot==f,'native owner not restored')
print('PASS party slot bounds, HP/egg track, native/OFF/delegate/summary/unload fallback')
