-- Run two isolated *-qa processes with QA_ROLE=host/guest and QA_MODE=single/double.
-- Requires Online + Double Battles + Modern UI enabled in disposable profiles.
-- Exercises real room invitations and native battle entry; no intro/turn bypass.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 love.joystick.getJoysticks=function()return{}end;love.joystick.getJoystickCount=function()return 0 end
 local role=os.getenv('QA_ROLE')or'host';local host=role=='host';local mode=os.getenv('QA_MODE')or'single'
 local R=require('src.mods.Runtime');local update=game.update;game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 local gen=require('src.core.GameVersion').generation()
 if gen==2 then game.world.trySceneScript=function()return false end;game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',host and 7 or 8,8,'down'))else U.teleport(game,'PALLET_TOWN',9,host and 8 or 7,'down')end
 local Pokemon=require(gen==2 and 'src.battle.gen2.Mon'or'src.pokemon.Pokemon');game.save.party={}
 for i=1,3 do game.save.party[i]=Pokemon.new(game.data,host and 'PIKACHU'or'RATTATA',host and 40 or 20);game.save.party[i].moves={{id='TACKLE',pp=35,maxPP=35}}end
 local S=assert(game.mods.exports['gen1online-plus'].multiplayer)
 if host then assert(S.hostLan(27983))else U.wait(100);assert(S.joinLan('127.0.0.1:27983'))end
 local function untilTrue(fn,label,n)
  for i=1,n or 1800 do if fn()then return end;U.wait(1)end;error(label..' '..tostring(S.notice))
 end
 untilTrue(function()return S.connected and S.peers.remote end,'room connection')
 assert(S.say('QA '..role));U.wait(30);U.shot(game,dir..'/room.png')
 if host then assert(S.invite(mode))else untilTrue(function()return S.activity and S.activity.status=='incoming'end,'invite');U.shot(game,dir..'/incoming.png');game:keypressed('return');game:keyreleased('return');U.wait(4)end
 untilTrue(function()return S.activity and S.activity.status=='active'end,'activity start')
 local seen,command={},false
 for i=1,18000 do
  local top=game.stack:top();local phase=top and (top.phase or top.stage)
  if phase and not seen[phase]then print('[room phase]',role,phase);seen[phase]=true;U.shot(game,dir..'/'..phase..'.png')end
  if top and top.phase=='menu'then command=true end
  if S.lastActivity and not S.activity then U.wait(20);U.shot(game,dir..'/returned.png');assert(command,'no command menu');assert(S.connected,'room closed');print('[PASS room battle]',role,mode,S.lastActivity.result);love.event.quit();return end
  local picked=top and top.party and top.index and top.party[top.index]
  U.tap(game,picked and picked.hp<=0 and 'down'or'a');U.wait(2)
 end
 error('room battle stalled')
end
