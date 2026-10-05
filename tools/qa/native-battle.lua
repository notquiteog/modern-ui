return function(game)
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local GV=require('src.core.GameVersion');local em=GV.get()=='emerald'
 game:_handleBootAction({action='new_game',start={map=em and 'EM_OLDALE_TOWN' or 'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local Party=require('src.core.game3.party');game.session.name='TESTER';game.session.party={};assert(Party.giveMon(game.session,6,35));game.session.party[1].moves={53,33};game.session.party[1].pp={15,35}
 local B=require('src.core.game3.battle');U.wait(40)
 assert(B.start({playerParty=game.session.party,foe={species=6,level=35},wild=true,session=game.session}))
 local function command()for i=1,500 do if B._phase=='command'then return end;U.tap(game,'a');U.wait(2)end;error('command '..tostring(B._phase))end
 command();U.wait(20);assert(U.shot(game,dir..'/single.png'))

 local Runtime=require('src.mods.Runtime')
 assert(not game.mods.exports.BATTLE_ART_VOXEL_FORK,'standalone must not load voxel')
 local exports=assert(game.mods.exports.MODERN_POKEMON_UI,'Modern UI not loaded')
 assert(exports.enabled(),'modern preview must start enabled')

 local row
 for _,r in ipairs(require('src.ui.game3.option_rows').build({game=game,session=game.session}))do if r.id=='MODERN_POKEMON_UI:modernBattleUI'then row=r end end
 assert(row,'native menu row missing');row.step({game=game},1)
 U.wait(8)
 assert(not exports.enabled(),'OFF ignored')
 assert(U.shot(game,dir..'/native.png'))
 row.step({game=game},1)
 U.wait(8)
 assert(exports.enabled())
 assert(U.shot(game,dir..'/modern.png'))

 local Ui=require('src.core.game3.battle.ui')
 U.tap(game,'a');U.wait(4);assert(Ui._mode=='moves','Fight did not open moves')
 U.shot(game,dir..'/moves.png')
 U.tap(game,'b');U.wait(3);assert(Ui._mode=='menu','move cancel lost command mode')
 U.tap(game,'right');U.wait(3);assert(Ui._menuIndex==3,'PKMN placement disagrees with input')
 U.tap(game,'left');U.wait(3);assert(Ui._menuIndex==1)
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(12)
 assert(Ui._mode~='menu' and Ui._mode~='moves','attack did not leave selection')
 U.shot(game,dir..'/attack.png')
 command();U.wait(4);U.shot(game,dir..'/return.png')
 print('[modern-ui] PASS move/cancel, spatial input, attack/return')
 print('[modern-ui] PASS runtime provider discovery and ON/OFF')
 love.event.quit()
end
