-- Semantic Game Boy summary cards; native state owns navigation and swapping.
return function(mod,Theme,enabled)
 local gen=require('src.core.GameVersion').generation();if gen>2 then return function()end end
 local S=require(gen==2 and'src.ui.gen2.SummaryMenu'or'src.ui.SummaryMenu')
 local Strings=require('src.core.Strings');local active=true
 local function text(s,x,y,w)
  s=tostring(s):gsub('№','#'):gsub('♂','M'):gsub('♀','F')
  Theme.text(s,x,y,w,Theme.ink)
 end
 local function cellEntries(list,ox,oy,minY)
  for _,e in ipairs(list)do
   local value=tostring(e.text)
   for _,glyph in ipairs({'┌','┐','└','┘','│','─'})do value=value:gsub(glyph,'')end
   if value~=''then text(value,ox+e.x*8,oy+(e.y-(minY or 0))*8,160-e.x*8)end
  end
 end
 local function gb1(s,game)
  local m=s.mon;local d=game.data.pokemon[m.species];local stats=m.stats
  text(m.nickname or d.name,80,39,160);text('No.'..string.format('%03d',d.dex or 0),80,57,68)
  if require('src.ui.LevelDisplay').visible(m,'summary',game)then text('Lv.'..m.level,166,57,68)end
  if s.sprite then love.graphics.setColor(1,1,1,1);local pw,ph=s.sprite:getDimensions();love.graphics.draw(s.sprite,14+pw,36+math.max(0,56-ph),0,-1,1)end
  if s.page==1 then
   text('HP '..m.hp..' / '..stats.hp,80,78,154)
   local f=math.max(0,math.min(1,m.hp/math.max(1,stats.hp)))
   love.graphics.setColor(.20,.28,.26,1);love.graphics.rectangle('fill',80,89,152,3)
   love.graphics.setColor(Theme.hpColor(f));love.graphics.rectangle('fill',81,90,150*f,1)
   local status=require('src.battle.Status').hudLabelFor(game.data.statuses,m.status)or'OK';text(status,80,95,154)
   for i,key in ipairs({'attack','defense','speed','special'})do
    local y=131+(i-1)*19;text(Strings(key:upper()),18,y,88);text(tostring(stats[key]),102,y,34)
   end
   local Types=require('src.battle.TypeChart')
   for i,id in ipairs(d.types or{})do text(Types.displayName(id,game.data),154,131+(i-1)*17,84)end
   text('ID '..string.format('%05d',m.otId or game.save.player.id or 0),154,170,84)
   text('OT '..(m.ot or game.save.player.name or'RED'),154,190,84)
  else
   text(Strings('EXP POINTS')..' '..tostring(m.exp or 0),80,77,154)
   local nextExp=m.level<100 and require('src.pokemon.Growth').expForLevel(d.growthRate,m.level+1)-(m.exp or 0)or 0
   text(Strings('LEVEL UP')..' '..math.max(0,nextExp),80,94,154)
   for i=1,4 do local mv=m.moves[i];local y=129+(i-1)*20
    local md=mv and game.data.moves[mv.id];text(md and md.name or'-',18,y,140)
    text(md and('PP '..mv.pp..' / '..(md.pp+(mv.ppUps or 0)*math.floor(md.pp/5)))or'--',166,y,72)
   end
  end
 end
 local function gb2(s)
  local m=s.mon;local egg=m.isEgg or m.species=='EGG'
  if s.moveDetail then
   -- Native placement records provide current PP, power, type, description,
   -- and the swap prompt; no private battle/storage state is reconstructed.
   for i=1,4 do if s.moveIndex==i or s.swapFrom==i then
    love.graphics.setColor(1,.84,.38,.45);love.graphics.rectangle('fill',22,40+(3+(i-1)*2)*8,212,15)
   end end
   cellEntries(s:moveDetailPlacements(),30,40,0);return
  end
  love.graphics.push();love.graphics.translate(14,36)
  if egg then s:drawEggPic()else s:drawPic()end
  love.graphics.pop();love.graphics.setShader()
  if egg then
   for _,e in ipairs(s:eggPlacements())do
    text(e.text,16+e.x*8,e.y<8 and(39+e.y*8)or(132+(e.y-9)*8),224-e.x*8)
   end;return end
  cellEntries(s:upperPlacements(),16,39,0)
  local list=s.page==2 and s:greenPlacements()or s.page==3 and s:bluePlacements()or s:pinkPlacements()
  cellEntries(list,48,128,8)
  if s.page==1 then
   local max=m.maxHp or(m.stats and m.stats.hp)or 1;local f=math.max(0,math.min(1,(m.hp or 0)/math.max(1,max)))
   love.graphics.setColor(.20,.28,.26,1);love.graphics.rectangle('fill',48,133,68,4)
   love.graphics.setColor(Theme.hpColor(f));love.graphics.rectangle('fill',49,134,66*f,2)
  end
 end
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport);local s=game.stack and game.stack:top()
  if not active or not enabled()or getmetatable(s)~=S or s.closing or(s.whiteHold or 0)>0 then return result end
  local G=love.graphics;local fullW,fullH=G.getDimensions();local ox,oy,w,h=0,0,fullW,fullH
  if Theme.viewport then ox,oy,w,h=Theme.viewport(fullW,fullH)end;local scale=math.floor(math.min(w/256,h/240));if scale<1 then return result end
  G.push('all');local ok,err=pcall(function()
   G.origin();G.setShader();G.setScissor();G.setDepthMode();G.setColor(.075,.12,.13,1);G.rectangle('fill',0,0,fullW,fullH)
   G.translate(ox+math.floor((w-256*scale)/2),oy+math.floor((h-240*scale)/2));G.scale(scale)
   local page=s.moveDetail and'MOVE DETAILS'or gen==1 and(s.page==1 and'STATUS'or'MOVES')or({'STATUS','MOVES','TRAINER'})[s.page]or'SUMMARY'
   if gen==2 and s.mon.isEgg then page='EGG'end
   Theme.text(page,8,8,240,{.88,.95,.93,1},true)
   if s.moveDetail then Theme.panel(8,30,240,186,false)
   else Theme.panel(8,28,240,86,false);Theme.panel(8,122,240,94,false)end
   if gen==1 then gb1(s,game)else gb2(s)end
   Theme.text(gen==1 and'A / B  CONTINUE'or s.moveDetail and'A  SWAP     B  BACK'or s.page==2 and'SELECT  DETAILS     B  BACK'or'LEFT / RIGHT  PAGE     B  BACK',8,228,240,{.61,.74,.70,1})
  end);G.pop();if not ok then error(err,0)end;return result
 end)
 return function()active=false end
end
