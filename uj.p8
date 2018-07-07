pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- game
function _init()
	player={
	 x=64,
	 y=64,
	 spr=1,
	 steps=0, -- step counter
	 flip=false,
	 hp=2,
	 dash=false -- true while dashing, used for enemies only killable when dashign
	}
  
	for e in all(enemies) do
	 del(enemies,e)
	end
  
	eadd(3,1)
	enemy=1 -- poorly named round counter
	mode="rect" -- rect == starting animation
	sadd()
	t=0
	st=0 -- shield timer
	shieldmenet=0 -- when equals to 1 enables shield timer
	--boss=0 -- unnecessary, can be deleted
	
	s=0 -- radius of first circle in the starting animation
 f=0 -- radius of second circle in the starting animation
	xx=128 -- right x coordinate of the starting rectangle animation
	shaking=0
	pal()
end

function gameupdate()
 t+=1
 if t>=60 then t=0 end

 if shieldmenet==1 and st>=1 then 
 	if (t%60==0) st-=1
 end
 
 if (player.hp==3) st=-1

 if (player.hp>3) pal(8,12) pal(15,12)
 if (st==0) player.hp=3 shieldmenet=0 pal()
 if (player.hp<=3) pal()
          
 if (player.hp<3 and #enemies==0) iadd() sadd()
 if (xx>-50) xx-=2
                
 if (#enemies==0) pal() enemy+=1 shaking=1 eadd(3,enemy)
 if (#enemies==5) then 
  pal(5,10)
  enemy=1
	for e in all(enemies) do
	 del(enemies,e)
  end
  eadd(10,enemy,3)
	--boss=1 -- unnecessary, can be deleted
 end
 
 if (btn(0)) player.x-=1 player.flip=true 
	if (btn(1)) player.x+=1 player.flip=false 
	if (btn(2)) player.y-=1
 if (btn(3)) player.y+=1
	
 if btnp(5) then
 	if not player.flip then
 		badd(player.x+12,player.y+10,false,"player") 
 	else
 		badd(player.x+1,player.y+10,true,"player") 
 	end
 end
 
 if btn(0) or btn(1) or btn(2) or btn(3) then
  player.steps+=2
  if player.steps%20==0 then
   if player.spr!=2 then
    player.spr=2
   elseif player.spr!=3 then
    player.spr=3
   end
  end
 else 
  player.spr=1 
  player.steps=0
 end

 foreach(bullets,bupdate)
 foreach(enemies,eupdate)
 foreach(items,iupdate)
 foreach(shield,supdate)
 
 if (btnp(4) and btn(0)) for i=1,25 do player.x-=1 trail(player.x,player.y) end
 if (btnp(4) and btn(1)) for i=1,25 do player.x+=1 trail(player.x,player.y) end
 if (btnp(4) and btn(2)) for i=1,25 do player.y-=1 trail(player.x,player.y) end
 if (btnp(4) and btn(3)) for i=1,25 do player.y+=1 trail(player.x,player.y) end
 
 if btnp(4) then
 	shaking=1
  player.dash=true
  for i=1,50 do
   trail(player.x,player.y)
  end
 else
  player.dash=false
 end
 
 updatetrails()
 
 if (player.x>128) player.x=0 
 if (player.x+7<0) player.x=128 
 if (player.y>128) player.y=0 
 if (player.y+7<0) player.y=128 
 if (player.hp<=0) mode="gameover"
end 

function gamedraw()
 shake()
 spr(player.spr,player.x,player.y,1,2,player.flip)
 if (btn(2) or btn(3)) spr(1,player.x,player.y)
 foreach(bullets,bdraw)
 foreach(enemies,edraw)
 foreach(items,idraw)
 foreach(shield,sdraw)
 drawtrails()
 for i=1,3 do
  spr(14,2+i*9,2)
 end
 for i=1,player.hp do
  if i<4 then
   spr(13,2+i*9,2)
  else
   spr(15,2+i*9,2)
  end
 end
 --rect(player.x,player.y,player.x+8,player.y+16)
	if player.flip==false then spr(10,player.x+10,player.y+5)
 elseif player.flip==true then spr(11,player.x-10,player.y+5) 	
 end
 rectfill(-128,0,xx,128,12) -- starting animation's rectangle
end
-->8
-- bullets
bullets={}

function badd(_x,_y,_flip,_id)
 add(bullets,{
  x=_x,
  y=_y,
  flip=_flip,
  id=_id
 })
end

function bupdate(b)
 if not b.flip then
  if b.x>133 then
   del(bullets,b)
  else
   b.x+=2
  end
 else
  if b.x+3<0 then
   del(bullets,b)
  else
   b.x-=2
  end
 end
 
 if b.id=="enemy" then
  if (b.x>=player.x and player.x+7>=b.x and b.y>=player.y and b.y<=player.y+15) player.hp-=1 del(bullets,b)
 end
end

function bdraw(b)
 line(b.x-6,b.y,b.x,b.y,10)
 pset(b.x,b.y,4)
end
-->8
-- enemies

enemies={}

function eadd(_hp,_num,_tpe)
 for i=1,_num do
 	add(enemies,{
 		x=flr(rnd(112))+8,
 		y=flr(rnd(112))+8,
 		hp=_hp,
 		t=0,
 		tpe=_tpe or flr(rnd(2))+1,
 		canmove=1
 	})
 end
end
	
function eupdate(e)
	e.t+=1
	
	if e.tpe==3 and e.canmove==0 and player.dash==true then
		if e.x+8>=player.x and e.x<=player.x+8 and e.y+14>=player.y and e.y<=player.y+14 then 
	 	del(enemies,e) 
		end
	end
	
	if e.tpe==3 and e.hp<=0 then
		e.canmove=0
		e.hp=0
	end

	local move=flr(rnd(4))
	
	if e.t%20==0 and e.canmove==1 then
		if move==0 and e.x>=8 then e.x-=2 end
		if move==1 and e.x<=120 then e.x+=2 end
		if move==2 and e.y>=8 then e.y-=2 end
		if move==3 and e.y<=120 then e.y+=2 end
 end
 
 for b in all(bullets) do
  if b.x-1>=e.x and b.x-1<=e.x+14 and b.y>=e.y and b.y<=e.y+15 and e.tpe==1 and b.id=="player" then 
   del(bullets,b) 
   e.hp-=1
 	elseif b.x>=e.x and b.x<=e.x+14 and b.y>=e.y and b.y<=e.y+14 and player.x<e.x and (e.tpe==2 or e.tpe==3) then 
   del(bullets,b)
  elseif b.x>=e.x and b.x<=e.x+14 and b.y>=e.y and b.y<=e.y+14 then 
   del(bullets,b) 
   e.hp-=1
  end

 	if (e.hp==0 and e.tpe==1) del(enemies,e)
 	if (e.hp==0 and e.tpe==2) del(enemies,e)
 end

 if player.y>=e.y and player.y<=e.y+14 and e.tpe==1 and e.t%60==0 then
 	if player.x>=e.x+14 then
 	 badd(e.x+13,e.y+7,false,"enemy")
 	elseif not (player.x>=e.x+14) then
 	 badd(e.x-1,e.y+7,true,"enemy")
		end
 end
 
 if player.y>=e.y and player.y<=e.y+14 and e.tpe==3 and e.t%60==0 then
 	if player.x>=e.x+14 then
 	 badd(e.x+13,e.y+7,false,"enemy")
 	elseif not (player.x>=e.x+14) then
 	 badd(e.x-1,e.y+7,true,"enemy")
		end
 end
end

function edraw(e)
	if e.tpe==1 then
		spr(4,e.x,e.y,1,2)
	elseif e.tpe==2 then
		spr(8,e.x,e.y,1,2)
	elseif e.tpe==3 then
		spr(8,e.x,e.y,1,2)
	end
	if e.canmove==0 then
		print("dash!",e.x-5,e.y-10,9)
	end
	--	rect(e.x,e.y,e.x+7,e.y+15,9)
	if e.hp>0 then
		print(e.hp,e.x+2,e.y-10,8)
	end
end
-->8
-- effects

-- screenshake
function shake()
 local shakex=5-flr(rnd(10))
 local shakey=5-flr(rnd(10))
 
 shakex*=shaking
 shakey*=shaking
 
 shaking*=.5
 
 camera(shakex,shakey)
end

-- player trails
trails={}
function addtrail(x,y,t,maxage,col)
	local p={}
	p.x=x
	p.y=y
	p.t=t
	p.age=0
	p.maxage=maxage
	p.col=col
	
	add(trails,p)
end

function trail(x,y)
	addtrail(x,y,0,15,12)
end

function updatetrails()
	local p
	for i=#trails,1,-1 do
		p=trails[i]
		p.age+=1
		p.maxage=i+1
		
		if p.age>p.maxage then
			del(trails,trails[i])
		end
	end
end

function drawtrails()
	local p
	for i=1,#trails do
		p=trails[i]
		if p.t==0 then
			spr(7,p.x,p.y,1,2)
		end
	end
end

-->8
-- game over
function goupdate()
 if (btn(5) and btn(0))  _init()
end

function godraw()
	print("game over",50,40,7)
	print("press ❎ + ⬅️ to restart",23,80,12)
end
-->8
function _update60()
	if mode=="game" then
		gameupdate()
	elseif mode=="gameover" then
		goupdate()
	elseif mode=="rect" then
		rectupdate()
	end
end

function _draw()
	cls()
	if mode=="game" then
		gamedraw()
	elseif mode=="gameover" then
		godraw()
	elseif mode=="rect" then
		rectdraw()
	end
end
-->8
-- starting animation
function rectupdate()
 s+=5
 f+=3
 if (f/2>91) mode="game"
end

function rectdraw()
	circfill(64,64,s,12)
	circfill(64,64,f,0)
	circfill(64,64,f/2,12)
end

--shield
shield={}

function sadd()
	add(shield,{
		x=flr(rnd(112))+8,
		y=flr(rnd(112))+8
	})
end

function supdate(s)
	if s.x+8>=player.x and s.x<=player.x+7 and s.y+14>=player.y and s.y<=player.y+14 then
			shieldmenet+=1
			del(shield,s)
			player.hp=5
			st+=5
	end
end

function sdraw(s)
	spr(12,s.x,s.y)
	print("s",s.x+2.5,s.y+2,7)
end
-->8
-- items
items={}

function iadd()
	add(items,{
		x=flr(rnd(112))+8,
		y=flr(rnd(112))+8
	})
end

function iupdate(i)
	if i.x+8>=player.x and i.x<=player.x+7 and i.y+14>=player.y and i.y<=player.y+14 then
		if player.hp<3 then
			del(items,i)
			player.hp+=1
		end
	end
end

function idraw(i)
	spr(9,i.x,i.y)
end
__gfx__
00000000888888888888888888888888555555558888888888888888ccccccccb555555577777777000000000000000077777777000000000000000000000000
00000000888888888888888888888888555555558888888888888888ccccccccb55555557887788755555500005555557cccccc7005505500055055000550550
00700700ffffffffffffffffffffffff55555555ffffffffffffffffccccccccb555555578877887bbbbb550055bbbbb7cccccc7058858750555555505cc5c75
00077000ffffffffffffffffffffffff55555555ffffffffffffffffccccccccb555555578877887bbbbbbb55bbbbbbb7cccccc7058888750555555505cccc75
00077000ffdffdfffffdffdffffdffdfeebeebeeffdffdffffdffdffcc8cc8ccbebeebee77777777bbbbbbb55bbbbbbb7cccccc70058885000555550005ccc50
00700700ffffffffffffffffffffffff55555555ffffffffffffffffccccccccb555555578877887bbbbb550055bbbbb7cccccc700058500000555000005c500
00000000ffffffffffffffffffffffff55555555ffffffffffffffffccccccccb55555557887788755555500005555557cccccc7000050000000500000005000
000000000888888008888880088888805555555508888880088888800cccccc0b555555577777777000000000000000077777777000000000000000000000000
00000000f888888ff888888ff888888f55555555f888888ff888888fccccccccb555555500000000000000000000000000000000000000000000000000000000
00000000f888888ff888888ff888888f55555555f888888ff888888fccccccccb555555500000000000000000000000000000000000000000000000000000000
00000000f888888ff888888ff888888f55555555f888888ff888888fccccccccb555555500000000000000000000000000000000000000000000000000000000
0000000000800800008008000080080000b00b00008008000080080000c00c00b0b00b0000000000000000000000000000000000000000000000000000000000
0000000000800800008008000080080000b00b00008008000080080000c00c00b0b00b0000000000000000000000000000000000000000000000000000000000
0000000000800800008008000080080000b00b00008008000080080000c00c00b0b00b0000000000000000000000000000000000000000000000000000000000
0000000000800800008000000000080000b00b00008000000000080000000c00b0b00b0000000000000000000000000000000000000000000000000000000000
0000000000800800008000000000080000b00b00008000000000080000000c00b0b00b0000000000000000000000000000000000000000000000000000000000
