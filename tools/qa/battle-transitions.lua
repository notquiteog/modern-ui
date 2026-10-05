-- Isolated Gen3 QA profile. Native trainer doubles are supported by the engine;
-- wild doubles remain an optional companion's separate gameplay responsibility.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 -- A user's connected controller must not steer the isolated driver or its camera.
 print('[QA] physical pads excluded',#love.joystick.getJoysticks())
 love.joystick.getJoysticks=function()return {}end;love.joystick.getJoystickCount=function()return 0 end
 for _,event in ipairs({'gamepadpressed','gamepadreleased','gamepadaxis','joystickpressed','joystickreleased','joystickaxis','joystickhat'})do
  love[event]=function()end
 end
 game.input:reset()
 local R=require('src.mods.Runtime');local update=game.update
 game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 local em=require('src.core.GameVersion').get()=='emerald'
 game:_handleBootAction({action='new_game',start={map=em and 'EM_OLDALE_TOWN' or 'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK
 if V then
  V=V.lib;R.emit('mod.options_changed',{mod='BATTLE_ART_VOXEL_FORK',key='battles',value=true})
  V.require('ModernBattleUI').setting:sync(true);V.require('Gen3Integration').setLevel(3,game)
 end
 local Party=require('src.core.game3.party');game.session.name='TESTER';game.session.party={}
 assert(Party.giveMon(game.session,6,35));assert(Party.giveMon(game.session,9,35))
 for _,mon in ipairs(game.session.party)do mon.moves={33,45};mon.pp={35,40};mon.maxPp={35,40}end
 local B=require('src.core.game3.battle');local Ui=require('src.core.game3.battle.ui')
 U.wait(40)
 assert(B.start({playerParty=game.session.party,foe={party={{species=3,level=35},{species=9,level=35}}},
  trainerClass=1,trainerClassName='TRAINER',trainerName='QA',double=true,wild=false,session=game.session}))
 local function settle(mode)
  for i=1,800 do if B._phase=='command' and Ui._mode==mode then U.wait(3);return end;U.tap(game,'a');U.wait(2)end
  error('command not reached '..tostring(B._phase)..' '..tostring(Ui._mode))
 end
 settle('menu');assert(B._st.double and B._st.battlers[2]and B._st.battlers[3])
 U.shot(game,dir..'/double-command.png')
 U.tap(game,'right');U.wait(3);assert(Ui._menuIndex==3,'right does not select PKMN')
 U.tap(game,'a');U.wait(40)
 local PM=require('src.ui.game3.party_menu');assert(PM.isOpen(),'PKMN did not open native party')
 U.shot(game,dir..'/party.png');U.tap(game,'b');U.wait(40)
 assert(not PM.isOpen(),'party cancel failed');assert(Ui._mode=='menu','party cancel lost command menu')
 -- Return to Fight from the retained Pokemon slot; visual grid is transposed.
 U.tap(game,'left');U.wait(3);assert(Ui._menuIndex==1)
 U.tap(game,'down');U.wait(3);assert(Ui._menuIndex==2,'down does not select Items')
 U.tap(game,'a');U.wait(40)
 local Bag=require('src.ui.game3.bag_menu');assert(Bag.isOpen(),'Items did not open native bag')
 U.shot(game,dir..'/bag.png');U.tap(game,'b');U.wait(40)
 assert(not Bag.isOpen(),'bag cancel failed');assert(Ui._mode=='menu')
 U.tap(game,'up');U.wait(3);assert(Ui._menuIndex==1)
 U.tap(game,'a');U.wait(3);assert(Ui._mode=='moves');U.shot(game,dir..'/double-moves.png')
 U.tap(game,'a');U.wait(3);assert(Ui._mode=='target','single-target move needs native target selection')
 local first=Ui.targetCursor();U.tap(game,'right');U.wait(3)
 assert(Ui.targetCursor()~=first,'native target cursor did not change')
 U.shot(game,dir..'/double-target.png')
 U.tap(game,'b');U.wait(3);assert(Ui._mode=='moves','target cancel failed')
 U.tap(game,'b');U.wait(3);assert(Ui._mode=='menu','move cancel failed')
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(5)
 for i=1,90 do if Ui._mode=='menu' and Ui.activeBattler()==2 then break end;U.wait(1)end
 assert(Ui._mode=='menu' and Ui.activeBattler()==2,'second battler never received commands: '..tostring(Ui._mode)..' '..tostring(Ui.activeBattler())..' '..tostring(B._phase))
 U.shot(game,dir..'/second-battler.png')
 U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(3);U.tap(game,'a');U.wait(40)
 assert(Ui._mode~='menu' and Ui._mode~='moves','doubles turn did not start')
 U.shot(game,dir..'/double-attack.png');settle('menu');U.shot(game,dir..'/double-return.png')
 print('[modern-ui] PASS native trainer doubles: party, bag, target/cancel, partner commands, turn/return')
 love.event.quit()
end
