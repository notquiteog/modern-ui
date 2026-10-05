return function(game)
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local GV=require('src.core.GameVersion');local em=GV.get()=='emerald'
 game:_handleBootAction({action='new_game',start={map=em and 'EM_OLDALE_TOWN' or 'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib; require('src.mods.Runtime').emit('mod.options_changed',{mod='BATTLE_ART_VOXEL_FORK',key='battles',value=true}); V.require('ModernBattleUI').setting:sync(true);V.require('Gen3Integration').setLevel(3,game)
 local Party=require('src.core.game3.party');game.session.name='TESTER';game.session.party={};assert(Party.giveMon(game.session,6,35));game.session.party[1].moves={53,33};game.session.party[1].pp={15,35}
 local B=require('src.core.game3.battle');local Stage=V.require('Gen3Battle');U.wait(40)
 assert(B.start({playerParty=game.session.party,foe={species=6,level=35},wild=true,session=game.session}))
 local function command()for i=1,500 do if B._phase=='command'then return end;U.tap(game,'a');U.wait(2)end;error('command '..tostring(B._phase))end
 command();U.wait(20);assert(Stage.active);assert(Stage.frame.byId[0]and Stage.frame.byId[1]);assert(U.shot(game,dir..'/single.png'))

 local Runtime=require('src.mods.Runtime')
 local exports=assert(game.mods.exports.MODERN_POKEMON_UI,'Modern UI not loaded')
 assert(exports.enabled(),'modern preview must start enabled')
 assert(V.require('ModernBattleUI').enabled(),'stage did not discover optional provider')
 local row
 for _,r in ipairs(require('src.ui.game3.option_rows').build({game=game,session=game.session}))do if r.id=='MODERN_POKEMON_UI:modernBattleUI'then row=r end end
 assert(row,'native menu row missing');row.step({game=game},1)
 U.wait(8)
 assert(not exports.enabled()and not V.require('ModernBattleUI').enabled(),'OFF ignored')
 assert(U.shot(game,dir..'/native.png'))
 row.step({game=game},1)
 U.wait(8)
 assert(V.require('ModernBattleUI').enabled())
 assert(U.shot(game,dir..'/modern.png'))
 print('[modern-ui] PASS runtime provider discovery and ON/OFF')
 love.event.quit()
end
