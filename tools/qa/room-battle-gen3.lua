-- Run two isolated *-qa processes with QA_ROLE=host/guest and QA_MODE=single/double.
-- Requires Online + Double Battles + Modern UI enabled in disposable profiles.
-- Exercises real room invitations and native battle entry; no intro/turn bypass.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 love.joystick.getJoysticks=function()return{}end;love.joystick.getJoystickCount=function()return 0 end
 local role=os.getenv('QA_ROLE')or'host';local host=role=='host';local mode=os.getenv('QA_MODE')or'single'
 local R=require('src.mods.Runtime');local update=game.update;game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=require('src.core.GameVersion').get()=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=host and 7 or 8,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 local Party=require('src.core.game3.party');game.session.name=role;game.session.party={}
 for i=1,3 do assert(Party.giveMon(game.session,host and 25 or 19,host and 40 or 20));local m=game.session.party[i];m.moves={33};m.pp={35};m.maxPp={35}end
 local B=require('src.core.game3.battle');local Ui=require('src.core.game3.battle.ui')
 local PartyMenu=require('src.ui.game3.party_menu')
 U.wait(40)
 local S=assert(game.mods.exports['gen1online-plus'].multiplayer)
 if host then assert(S.hostLan(27984))else U.wait(100);assert(S.joinLan('127.0.0.1:27984'))end
 local function untilTrue(fn,label,n)
  for i=1,n or 1800 do if fn()then return end;U.wait(1)end;error(label..' '..tostring(S.notice))
 end
 untilTrue(function()return S.connected and S.peers.remote end,'room connection')
 assert(S.say('QA '..role));U.wait(30);U.shot(game,dir..'/room.png')
 if host then assert(S.invite(mode))else untilTrue(function()return S.activity and S.activity.status=='incoming'end,'invite');U.shot(game,dir..'/incoming.png');game:keypressed('return');game:keyreleased('return');U.wait(4)end
 untilTrue(function()return S.activity and S.activity.status=='active'end,'activity start')
 local seen,command={},false
 local inspected=false
 for i=1,18000 do
  local top=game.stack and game.stack:top();local phase=B._phase and (B._phase..'-'..tostring(Ui._mode))
  if phase and not seen[phase]then print('[room phase]',role,phase);seen[phase]=true;U.shot(game,dir..'/'..phase..'.png')end
  if B._phase=='command' and Ui._mode=='menu'then command=true end
  if os.getenv("QA_OPTIONS")=="1" and mode=="single" and host and not inspected and B._phase=='command' and Ui._mode=='menu'then
   inspected=true
   U.tap(game,'down');U.wait(3);assert(Ui._menuIndex==2,'ITEMS mapping')
   U.tap(game,'a');U.wait(20);U.shot(game,dir..'/online-bag-rule.png')
   for n=1,180 do if Ui._mode=='menu'then break end;U.tap(game,'a');U.wait(3)end
   assert(Ui._mode=='menu','bag rejection did not return to commands')
   U.tap(game,'up');U.tap(game,'right');U.wait(3);assert(Ui._menuIndex==3,'PKMN mapping')
   U.tap(game,'a');U.wait(45);assert(PartyMenu.isOpen(),'voluntary switch party absent')
   U.shot(game,dir..'/online-party.png');U.tap(game,'down');U.tap(game,'a');U.wait(4);U.tap(game,'a');U.wait(15)
  end
  if S.lastActivity and not S.activity then U.wait(20);U.shot(game,dir..'/returned.png');assert(command,'no command menu');assert(S.connected,'room closed');print('[PASS room battle]',role,mode,S.lastActivity.result);love.event.quit();return end
  local picked=PartyMenu.isOpen()and PartyMenu._party and PartyMenu._party[PartyMenu.cursor]
  local invalid=picked and picked.hp<=0
  if picked and B._st and B._st.battlers then
   for id,b in pairs(B._st.battlers)do if id%2==0 and b.mon==picked then invalid=true end end
  end
  U.tap(game,invalid and (PartyMenu.mode=='action'and'b'or'down')or'a');U.wait(2)
 end
 error('room battle stalled')
end
