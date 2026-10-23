-- Public options hook and registered GB-sized screen; no native menu patch.
package.loaded['src.core.GameVersion']={generation=function()return 3 end}
local emitted=0;package.loaded['src.mods.Runtime']={emit=function(name,p)assert(name=='mod.options_changed'and p.mod=='TEST');emitted=emitted+1 end}
local hooks,screens={},{};local saved={};local writes=0
local game={options={modOptions={TEST=saved}},mods={modOptions={TEST=saved}},writeOptions=function()writes=writes+1 end,input={wasPressed=function()return false end}}
local opened,constructed
local mod={id='TEST',read=function(_,path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end,options={get=function(_,key)if saved[key]~=nil then return saved[key]end;return false end},content={screens={register=function(_,id,def)assert(not screens[id]);screens[id]=def end}},hooks={wrap=function(_,name,fn)hooks[name]=fn end},ui={push=function(g,id)assert(g==game);opened=id end,ListMenu={new=function(g,title,items,opts)
 assert(g==game and title=='TEST MENU');constructed={game=g,items=items,index=1,update=function()end,close=function(self)self.closed=true end,onChoose=opts.onChoose};return constructed
end}}}
dofile('lib/InGameOptions.lua').install(mod,{{key='on',label='TEST OPTION',type='toggle',default=false}},'TEST MENU')
assert(hooks['ui.options.rows']and screens['TEST:options'])
local native,extra={id='native',label='NATIVE'},{}
local function nextRows(g,rows,arg)assert(g==game and arg==extra);return rows end
local rows=hooks['ui.options.rows'](nextRows,game,{native,{id='cancel',label='CANCEL'}},extra)
assert(rows[1]==native and rows[2].id=='TEST:settings'and rows[3].id=='cancel'and rows[2].value()=='1 OPTIONS')
assert(#hooks['ui.options.rows'](nextRows,game,rows,extra)==3,'duplicate category')
rows[2].activate(game);assert(opened=='TEST:options')
local menu=screens[opened].new(game);assert(menu.gbaCanvas==true and menu.rows==7,'native artwork uses full240x160, seven rows')
assert(menu.items[1].right=='OFF');menu.onChoose(menu.items[1],menu)
assert(saved.on==true and menu.items[1].right=='ON'and emitted==1 and writes==1)
game.input.wasPressed=function(_,key)return key=='left'end;menu:update(0)
assert(saved.on==false and menu.items[1].right=='OFF'and emitted==2 and writes==2)
menu.onChoose(menu.items[2],menu);assert(menu.closed)
hooks['core.quit_to_launcher'](function()end)
assert(#hooks['ui.options.rows'](nextRows,game,{native},extra)==1)
assert(package.loaded['src.ui.game3.option_rows']==nil,'private native options bypass returned')
print('PASS public native options identity/arguments, owner grouping, registered native240x160 screen, live toggle/persistence/event, A/left/CANCEL and inert unload')
