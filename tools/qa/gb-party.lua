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

 local Party=require(gen==2 and'src.ui.gen2.PartyMenu'or'src.ui.PartyMenu')
 local Mon=require(gen==2 and'src.battle.gen2.Mon'or'src.pokemon.Pokemon');game.save.party={}
 for _,id in ipairs({'PIKACHU','CHARIZARD','RATTATA','SQUIRTLE','BULBASAUR','JIGGLYPUFF'})do table.insert(game.save.party,Mon.new(game.data,id,25))end
 game.save.party[2].hp=0;game.save.party[3].hp=3
 local menu=Party.new(game,{submenu=true,onCancel=function()game.stack:pop()end});game.stack:push(menu);U.wait(15);U.shot(game,dir..'/roster-modern.png')
 row.step(ctx,1);U.wait(2);U.shot(game,dir..'/roster-native.png');row.step(ctx,1)
 local old=menu.index;U.tap(game,'down');U.wait(8);assert(menu.index~=old,'native down ignored');U.shot(game,dir..'/roster-selected.png')
 U.tap(game,'a');U.wait(8);assert(menu.submenu,'native actions absent');U.shot(game,dir..'/roster-actions.png')
 U.tap(game,'a');U.wait(30);U.shot(game,dir..'/roster-summary.png')
 for i=1,5 do if game.stack:top()==menu then break end;U.tap(game,'b');U.wait(30)end;assert(game.stack:top()==menu,'summary return lost party')
 if menu.submenu then U.tap(game,'b');U.wait(8)end
 U.tap(game,'a');U.wait(8);U.tap(game,'down');U.tap(game,'a');U.wait(8)
 assert(menu.switchFrom or menu.swapFrom,'native switch choice absent');U.shot(game,dir..'/roster-switch.png')
 local selected=menu.index;local mon=game.save.party[selected];U.tap(game,'down');U.tap(game,'a');U.wait(70)
 assert(game.save.party[selected]~=mon,'native reorder did not finish');U.shot(game,dir..'/roster-reordered.png')
 if gen==2 then for i=1,8 do if menu:isCancel()then break end;U.tap(game,'down')end;assert(menu:isCancel());U.shot(game,dir..'/roster-cancel.png')end
 U.tap(game,'b');U.wait(15);assert(game.stack:top()~=menu,'native back did not close')
 print('[PASS GB party selection and actions]');love.event.quit()
end
