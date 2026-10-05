-- Native timing, labels, health animation and inputs keep their engine owners.
-- A compatible stage can consume our public opt-in and paint projected cards.
return function(mod,Theme,enabled)
 local restore={}
 local active=true
 local function owned()
  local ok,p=pcall(function()return mod.find and mod.find('BATTLE_ART_VOXEL_FORK')end)
  if not ok then return false end
  local api=p and p.exports and p.exports.battlePresentation
  if not api or type(api.nativeHudOwned)~='function'then return false end
  local ok,value=pcall(api.nativeHudOwned)
  return ok and value==true
 end
 local function wrap(owner,key,fn)
  local original=owner[key];if type(original)~='function'then return end
  local replacement=function(...)
   if not active then return original(...)end
   return fn(original,...)
  end
  owner[key]=replacement
  restore[#restore+1]=function()if owner[key]==replacement then owner[key]=original end end
 end
 local function panel(x,y,w,h)
  -- GB palettes remap grayscale shades after this pass. Arbitrary silver
  -- RGB values become HP-palette colours; native black/white remain stable.
  local g=love.graphics;g.push('all')
  local ok,err=pcall(function()
   g.setColor(0,0,0,1);g.rectangle('fill',x,y-1,w,h+1)
   g.setColor(1,1,1,1);g.rectangle('fill',x+1,y,w-2,h-1)
  end)
  g.pop();if not ok then error(err,0)end
 end
 local gen=require('src.core.GameVersion').generation()
 if gen==3 then
  local Healthbox=require('src.core.game3.battle.healthbox')
  local shader,attempted
  wrap(Healthbox,'draw',function(original,...)
   if not enabled()or owned()then return original(...)end
   local g=love.graphics
   if not attempted then
    attempted=true
    local ok,value=pcall(g.newShader,[[
     vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen) {
      vec4 pixel=Texel(texture,uv)*color;
      // Native paper and its text-wipe rectangles share this palette.
      // Recolour both; preserve ROM silhouettes, OAM offsets and glyphs.
      if(pixel.r>0.97 && pixel.g>0.97 && pixel.b>0.80 && pixel.b<0.91)
       pixel.rgb=vec3(0.80,0.82,0.79);
      else if(pixel.r>0.84 && pixel.r<0.91 && pixel.g>0.80 && pixel.g<0.88 && pixel.b>0.67 && pixel.b<0.77)
       pixel.rgb=vec3(0.62,0.65,0.62);
      return pixel;
     }
    ]])
    if ok then shader=value end
   end
   if not shader then return original(...)end
   g.push('all');g.setShader(shader)
   local result={pcall(original,...)}
   g.pop()
   if not result[1]then error(result[2],0)end
   return unpack(result,2)
  end)
 elseif gen==2 then
  local State=require('src.ui.gen2.BattleState')
  for _,side in ipairs({'Enemy','Player'})do
   local name=side:lower()
   wrap(State,'draw'..side..'Hud',function(original,self,...)
    -- Doubles owns its extra slots. Never add a second HUD behind its cards.
    if enabled()and not owned()and not(self.battle and self.battle.doubles)
      and self:statusHUDVisible()and self:activeMon(name)
      and (name=='player'and self.showPlayerHud or name=='enemy'and self.showEnemyHud)and not self:hudCleared(name)then
     panel(name=='player'and 72 or 0,name=='player'and 56 or 0,name=='player'and 88 or 96,name=='player'and 40 or 32)
    end
    return original(self,...)
   end)
  end
 else
  local State=require('src.battle.BattleState')
  wrap(State,'drawHUDs',function(original,self,slide,...)
   if enabled()and not owned()and not self.fieldCleared and not self.doubles and not self.safari
    and not self.demo and slide==0 and self:statusHUDVisible()then
    if self.enemy and not self.enemy.fainted and not self.showEnemyTrainer
     and not self.enemySendingOut and not self.enemyHudPending and not self.introBalls
     and not self:growInScale(self.enemy)then panel((self.fx and self.fx.hudShakeX)or 0,0,88,32)end
    if self.player and not self.player.fainted and not self.showPlayerBack
     and not self.sendingOut and not self.introBalls then panel(72,56,88,40)end
   end
   return original(self,slide,...)
  end)
 end
 return function()active=false;for i=#restore,1,-1 do restore[i]()end end
end
