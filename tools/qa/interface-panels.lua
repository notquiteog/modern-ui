return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 love.joystick.getJoysticks=function()return{}end;love.joystick.getJoystickCount=function()return 0 end
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local gen=require('src.core.GameVersion').generation();local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 if gen==3 then
 game:_handleBootAction({action='new_game',start={map=require('src.core.GameVersion').get()=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local sp=require('src.core.game3.scripting.space');sp.runOnFrame=function()end;local vm=sp.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset()
 elseif gen==2 then game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'))
 else U.teleport(game,'PALLET_TOWN',9,8,'down')end
 U.wait(45)
 local api=assert(game.mods.exports.MODERN_POKEMON_UI.interface);local row
 local rows=gen==3 and require('src.ui.game3.option_rows').build({game=game,session=game.session})or R.call('ui.options.rows',function(_,b)return b end,game,{})
 local ctx=gen==3 and {game=game}or game
 for _,r in ipairs(rows)do if r.id=='MODERN_POKEMON_UI:modernInterfaceUI'then row=r end end
 assert(row,'panel option absent');if not api.enabled()then row.step(ctx,1)end
 if gen==3 then require('src.ui.game3.start_menu').show({session=game.session,game=game})else U.tap(game,'start')end
 U.wait(15);U.shot(game,dir..'/pause-modern.png');row.step(ctx,1);assert(not api.enabled());U.wait(3);U.shot(game,dir..'/pause-native.png');row.step(ctx,1)
 if gen==3 then require('src.ui.game3.start_menu').close();U.wait(10);require('src.ui.game3.message').show('Hello! A clear message for your next adventure.')else U.tap(game,'b');game.stack:push(require('src.render.TextBox').new(game,'Hello! A clear message\nfor your next adventure.'))end
 U.wait(130);if gen==3 then assert(require('src.ui.game3.message').isOpen(),'native dialogue closed before capture')end;U.shot(game,dir..'/dialogue-modern.png');row.step(ctx,1);U.wait(3);U.shot(game,dir..'/dialogue-native.png');row.step(ctx,1)
 print('[PASS panel setting ON/OFF and native pause/dialogue]');love.event.quit()
end
