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
 local P=require('src.core.game3.party');local S=require('src.ui.game3.summary_menu')
 game.session.party={};for _,id in ipairs({25,6})do assert(P.giveMon(game.session,id,25))end
 local mon=game.session.party[1];local Pokemon=require('src.core.game3.pokemon');Pokemon.replaceMove(mon,1,15)
 local choice='unset';S.openMenu(game.session.party,1,{session=game.session,mode='select_move',moveToLearn=85,onSelectMove=function(slot)choice=slot end})
 U.wait(90);U.tap(game,'a');U.wait(45);assert(choice=='unset'and S.isOpen(),'HM should not be forgettable')
 U.shot(game,dir..'/summary-hm-notice.png')
 for i=1,3 do if not S.isOpen()then break end;U.tap(game,'b');U.wait(60)end
 assert(choice==nil and not S.isOpen(),'HM screen cancel callback lost');print('[PASS native HM refusal and cancel]');love.event.quit()
end
