return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 love.joystick.getJoysticks=function()return{}end;love.joystick.getJoystickCount=function()return 0 end
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local gen=require('src.core.GameVersion').generation();local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 if gen==3 then
 local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[require('src.core.GameVersion').get()]
 game:_handleBootAction({action='new_game',start={map=prefix and prefix..'OLDALE_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local sp=require('src.core.game3.scripting.space');sp.runOnFrame=function()end;local vm=sp.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset()
 elseif gen==2 then game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'))
 else U.teleport(game,'PALLET_TOWN',9,8,'down')end
 U.wait(45)
 local api=assert(game.mods.exports.MODERN_POKEMON_UI.interface);local row
 local ctx={game=game}
 local version=require('src.core.GameVersion').get()
 if version=='ruby'or version=='sapphire'then
  -- These isolated QA caches predate native options string extraction. The
  -- party test toggles only the mod option; native party input is unchanged.
  row={step=function()
   local value=not api.enabled();local opts=(game.save and game.save.options)or game.options
   opts.modOptions=opts.modOptions or{};opts.modOptions.MODERN_POKEMON_UI=opts.modOptions.MODERN_POKEMON_UI or{}
   opts.modOptions.MODERN_POKEMON_UI.modernInterfaceUI=value
   game.mods.modOptions.MODERN_POKEMON_UI=game.mods.modOptions.MODERN_POKEMON_UI or{}
   game.mods.modOptions.MODERN_POKEMON_UI.modernInterfaceUI=value
   R.emit('mod.options_changed',{mod='MODERN_POKEMON_UI',key='modernInterfaceUI',value=value})
  end}
 else
  for _,r in ipairs(require('src.ui.game3.option_rows').build({game=game,session=game.session}))do if r.id=='MODERN_POKEMON_UI:modernInterfaceUI'then row=r end end
 end
 assert(row,'panel option absent');if not api.enabled()then row.step(ctx,1)end

 assert(gen==3)
 local P=require('src.core.game3.party');local Storage=require('src.core.game3.storage');local Box=require('src.ui.game3.box_storage_ui')
 game.session.party={};for _,id in ipairs({25,6,7})do assert(P.giveMon(game.session,id,25))end
 local storage=Storage.ensure(game.session);storage.currentBox=1;storage.boxes[1].mons={}
 assert(Storage.deposit(game.session,3,1,1));assert(#game.session.party==2)
 Box.show({session=game.session,subMode='withdraw'});U.wait(90);U.shot(game,dir..'/storage-modern.png')
 row.step(ctx,1);U.wait(3);U.shot(game,dir..'/storage-native.png');row.step(ctx,1)
 U.tap(game,'a');U.wait(20);U.shot(game,dir..'/storage-actions.png')
 U.tap(game,'a');U.wait(240);assert(#game.session.party==3,'native withdrawal failed');U.shot(game,dir..'/storage-withdrawn.png')
 for i=1,5 do if not Box.open then break end;U.tap(game,'b');U.wait(60);U.tap(game,'a');U.wait(60)end
 assert(not Box.open,'storage return failed');print('[PASS GBA storage ON/OFF and real withdrawal/return]');love.event.quit()
end
