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

 local Mon=require(gen==2 and'src.battle.gen2.Mon'or'src.pokemon.Pokemon')
 game.save.party={Mon.new(game.data,'PIKACHU',25),Mon.new(game.data,'CHARIZARD',30)}
 local S=require(gen==2 and'src.ui.gen2.SummaryMenu'or'src.ui.SummaryMenu')
 local summary=gen==2 and S.new(game,{party=game.save.party,index=1,onClose=function()game.stack:pop()end})or S.new(game,game.save.party[1])
 game.stack:push(summary);U.wait(20);U.shot(game,dir..'/summary-status.png')
 U.tap(game,gen==2 and'right'or'a');U.wait(20);U.shot(game,dir..'/summary-moves.png')
 if gen==2 then
  U.tap(game,'right');U.wait(20);U.shot(game,dir..'/summary-trainer.png')
  U.tap(game,'left');U.wait(20);assert(summary.page==2);U.tap(game,'select');U.wait(20);assert(summary.moveDetail);U.shot(game,dir..'/summary-move-detail.png')
  U.tap(game,'a');U.wait(4);assert(summary.swapFrom);U.tap(game,'down');U.tap(game,'a');U.wait(10);assert(not summary.swapFrom)
 end
 for i=1,5 do if game.stack:top()~=summary then break end;U.tap(game,'b');U.wait(20)end
 assert(game.stack:top()~=summary,'summary did not return')
 if gen==2 then
  local Box=require('src.ui.gen2.BoxMenu');local pc=Box.new(game,{mode='deposit',onClose=function()game.stack:pop()end})
  game.stack:push(pc);U.wait(10);U.shot(game,dir..'/pc-list.png')
  U.tap(game,'a');U.wait(10);U.shot(game,dir..'/pc-actions.png')
  U.tap(game,'a');U.wait(30);assert(#game.save.party==1,'native deposit failed');U.shot(game,dir..'/pc-deposited.png')
  U.wait(240)
  for i=1,5 do if game.stack:top()~=pc then break end;U.tap(game,'b');U.wait(20)end;assert(game.stack:top()~=pc)
 end
 print('[PASS modern GB summary pages and PC actions]');love.event.quit()
end
