-- RS owns its full party screen rather than the shared drawSlot function.
-- Substitute only its authored panel textures during drawParty; all native
-- icons, HP ticks, selection/order markers and animations still draw normally.
return function(mod,Theme,enabled)
 local Version=require('src.core.GameVersion')
 if Version.generation()~=3 or(Version.get()~='ruby'and Version.get()~='sapphire')then return function()end end
 local C=require('src.ui.game3.rs.party_chrome');local Kit=require('src.ui.game3.rse.scene_kit')
 local active=true;local scope=false;local paths;local cache={}
 local originalImage=Kit.image;local originalDraw=C.drawParty;local originalBg=C.drawBg
 local imageWrap=function(path,...)
  if not active or not scope or not enabled()then return originalImage(path,...)end
  if not paths then
   paths={}
   for kind,panel in pairs(C.manifest().panels)do
    for bank,p in pairs(panel.variants or{})do paths[p]={empty=kind=='empty',selected=(tonumber(bank)or 0)>=7}end
   end
  end
  local style=paths[path];if not style then return originalImage(path,...)end
  if cache[path]then return cache[path]end
  local source=originalImage(path,...);if not source then return source end
  local G=love.graphics;local w,h=source:getDimensions();local target=G.getCanvas();local canvas=G.newCanvas(w,h,{dpiscale=1});canvas:setFilter('nearest','nearest')
  G.push('all');local ok,err=pcall(function()
   G.setCanvas(canvas);G.origin();G.setShader();G.setScissor();G.setDepthMode();G.clear(0,0,0,0)
   Theme.partyCard(0,0,w,h,style.selected,style.empty)
  end);G.setCanvas(target);G.pop()
  if not ok then canvas:release();error(err,0)end
  cache[path]=canvas;return canvas
 end
 local drawWrap=function(...)
  local prior=scope;scope=true;local result={pcall(originalDraw,...)};scope=prior
  if not result[1]then error(result[2],0)end;return unpack(result,2)
 end
 local bgWrap=function(...)
  if not active or not enabled()then return originalBg(...)end
  local G=love.graphics;G.push('all');G.setColor(.09,.15,.16,1);G.rectangle('fill',0,0,240,160);G.pop()
 end
 Kit.image=imageWrap;C.drawParty=drawWrap;C.drawBg=bgWrap
 return function()
  active=false;if Kit.image==imageWrap then Kit.image=originalImage end;if C.drawParty==drawWrap then C.drawParty=originalDraw end;if C.drawBg==bgWrap then C.drawBg=originalBg end
  for _,canvas in pairs(cache)do canvas:release()end;cache={}
 end
end
