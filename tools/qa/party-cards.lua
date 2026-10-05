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

 assert(gen==3)
 local P=require('src.core.game3.party');local Menu=require('src.ui.game3.party_menu')
 game.session.party={};for _,id in ipairs({25,6,19,7,1,39})do assert(P.giveMon(game.session,id,25))end
 game.session.party[2].hp=0;game.session.party[3].hp=3;game.session.party[4].status=8
 Menu.show(game.session.party,nil,{session=game.session});U.wait(40)
 U.shot(game,dir..'/party-modern.png');row.step(ctx,1);assert(not api.enabled());U.wait(3);U.shot(game,dir..'/party-native.png');row.step(ctx,1)
 U.tap(game,'right');U.wait(8);assert(Menu.cursor==2,'right navigation');U.shot(game,dir..'/party-selected.png')
 U.tap(game,'a');U.wait(12);U.shot(game,dir..'/party-actions.png')
 U.tap(game,'a');U.wait(60);assert(require('src.ui.game3.summary_menu').isOpen(),'summary not opened');U.shot(game,dir..'/party-summary.png')
 U.tap(game,'b');U.wait(45);assert(Menu.isOpen(),'party lost after summary');U.tap(game,'b');U.wait(20);assert(not Menu.isOpen(),'party cancel lost')
 print('[PASS party ON/OFF, selection, summary and return]');love.event.quit()
end
