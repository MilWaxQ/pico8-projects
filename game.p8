pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	player={x=64,y=64,spr=1}
 frames=0
 secs=0
 eadd(flr(rnd(128)),flr(rnd(128)))
end

function _update()
	frames+=1
	if (frames%30==0) secs+=1
 
	
	if (btn(0)) player.x-=1  
	if (btn(1)) player.x+=1
	if (btn(2)) player.y-=1
	if (btn(3)) player.y+=1
	if btn()==0 or btn()==32 or btn()==16 or btn()==48 then 
	 player.spr=1 
	else 
	 if frames%10==0 and player.spr!=2 then
   player.spr=2
  elseif frames%10==0 and player.spr!=3 then
   player.spr=3
  end
 end
 if (btnp(5)) badd(player.x+10,player.y+4)
 foreach(bullets,bupdate)
end

function _draw()
 cls()
 spr(player.spr,player.x,player.y)
 cursor(0,0)
 print(frames)
 print(secs)
 foreach(enemies,edraw)
 foreach(bullets,bdraw)
end
-->8
-- bullets
bullets={}

function badd(_x,_y)
 add(bullets,{
  x=_x,
  y=_y
 })
end

function bupdate(b)
 if b.x<131 then
  b.x+=2
 else
  del(bullets,b)
 end
 
 for e in all(enemies) do
  if b.x>=e.x and b.x<=e.x+7
   and b.y>=e.y and b.y<=e.y+7 then
   del(enemies,e)
   del(bullets,b)
  end
 end
end

function bdraw(b)
 line(b.x,b.y,b.x-3,b.y,10)
end
-->8
-- enemies
enemies={}

function eadd(_x,_y)
 add(enemies,{
  x=_x,
  y=_y,
  hp=3
 })
end

function eupdate(e)
 
end

function edraw(e)
	spr(4,e.x,e.y)
end
__gfx__
00000000888888888888888888888888555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffffffffffff555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700f5fff5fff5fff5fff5fff5fff66ff66f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ffffffffffffffffffffffff555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000088888550888885508888855555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700088880500888805008888050555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080080000800800008008000005005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080080000800000000008000005005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
