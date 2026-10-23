-- Native options adapters. Each mod ships its own copy and supplies only its
-- own public schema; no other mod or private manager implementation is needed.
local M={}
function M.install(mod,schema,title)
 local active=true
 local function rows(game)
  local out={}
  for _,s in ipairs(schema)do
   if s.type=='toggle' or s.type=='choice' or s.type=='number' then
    local choices=s.choices or {{'OFF',false},{'ON',true}}
    local function index()
     local value=mod.options:get(s.key)
     for i,c in ipairs(choices)do if c[2]==value then return i end end
     return 1
    end
    out[#out+1]={id=mod.id..':'..s.key,label=s.label or s.key,
     value=function()return s.type=='number' and tostring(mod.options:get(s.key) or s.default or 0) or choices[index()][1]end,
     step=function(g,dir)
      g=g or game
      local value
      if s.type=='number' then
       value=math.max(s.min or -math.huge,math.min(s.max or math.huge,(tonumber(mod.options:get(s.key)) or s.default or 0)+(dir or 1)*(s.step or 1)))
      else value=choices[(index()-1+(dir or 1))%#choices+1][2]end
      local opts=g and ((g.save and g.save.options) or g.options)
      if not (opts and g.mods)then return false end
      opts.modOptions=opts.modOptions or {};opts.modOptions[mod.id]=opts.modOptions[mod.id]or{}
      opts.modOptions[mod.id][s.key]=value
      g.mods.modOptions=g.mods.modOptions or {};g.mods.modOptions[mod.id]=g.mods.modOptions[mod.id]or{}
      g.mods.modOptions[mod.id][s.key]=value
      require('src.mods.Runtime').emit('mod.options_changed',{mod=mod.id,key=s.key,value=value})
      if g.writeOptions then g:writeOptions()elseif g.persistOptions then g:persistOptions()end
      return true
     end}
   end
  end
  return out
 end
 local gen3=require('src.core.GameVersion').generation()==3
 local screenId=mod.id..':options'
 if gen3 then
  -- Portable API3 supplies the native Gen3 ui.options.rows call site and
  -- registered screens; the native artwork explicitly uses 240x160.
  local NativeScreen=(loadstring or load)(mod:read('lib/Gen3OptionScreen.lua'))()
  mod.content.screens:register(screenId,{new=function(game)
   local source=rows(game);local items={}
   local function refresh()for i,row in ipairs(source)do items[i].right=row.value(game)end end
   for i,row in ipairs(source)do items[i]={label=row.label,right=row.value(game),row=row}end
   items[#items+1]={label='CANCEL'}
   local menu=mod.ui.ListMenu.new(game,title or mod.id,items,{onChoose=function(item,self)
    if item.row then item.row.step(game,1);refresh()else self:close()end
   end})
   local update=menu.update
   menu.update=function(self,dt)
    if not active then return self:close()end
    local input=game.input;local item=self.items[self.index]
    if item and item.row and(input:wasPressed('left')or input:wasPressed('right'))then
     item.row.step(game,input:wasPressed('left')and-1 or 1);refresh();return
    end
    return update(self,dt)
   end
   return NativeScreen.decorate(menu)
  end})
 end
 mod.hooks:wrap('ui.options.rows',function(nextFn,game,base,...)
  local out=nextFn(game,base,...);if not active or type(out)~='table'then return out end
  local seen={};for _,r in ipairs(out)do if r.id then seen[r.id]=true end end
  local at=#out+1
  for i,r in ipairs(out)do if r.id=='cancel' or r.label=='CANCEL' or r.label=='BACK'then at=i;break end end
  if gen3 then
   local id=mod.id..':settings'
   if not seen[id]then table.insert(out,at,{id=id,label=title or mod.id,group=true,
    value=function()return #rows(game)..' OPTIONS'end,
    activate=function(g)return mod.ui.push(g or game,screenId)end})end
  else
   for _,r in ipairs(rows(game))do if not seen[r.id]then table.insert(out,at,r);at=at+1 end end
  end
  return out
 end)
 mod.hooks:wrap('core.quit_to_launcher',function(nextFn,...)
  active=false;return nextFn(...)
 end)
end
return M
