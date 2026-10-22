-- Semantic summary workspace. Native controllers retain page/move/party input;
-- Emerald's already-running portrait animation is replayed without updating it.
return function(mod,T,enabled)
 local V=require('src.core.GameVersion');if V.generation()~=3 then return function()end end
 local version=V.get();local rs=version=='ruby'or version=='sapphire';local em=version=='emerald'
 local Bridge=require('src.ui.game3.summary_menu');local S=rs and require('src.ui.game3.rs.summary_menu')or Bridge
 local P=require('src.core.game3.pokemon');local D=require('src.core.game3.summary_data');local R=require('src.core.game3.rom_text')
 local Kit=require('src.ui.game3.rse.scene_kit');local A=require('src.core.game3.mon_anim');local active=true;local portraitCanvas
 local function clean(v)return tostring(v or''):gsub('{LV_?2?}','Lv.'):gsub('{[^}]*}',''):gsub('♂','M'):gsub('♀','F')end
 local function text(v,x,y,w)T.text(clean(v),x,y,w,T.ink)end
 local function lines(v,x,y,w,maxLines)
  local out={};local line=''
  for word in (clean(v)..'\n'):gmatch('[^%s]+%s*')do
   local token=word:gsub('%s+$','')
   if #line+#token>math.floor(w/5.5)and line~=''then out[#out+1]=line;line=''end
   line=line==''and token or line..' '..token
   if word:find('\n',1,true)then out[#out+1]=line;line=''end
  end
  if line~=''then out[#out+1]=line end
  for i=1,math.min(#out,maxLines or 5)do text(out[i],x,y+(i-1)*13,w)end
 end
 local function ability(m)
  local id=tonumber(m.abilityId or m.ability)or P.abilityId(P.speciesOf(m),m.personality or 0)
  return id,m.abilityName or(type(m.ability)=='string'and not tonumber(m.ability)and m.ability)or P.abilityName(id)
 end
 local function item(m)
  local I=require('src.core.game3.items_data');local id=I.toNumericId(m.item or m.heldItem)or 0
  return id>0 and I.displayName(id)or'NONE'
 end
 local function memo(m,session)
  if not rs and not em then return table.concat(D.formatTrainerMemo(m,session,{enemyParty=S._enemyParty,owner=S._owner}),'\n')end
  local sections=Kit.loadLua('data/generated/gba/region_map/map_sections.lua');local row=sections and sections.sections and sections.sections[tonumber(m.metLocation)]
  if rs then local out={};for _,run in ipairs(require('src.ui.game3.rs.summary_policy').memo(m,session,row and row.name))do out[#out+1]=run.text end;return table.concat(out)end
  local nature=R.at('gNatureNamePointers',(tonumber(m.personality)or 0)%25)
  local lv=tonumber(m.metLevel)or 0;local own=tostring(m.otName or m.ot or'')==tostring(session.name or session.playerName or'')and(tonumber(m.otId)or 0)%65536==(tonumber(session.trainerId)or 0)%65536
  local key=own and(lv==0 and(row and'gText_XNatureHatchedAtYZ'or'gText_XNatureHatchedSomewhereAt')or(row and'gText_XNatureMetAtYZ'or'gText_XNatureMetSomewhereAt'))or(row and'gText_XNatureProbablyMetAt'or'gText_XNatureObtainedInTrade')
  return R.plain(key,{dynamic={[0]='',[1]='',[2]=nature,[3]=tostring(lv==0 and 5 or lv),[4]=row and row.name or'',[5]=''}})
 end
 local function eggText(m)
  if rs then return R.plain(require('src.ui.game3.rs.summary_policy').eggHatchKey(m))end
  if not em then return D.eggHatchText(m)end
  local f=tonumber(m.friendship or m.eggCycles)or 40
  return R.plain(m.isBadEgg and'gText_EggWillTakeALongTime'or f<=5 and'gText_EggAboutToHatch'or f<=10 and'gText_EggWillHatchSoon'or f<=40 and'gText_EggWillTakeSomeTime'or'gText_EggWillTakeALongTime')
 end
 local function moves(m)
  local out={};for i=1,5 do
   local rawId=i<=4 and P.moveIdAt(m,i)or S._moveToLearn;local id=tonumber(rawId)
   if not id and type(rawId)=='string'then local C=require('src.core.game3.constants').of(S._playerState);id=C and C:id('moves',rawId)or(P.battleMoveId and P.battleMoveId(rawId))end
   if id and id>0 then
    local raw=m.moves and m.moves[i];local def=P.battleMove(id)or{}
    local maximum=rs and require('src.ui.game3.rs.summary_policy').maxPP(m,i,id)or tonumber(m.maxPp and m.maxPp[i])or def.pp or P.movePp(id)or 0
    out[i]={id=id,def=def,name=P.moveName(id),pp=i==5 and maximum or(type(raw)=='table'and raw.pp)or(m.pp and m.pp[i])or maximum,max=maximum}
   end
  end;return out
 end
 mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport);local top=require('src.ui.game3.stack').top()
  if not active or not enabled()or not S.open or not top or top.mod~=S then return result end
  local m=S._loaded or(S._party and S._party[S._cursor]);if not m then return result end
  local page=S._page or 0;local detail=rs and S._state~='normal'or not rs and page==Bridge.PAGE_MOVES_INFO
  if em then page=require('src.ui.game3.rse.summary_menu').page(S);detail=require('src.ui.game3.rse.summary_menu').detail(S)end
  local egg=P.isEgg(m);if egg then page=0 end
  local G=love.graphics;local fullW,fullH=G.getDimensions();local ox,oy,w,h=0,0,fullW,fullH
  if T.viewport then ox,oy,w,h=T.viewport(fullW,fullH)end;local scale=math.floor(math.min(w/320,h/240));if scale<1 then return result end
  G.push('all');local ok,err=pcall(function()
   G.origin();G.setShader();G.setScissor();G.setDepthMode();G.setMeshCullMode("none");G.setStencilTest();G.setBlendMode("alpha");G.setColor(.075,.12,.13,1);G.rectangle('fill',0,0,fullW,fullH)
   G.translate(ox+math.floor((w-320*scale)/2),oy+math.floor((h-240*scale)/2));G.scale(scale)
   T.text(egg and'EGG'or page==0 and'POKEMON INFO'or page==1 and'SKILLS'or(page==3 and(rs or em))and'CONTEST MOVES'or'MOVES',8,8,304,{.88,.95,.93,1},true)
   T.panel(8,28,88,112,false);T.panel(104,28,208,112,false);T.panel(8,148,304,76,false)
   G.setColor(1,1,1,1)
   local emState=em and require('src.ui.game3.rse.summary_menu')._st
   local sprite=emState and emState.monSprite
   local pic=(rs or em)and P.monFrontPic(m)or P.monFrontPic(m,nil,'summary')
   if sprite and sprite.mon==m then
    pic=A.framePic(P.monPicSpecies(m),sprite.frame,P.isShiny(m))or pic
    if pic and pic.image then -- Isolate native portrait raster state from move-detail chrome.
     -- Composite a positive-scale canvas; keep native frame/affine/blend state.
     portraitCanvas=portraitCanvas or G.newCanvas(88,72)
     G.push('all');G.setCanvas(portraitCanvas);G.origin();G.setShader();G.setScissor();G.setDepthMode();G.setMeshCullMode('none');G.setStencilTest();G.setBlendMode('alpha');G.clear(0,0,0,0);G.setColor(1,1,1,1)
     A.draw(sprite,pic.image,44,36);G.pop()
     G.setColor(1,1,1,1);G.setShader();G.setBlendMode('alpha','premultiplied');G.draw(portraitCanvas,8,34);G.setBlendMode('alpha')end
   elseif pic and pic.image then
    local fw,fh=pic.w or 64,pic.h or 64;local man=rs and S.manifest()or em and Kit.manifest('rse/summary')or require('src.ui.game3.summary_chrome').manifest()
    local flip=not egg and not(man and man.noFlip and man.noFlip[tonumber(P.speciesOf(m))])
    G.setColor(1,1,1,1);G.setShader()
    G.draw(pic.image,52+(flip and fw/2 or-fw/2),70-fh/2+(not rs and not em and S._bounce and S._bounce.dy or 0),0,flip and-1 or 1,1)
   end
   text(egg and'EGG'or P.displayName(m),14,112,76)
   if not egg then
    local status=({'PSN','PAR','SLP','FRZ','BRN','PKRS','FNT'})[D.statusAilment(m)]or(P.hasHadPokerus(m)and'PKRS .'or'')
    text((D.isShiny(m)and'* 'or'')..status,14,100,76)
    text('Lv.'..tostring(m.level)..' '..(D.gender(m)or''),14,126,76)
   end
   local session=S._playerState or game.session or{}
   if egg then text('OT  ?????',114,44,188);text('ID  ?????',114,65,188);lines(eggText(m),114,88,188,3)
    lines(em and R.plain('gText_OddEggFoundByCouple')or memo(m,session),18,161,284,4)
   elseif page==0 then
    text(P.name(P.speciesOf(m)),114,37,168)
    local img,q=require('src.core.game3.battle.ui').ballQuad(Bridge.ballIdOf(m),0)
    if img then G.setColor(1,1,1,1);G.draw(img,q,286,32)end
    local types=P.types(P.speciesOf(m))or{};local Types=require('src.core.game3.battle.types');local names={}
    for _,id in ipairs(types)do local name=type(id)=='number'and Types.name(id)or id;if name~=names[1]then names[#names+1]=name end end
    text(table.concat(names,' / '),114,54,188)
    text('OT '..tostring(m.otName or m.ot or session.name or''),114,72,188)
    text('ID '..string.format('%05d',(tonumber(m.otId or session.trainerId)or 0)%65536),114,89,188)
    text('ITEM '..item(m),114,108,188)
    local dex
    if rs or em then
     if require('src.core.game3.dex').nationalEnabled(session)then dex=P.national(P.speciesOf(m))
     else local regional=Kit.loadLua('data/generated/gba/pokemon/hoenn.lua');dex=regional and regional.toHoenn[P.speciesOf(m)];if dex and dex>202 then dex=nil end end
    else dex=Bridge.dexNoText(m,session)end
    text('No. '..tostring(dex or'---'),114,126,92)
    local mark=tonumber(m.markings)or 0
    for i=0,3 do local filled=math.floor(mark/2^i)%2==1;G.setColor(filled and .20 or .56,filled and .30 or .61,filled and .28 or .57,1)
     local x=252+i*13;local mode=filled and'fill'or'line';G.setLineWidth(1)
     if i==0 then G.circle(mode,x,130,3)elseif i==1 then G.rectangle(mode,x-3,127,6,6)elseif i==2 then G.polygon(mode,{x,126,x-4,133,x+4,133})else G.circle(mode,x-2,128,2);G.circle(mode,x+2,128,2);G.polygon(mode,{x-4,129,x+4,129,x,134})end
    end
    lines(memo(m,session),18,158,284,5)
   elseif page==1 then
    local stats=m.stats or{};local function stat(k,alt)return tonumber(m[k]or m[alt]or stats[k]or stats[alt])or 0 end
    local fields={{'HP',tostring(m.hp or 0)..' / '..tostring(m.maxHp or stats.hp or 0)},{'ATTACK',stat('attack','atk')},{'DEFENSE',stat('defense','def')},{'SP. ATK',stat('spAtk','spa')},{'SP. DEF',stat('spDef','spd')},{'SPEED',stat('speed','spe')}}
    for i,f in ipairs(fields)do text(f[1],114,35+(i-1)*16,112);text(f[2],224,35+(i-1)*16,76)end
    local fraction=math.max(0,math.min(1,(m.hp or 0)/math.max(1,m.maxHp or stats.hp or 1)))
    G.setColor(.20,.28,.26,1);G.rectangle('fill',225,46,76,2);G.setColor(T.hpColor(fraction));G.rectangle('fill',225,46,76*fraction,2)
    local exp=D.expProgress(m,P.growthRate(P.speciesOf(m)));local id,name=ability(m)
    text('EXP '..exp.totalExp..'    NEXT '..exp.expNeeded,18,156,284)
    G.setColor(.20,.28,.26,1);G.rectangle('fill',18,167,284,2);G.setColor(.17,.51,.72,1);G.rectangle('fill',18,167,284*exp.progressPercent,2)
    text(name,18,173,284);lines(D.abilityDescription(id,name),18,188,284,2)
    text('ITEM '..item(m),18,214,180)
    if em or rs then text('RIBBONS '..require('src.core.game3.rse.ribbons').count(m),211,214,92)end
   else
    local list=moves(m);local selected=rs and(S._selected or 0)+1 or S._moveCursor or 1;local swapping=rs and S._state=='swap'or S._swapSlot~=nil
    for i=1,5 do local mv=list[i];if i<=4 or detail then
     if detail and i==selected then G.setColor(1,.84,.38,.45);G.rectangle('fill',110,33+(i-1)*20,196,19)end
     local origin=rs and swapping and(S._switch or 0)+1 or S._swapSlot
     if origin==i then G.setColor(.28,.45,.59,1);G.setLineWidth(1);G.rectangle('line',110.5,33.5+(i-1)*20,195,18)end
     text(mv and mv.name or i==5 and'CANCEL'or'-',114,35+(i-1)*20,126)
     if mv then text(mv.pp..'/'..mv.max,244,35+(i-1)*20,58)end
    end end
    local mv=list[selected]or list[1]
    if S._hmNotice or(rs and S._state=='notice')then lines(R.plain(rs and'gOtherText_CantForgetHMs'or em and'sText_HMMovesCantBeForgotten'or'gText_PokeSum_HmMovesCantBeForgotten'),18,158,284,4)
    elseif mv then
     if page==3 and(rs or em)then
      local pack=Kit.loadLua('data/generated/gba/pokemon/contest_moves.lua');local cm=pack and pack.moves[mv.id];local effect=cm and pack.effects[cm.effect]
      if effect then text('APPEAL '..math.floor((effect.appeal==255 and 0 or effect.appeal)/10)..'    JAM '..math.floor((effect.jam==255 and 0 or effect.jam)/10),18,157,284);lines(D.contestEffectDescription(effect),18,176,284,3)end
     else text('POWER '..tostring((tonumber(mv.def.power)or 0)<2 and'--'or mv.def.power)..'    ACCURACY '..tostring((tonumber(mv.def.accuracy)or 0)==0 and'--'or mv.def.accuracy),18,157,284);lines(D.moveDescription(mv.id,mv.name),18,176,284,3)end
    end
    if swapping then text('SELECT A MOVE TO SWITCH',18,214,284)end
   end
   T.text(detail and'A  SELECT     B  BACK'or'LEFT / RIGHT  PAGE     B  BACK',8,230,304,{.61,.74,.70,1})
  end);G.pop();if not ok then error(err,0)end;return result
 end)
 return function()active=false;if portraitCanvas then portraitCanvas:release();portraitCanvas=nil end end
end
