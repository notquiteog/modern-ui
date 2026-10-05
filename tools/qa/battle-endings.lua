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
 assert(Party.giveMon(game.session,6,100))
 local mon=game.session.party[1];mon.moves={53};mon.pp={15};mon.maxPp={15}
 local B=require('src.core.game3.battle');local Ui=require('src.core.game3.battle.ui')
 U.wait(40)
 local function start()
  assert(B.start({playerParty=game.session.party,foe={species=19,level=2},wild=true,session=game.session}))
  for i=1,800 do if B._phase=='command' and Ui._mode=='menu'then return end;U.tap(game,'a');U.wait(2)end
  error('battle never reached commands')
 end
 local function finish(label)
  local shots={}
  for i=1,1500 do
   local phase=B._phase
   if not phase then U.wait(8);U.shot(game,dir..'/'..label..'-overworld.png');return end
   if (phase=='animating' or phase=='awarding' or phase=='ending' or phase=='fade_out')and not shots[phase]then
    U.shot(game,dir..'/'..label..'-'..phase..'.png');shots[phase]=true
   end
   assert(phase~='command','battle unexpectedly returned to commands during '..label)
   U.tap(game,'a');U.wait(2)
  end
  error('battle never ended: '..tostring(B._phase))
 end
 start();U.tap(game,'a');U.wait(4);assert(Ui._mode=='moves');U.tap(game,'a');U.wait(6)
 finish('victory')
 start();U.tap(game,'right');U.tap(game,'down');U.wait(4)
 assert(Ui._menuIndex==4,'RUN input mapping changed');U.tap(game,'a');U.wait(6)
 finish('escape')
 print('[modern-ui] PASS real victory/escape transitions and overworld return')
 love.event.quit()
end
