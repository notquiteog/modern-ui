local install=assert(loadfile('lib/PartyRoster.lua'))()
love={graphics={getDimensions=function()return 960,640 end}}
local calls=0;local pressed
local S={open=true,mode='list',cursor=1,_party={{},{},{},{},{},{}},draw=function()end,
 handleInput=function(input)calls=calls+1;pressed=input:wasPressed('a')end}
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
package.loaded['src.ui.game3.party_menu']=S
package.loaded['src.core.game3.pokemon']={}
package.loaded['src.core.game3.rom_text']={}
package.loaded['src.ui.game3.frlg_font']={}
package.loaded['src.ui.game3.summary_menu']={isOpen=function()return false end}
local on=true;local original=S.handleInput;local undo=install({hooks={wrap=function()end}}, {viewport=function(w,h)return 0,0,w,h end},function()return on end)
local function key(k,a)S.handleInput({wasPressed=function(_,v)return v==k or(a and v=='a')end})end
key('right',true);assert(S.cursor==2 and pressed,'grid right or simultaneous confirmation lost')
key('down');assert(S.cursor==4);key('down');assert(S.cursor==6);key('down');assert(S.cursor==7)
key('up');assert(S.cursor==6);key('left');assert(S.cursor==5)
S._party={{},{},{}};S.cursor=3;key('right');assert(S.cursor==3,'empty card selected');key('down');assert(S.cursor==7)
for _,mode in ipairs({'action','message','battle_switch','use','summary'})do
 S.mode=mode;S.cursor=1;key('down');assert(S.cursor==1,'special workflow navigation changed: '..mode)
end
S.mode='list';on=false;key('down');assert(S.cursor==1)
on=true;S._hpAnim={};key('down');assert(S.cursor==1);S._hpAnim=nil
local retained=S.handleInput;undo();assert(S.handleInput==original)
retained({wasPressed=function()return false end});assert(calls>0)
print('PASS party grid, cancel, empty slots, simultaneous confirmation, native modal/HP/OFF/unload ownership')
