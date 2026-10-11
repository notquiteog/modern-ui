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

 local menu=Party.new(game,{itemUse=true,onCancel=function()game.stack:pop()end});game.stack:push(menu);U.wait(10)
 U.shot(game,dir..'/item-modern.png');row.step(ctx,1);U.wait(2);U.shot(game,dir..'/item-native.png');row.step(ctx,1)
 local old=menu.index;U.tap(game,'down');U.wait(3);assert(menu.index~=old,'native item selection lost')
 menu.tmhm={move='SURF',kind='HM'};U.wait(3);U.shot(game,dir..'/tm-modern.png');menu.tmhm=nil
 if gen==1 then menu.evoStone='THUNDER_STONE';U.wait(3);U.shot(game,dir..'/stone-modern.png');menu.evoStone=nil end
 local mon=game.save.party[1];local hp=mon.hp;mon.hp=math.max(1,hp-12)
 if gen==1 then menu:animateTo(mon,1,function()end)else menu:showItemResult(1,{text='First result line\nSecond result line\nThird result line',fromHp=1})end
 U.wait(6);U.shot(game,dir..'/heal-modern.png')
 U.wait(120)
 if gen==2 then menu:showItemResult(nil,{text='First result line\nSecond result line\nThird result line',delay=0});U.wait(2);U.shot(game,dir..'/result-modern.png')end
 assert(mon.hp==math.max(1,hp-12),'renderer changed native HP')
 print('PASS GB specialized modern party native selection, eligibility and healing');love.event.quit()
end
