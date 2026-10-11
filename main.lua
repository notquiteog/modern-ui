return function(mod)
 local Theme=assert((loadstring or load)(assert(mod:read('lib/Theme.lua')),'@modern-ui/Theme'))()
 local schema={{key='modernBattleUI',label='MODERN BATTLE UI',type='toggle',default=true},{key='modernInterfaceUI',label='MODERN MENU PANELS',type='toggle',default=true}}
 mod.options:define(schema)
 local menu=assert((loadstring or load)(assert(mod:read('lib/InGameOptions.lua')),'@modern-ui/options'))()
 menu.install(mod,schema,'MODERN UI')
 local function enabled()return mod.options:get('modernBattleUI')~=false end
 mod.exports.apiVersion=1
 mod.exports.enabled=enabled
 mod.exports.battleTheme=Theme
 local install=assert((loadstring or load)(assert(mod:read('lib/NativeFrames.lua')),'@modern-ui/NativeFrames'))()
 local undo=install(mod,Theme,enabled)
 local commands=assert((loadstring or load)(assert(mod:read('lib/NativeCommands.lua')),'@modern-ui/NativeCommands'))()
 local undoCommands=commands(mod,Theme,enabled)
 local panels=assert((loadstring or load)(assert(mod:read('lib/NativePanels.lua')),'@modern-ui/NativePanels'))()
 local undoPanels=panels(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local party=assert((loadstring or load)(assert(mod:read('lib/PartyCards.lua')),'@modern-ui/PartyCards'))()
 local undoParty=party(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local gbParty=assert((loadstring or load)(assert(mod:read('lib/GBParty.lua')),'@modern-ui/GBParty'))()
 local undoGBParty=gbParty(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local summary=assert((loadstring or load)(assert(mod:read('lib/GBSummary.lua')),'@modern-ui/GBSummary'))()
 local undoSummary=summary(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local storage=assert((loadstring or load)(assert(mod:read('lib/GBStorage.lua')),'@modern-ui/GBStorage'))()
 local undoStorage=storage(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local gb1storage=assert((loadstring or load)(assert(mod:read('lib/GB1Storage.lua')),'@modern-ui/GB1Storage'))()
 local undoGB1Storage=gb1storage(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local rsParty=assert((loadstring or load)(assert(mod:read('lib/RSPartyCards.lua')),'@modern-ui/RSPartyCards'))()
 local undoRSParty=rsParty(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local gbaStorage=assert((loadstring or load)(assert(mod:read('lib/GBAStorageCards.lua')),'@modern-ui/GBAStorageCards'))()
 local undoGBAStorage=gbaStorage(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 local gbaSummary=assert((loadstring or load)(assert(mod:read('lib/GBASummary.lua')),'@modern-ui/GBASummary'))()
 local undoGBASummary=gbaSummary(mod,Theme,function()return mod.options:get('modernInterfaceUI')~=false end)
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)undoSummary();undoStorage();undoGB1Storage();undoRSParty();undoGBAStorage();undoGBASummary();undoGBParty();undoParty();undoPanels();undoCommands();undo();return next(...)end)
end
