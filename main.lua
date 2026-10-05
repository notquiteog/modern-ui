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
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)undoPanels();undoCommands();undo();return next(...)end)
end
