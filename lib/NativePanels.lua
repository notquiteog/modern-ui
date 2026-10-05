-- Shared chrome only: native text, clipping, selection and input stay in charge.
return function(mod,Theme,enabled)
 local active=true;local restore={}
 local gen=require('src.core.GameVersion').generation()
 local function panel(x,y,w,h,kind)
  if not active or not enabled()then return false end
  if type(x)~='number'or type(y)~='number'or type(w)~='number'or type(h)~='number'or w<4 or h<4 then return false end
  local g=love.graphics;g.push('all')
  local ok,err=pcall(Theme.interfacePanel,x,y,w,h,gen<3,kind)
  g.pop();if not ok then error(err,0)end
  return true
 end
 local function wrap(owner,key,paint)
  local original=owner[key];if type(original)~='function'then return end
  local fn=function(...)if active and enabled()and paint(...)then return end;return original(...)end
  owner[key]=fn;restore[#restore+1]=function()if owner[key]==fn then owner[key]=original end end
 end
 if gen<3 then
  wrap(require('src.render.Font'),'drawBox',function(x,y,w,h)return panel(x*8,y*8,w*8,h*8,'menu')end)
 else
  local C=require('src.ui.game3.chrome')
  local function frame(x,y,w,h)return panel((x-1)*8,(y-1)*8,(w+2)*8,(h+2)*8,'menu')end
  wrap(C,'stdFrame',frame);wrap(C,'fixedStdFrame',frame)
  wrap(C,'userFrame',function(_,...)return frame(...)end)
  wrap(C,'dialogueFrame',function()
   local x,y,w,h=C.dialogueWindow()
   return panel((x-1)*8,(y-1)*8,(w+2)*8,(h+2)*8,'dialogue')
  end)
 end
 -- Optional region/quest adapters can paint their frame without importing us.
 -- False means keep their own native frame; dimensions are local draw pixels.
 mod.exports.interface={apiVersion=1,enabled=function()return active and enabled()end,drawPanel=panel}
 return function()active=false;for i=#restore,1,-1 do restore[i]()end end
end
