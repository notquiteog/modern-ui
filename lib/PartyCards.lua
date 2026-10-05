-- Gen3 exposes independent slot chrome; native party logic and OAM remain intact.
return function(mod,Theme,enabled)
 if require('src.core.GameVersion').generation()~=3 then return function()end end
 local C=require('src.ui.game3.party_chrome')
 local Party=require('src.ui.game3.party_menu')
 local active=true;local undo={}
 local function owns()return active and enabled()and Party.open and Party.mode~='summary'and not C._nativeDelegate end
 local function wrap(key,fn)
  local original=C[key];if type(original)~='function'then return end
  local wrapped=function(...)if not owns()then return original(...)end;return fn(...)end
  C[key]=wrapped;undo[#undo+1]=function()if C[key]==wrapped then C[key]=original end end
 end
 local function paint(fn,...)
  local g=love.graphics;g.push('all');local result={pcall(fn,...)};g.pop()
  if not result[1]then error(result[2],0)end
 end
 wrap('drawBg',function()
  paint(function()
   local g=love.graphics;local D=require('src.core.game3.display')
   g.setColor(.09,.15,.16,1);g.rectangle('fill',0,0,D.W or 240,D.H or 160)
   g.setColor(.13,.21,.21,1);g.rectangle('fill',0,0,88,D.H or 160)
  end)
 end)
 wrap('drawSlot',function(kind,left,top,selected,hideHp)
  local x,y=left*8,top*8;local main=kind=='main';local w,h=main and 80 or 144,main and 56 or 24
  paint(Theme.partyCard,x,y,w,h,selected,kind=='empty')
  if kind~='empty'and not hideHp then
   paint(function()
    local g=love.graphics;g.setColor(.04,.09,.09,1)
    g.rectangle('fill',x+(main and 24 or 88),y+(main and 35 or 10),48,3)
   end)
  end
 end)
 local function button(kind,px,py,selected)
  px=px or 184;py=py or(kind=='cancel'and 136 or 128)
  paint(function()
   Theme.partyCard(px,py,56,16,selected,false)
   local Profile=require('src.core.game3.profile');local profile=Profile.forSession(nil)
   local p=profile and profile.ui and profile.ui.party
   local key=type(p)=='table'and p.buttons and p.buttons[kind]
    or(kind=='cancel'and'gFameCheckerText_Cancel'or'gText_PartyMenu_OK')
   local Font=require('src.ui.game3.frlg_font');local label=require('src.core.game3.rom_text').plain(key)
   local width=Font.measure(label,{small=true})
   Font.draw(label,px+8+math.max(1,math.floor((47-width)/2)),py+1,{small=true,colors=Font.COLOR.PARTY})
   C.drawBall(px-2,py-4,selected and 1 or 0)
  end)
 end
 wrap('drawCancelButton',function(...)return button('cancel',...)end)
 wrap('drawConfirmButton',function(...)return button('confirm',...)end)
 return function()active=false;for i=#undo,1,-1 do undo[i]()end end
end
