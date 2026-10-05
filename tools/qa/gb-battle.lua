return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local gen=require('src.core.GameVersion').generation()
 local update=game.update;game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 if gen==2 then
  game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'down'))
  local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'TOTODILE',15)}
  game.world:startBattle({wild=Mon.new(game.data,'SENTRET',10)})
 else
  if os.getenv('QA_WIDE')=='1' then game.save.options.battleLayout='wide' end
  U.teleport(game,'PALLET_TOWN',9,8,'down')
  game.save.party={require('src.pokemon.Pokemon').new(game.data,'PIKACHU',15)}
  game.overworld:pushBattle(require('src.battle.BattleState').newWild(game,'RATTATA',10))
 end
 local battle
 for i=1,800 do
  battle=game.stack:top()
  if battle and battle.phase=='menu'then break end
  U.tap(game,'a');U.wait(2)
 end
 assert(battle and battle.phase=='menu','battle never reached commands')
 local api=assert(game.mods.exports.MODERN_POKEMON_UI,'missing UI')
 local row
 for _,r in ipairs(R.call('ui.options.rows',function(_,base)return base end,game,{}))do
  if r.id=='MODERN_POKEMON_UI:modernBattleUI'then row=r end
 end
 assert(row,'missing toggle')
 if not api.enabled()then row.step(game,1)end
 U.wait(3);U.shot(game,os.getenv('SHOT_DIR')..'/modern.png')
 row.step(game,1);assert(not api.enabled());U.wait(3);U.shot(game,os.getenv('SHOT_DIR')..'/native.png')
 row.step(game,1);assert(api.enabled())

 U.tap(game,'a');U.wait(3)
 assert(battle.phase==(gen==1 and 'moveSelect' or 'moves'),'Fight did not open moves')
 U.shot(game,os.getenv('SHOT_DIR')..'/moves.png')
 U.tap(game,'b');U.wait(3);assert(battle.phase=='menu','move cancel lost menu')
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(8)
 U.shot(game,os.getenv('SHOT_DIR')..'/attack.png')
 for i=1,800 do if battle.phase=='menu' then break end;U.tap(game,'a');U.wait(2)end
 assert(battle.phase=='menu','attack did not return to command')
 U.shot(game,os.getenv('SHOT_DIR')..'/return.png')
 print('[modern GB PASS]',gen);love.event.quit()
end
