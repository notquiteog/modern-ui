-- Native capture/Dex/naming flow with optional Battle Art scene enabled.
-- Use only a disposable *-qa profile; no user saves are read or written.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 love.joystick.getJoysticks=function()return{}end;love.joystick.getJoystickCount=function()return 0 end
 local off=os.getenv('CAPTURE_OFF')=='1';local escape=os.getenv('CAPTURE_ESCAPE')=='1';local item=escape and 4 or 1
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=require('src.core.GameVersion').get()=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(os.getenv('QA_NATIVE')=='1'and 0 or 3,game)
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 V.require('Gen3Battle').setting:setIndex(os.getenv('QA_NATIVE')=='1'and 2 or 1,game)
 V.require('BattleArt').backPlacementSetting:setIndex(2,game)
 V.require('PokeballSettings').enabled:setIndex(off and 1 or 2,game)
 if os.getenv('CAPTURE_DARK')=='1' then V.require('UiBackplates').hudColor:setIndex(2,game) end
 local Party=require('src.core.game3.party');game.session.name='TESTER';game.session.playerName='TESTER';game.session.party={};assert(Party.giveMon(game.session,6,35))
 local Bag=require('src.core.game3.bag');game.session.bag=Bag.new();assert(Bag.add(game.session.bag,item,1))
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 assert(require('src.core.game3.battle_bridge').startWild(nil,game,{species=19,level=3},{}))
 for i=1,500 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 U.wait(15);assert(B._phase=='command')
 local Ball=V.require('Pokeball');local draw=Ball.draw;local draws=0;Ball.draw=function(self,...)draws=draws+1;return draw(self,...)end
 if escape then B._st.rng=function(lo,hi)return hi end end
 local command=UI.takeCommand;UI.takeCommand=function()UI.takeCommand=command;UI._mode='none';return{kind='bag',itemId=item}end
 for i=1,300 do if B._phase=='catching'then break end;U.tap(game,'a');U.wait(2)end
 assert(B._phase=='catching','no native capture '..tostring(B._phase))
 for i=1,(off and 5 or 150)do if V.require('Gen3Capture').status().started then break end;U.tap(game,'a');U.wait(2)end
 for i=1,900 do U.wait(1);if i==250 or i==450 or i==750 then U.shot(game,dir..'/capture-'..i..'.png')end end
 for k,v in pairs(V.require('Gen3Capture').status())do print('QA capture',k,v)end
 print('QA state',B._st.wild,B._st.double,B._st.safari,V.require('PokeballSettings').active(),V.require('Gen3Battle').enabled())
 assert(off and draws==0 or not off and draws>0,'capture ownership mismatch');assert(not Bag.has(game.session.bag,item,1),'native inventory not consumed')
 print('[PASS Gen3 capture native inventory and draws]',draws,B._phase)
 for i=1,300 do if B._phase~='catching'then break end;U.tap(game,'a');U.wait(3)end
 U.shot(game,dir..'/final.png');print('QA final',B._phase)
 local shots={}
 for i=1,1500 do
  local phase=B._phase
  if not phase then break end
  if not shots[phase]then U.shot(game,dir..'/post-'..phase..'.png');shots[phase]=true end
  if phase=='catch_naming'then
   print('[PASS native naming opened]');U.shot(game,dir..'/naming.png');U.tap(game,'a');U.tap(game,'start');U.tap(game,'a');U.wait(12);break
  end
  U.tap(game,'a');U.wait(3)
 end
 assert(shots.catch_naming,'nickname screen never opened: '..tostring(B._phase))
 for i=1,1200 do if not B._phase then break end;U.tap(game,'a');U.wait(3)end
 assert(not B._phase,'did not return after naming: '..tostring(B._phase));assert(#game.session.party==2,'capture missing from party');U.wait(90);U.shot(game,dir..'/named-return.png');print('[PASS native naming and capture returned]')
 Ball.draw=draw;love.event.quit()
end
