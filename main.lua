return function(mod)
 local Theme=assert((loadstring or load)(assert(mod:read('lib/Theme.lua')),'@modern-ui/Theme'))()
 local schema={{key='modernBattleUI',label='MODERN BATTLE UI',type='toggle',default=true}}
 mod.options:define(schema)
 local menu=assert((loadstring or load)(assert(mod:read('lib/InGameOptions.lua')),'@modern-ui/options'))()
 menu.install(mod,schema,'MODERN UI')
 local function enabled()return mod.options:get('modernBattleUI')~=false end
 mod.exports.apiVersion=1
 mod.exports.enabled=enabled
 mod.exports.battleTheme=Theme
 local install=assert((loadstring or load)(assert(mod:read('lib/NativeFrames.lua')),'@modern-ui/NativeFrames'))()
 local undo=install(mod,Theme,enabled)
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)undo();return next(...)end)
end
