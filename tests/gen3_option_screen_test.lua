-- The public ListMenu owns input; drawing must use native GBA font/art.
local draws,frames={},{}
package.loaded['src.ui.game3.frlg_font']={
 measure=function(s)return #s*6 end,countChars=function(s)return #s end,truncate=function(s,n)return s:sub(1,n)end,
 draw=function(s,x,y)draws[#draws+1]={text=s,x=x,y=y,width=#s*6}end,
 drawGlyph=function(g,x,y)assert(g==239 and x==12 and y>=40 and y<=130)end,CHAR_SELECTOR_ARROW=239}
package.loaded['src.ui.game3.window']={template=function(x,y,w,h)return{x=x,y=y,w=w,h=h}end,stdFrame=function(t)frames[#frames+1]=t end}
love={graphics={setColor=function()end,rectangle=function(_,x,y,w,h)assert(x==0 and y==0 and w==240 and h==160)end}}
local menu={title='WILDS',items={},index=1,scroll=0}
for i=1,20 do menu.items[i]={label='A long option label number '..i,right=string.rep('V',25)}end
menu.items[21]={label='CANCEL'}
assert(loadfile('lib/Gen3OptionScreen.lua'))().decorate(menu)
assert(menu.gbaCanvas and menu.rows==7)
menu:draw();assert(#draws==15 and #frames==2 and draws[1].text=='WILDS','native font must paint title and all visible values')
for i=2,#draws,2 do local label,value=draws[i],draws[i+1];assert(label.x+label.width+8<=value.x and value.x+value.width<=224,'columns overlap or leave viewport')end
menu.scroll=14;menu.index=21;draws={};menu:draw();assert(draws[#draws].text=='CANCEL'and draws[#draws].y==130,'last option/CANCEL not scroll-reachable')
assert(package.loaded['src.render.Font']==nil,'GB font cannot render native GBA options')
print('PASS native GBA font/frame draw, explicit240x160 canvas, nonoverlapping columns, seven-row scrolling/CANCEL and no GB font')
