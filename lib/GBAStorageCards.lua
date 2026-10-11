-- Modern storage workspaces preserve the native 30-slot grid, wallpaper choice,
-- presentation timeline, held-mon animations and every PC action controller.
return function(mod,Theme,enabled)
 if require('src.core.GameVersion').generation()~=3 then return function()end end
 local C=require('src.ui.game3.pc_chrome');local Box=require('src.ui.game3.box_storage_ui')
 local active=true;local undo={};local function owns()return active and enabled()and Box.open end
 -- 0.3.76's RS manifest stores an absolute cache key, but native ensure's
 -- texture helper prefixes it again. Load that exact native asset only when
 -- the normal lookup failed; retain the engine's screen-bar animation.
 local ensure=C.ensure
 local ensureWrap=function(...)
  local result=ensure(...)
  local e=C._manifest and C._manifest.pcScreenEffect
  local path=e and e.bar and e.bar.png
  if not C._pcScreenBarImg and type(path)=='string'and path:match('^data/generated/')then
   local ok,img=pcall(require('src.render.Assets').image,path)
   if ok and img then C._pcScreenBarImg=img end
  end
  return result
 end
 C.ensure=ensureWrap;undo[#undo+1]=function()if C.ensure==ensureWrap then C.ensure=ensure end end
 local function wrap(t,k,fn)
  local original=t[k];local wrapped=function(...)
   if not owns()then return original(...)end
   local G=love.graphics;G.push('all');local r={pcall(fn,...)};G.pop();if not r[1]then error(r[2],0)end;return unpack(r,2)
  end
  t[k]=wrapped;undo[#undo+1]=function()if t[k]==wrapped then t[k]=original end end
 end
 wrap(C,'drawBackground',function()local G=love.graphics;G.setColor(.09,.15,.16,1);G.rectangle('fill',0,0,240,160)end)
 wrap(C,'drawInterfaceFrame',function()
  Theme.panel(0,16,80,68,false);Theme.panel(0,84,80,76,false)
  Theme.text('POKEMON',3,4,74,{.88,.95,.93,1},true)
  local G=love.graphics;G.setColor(.09,.15,.16,.2);G.setLineWidth(1)
  for row=0,4 do for col=0,5 do G.rectangle('line',84.5+col*24,28.5+row*24,23,23)end end
 end)
 wrap(C,'drawWaveforms',function()end)
 wrap(C,'drawTopButtons',function(selected)
  Theme.partyCard(80,0,88,16,selected=='party',false);Theme.partyCard(168,0,72,16,selected=='close',false)
  Theme.text('PARTY',83,4,82,{.94,.96,.93,1},true);Theme.text('CLOSE',171,4,66,{.94,.96,.93,1},true)
 end)
 -- Palette replacement changes only lower-panel ink. Native data, gender,
 -- held-item names, egg privacy and preview/mosaic art stay authoritative.
 wrap(C,'textColors',function()
  local clear={0,0,0,0};local shadow={.85,.87,.82,1}
  return{fg=Theme.ink,shadow=shadow,bg=clear},{fg={.10,.33,.61,1},shadow=shadow,bg=clear},{fg={.63,.18,.30,1},shadow=shadow,bg=clear}
 end)
 local version=require('src.core.GameVersion').get()
 if version=='ruby'or version=='sapphire'then
  wrap(require('src.ui.game3.rs.storage_visuals'),'textColors',function(kind)
   return{fg=kind=='M'and{.10,.33,.61,1}or kind=='F'and{.63,.18,.30,1}or Theme.ink,shadow={.85,.87,.82,1},bg={0,0,0,0}}
  end)
 end
 return function()active=false;for i=#undo,1,-1 do undo[i]()end end
end
