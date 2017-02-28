#Rem
	Pocket Space Invaders
	Original concept and code by Paul Grayston - Yavin(Team Rebellion Software)
	Original start date [2nd Jan 2005 - 1am]
	Adapted by Jim Brown [April 2009]
	Adopted by Jesse for Monkey2 [feb 2017]
	TODO
	============================
	1. Implement hi-score name entry. See Game.Died() function
#End Rem 


Namespace myapp

#Import "<std>"
#Import "<mojo>"

#Import "img/bkg2.png"
#Import "img/titlescreen.png"
#Import "img/gameover.png"
#Import "img/block.png"
#Import "img/playerbullet.png"
#Import "img/ship.png"
#Import "img/alienset.png"
#Import "img/alienBullet.png"
#Import "img/ufo.png"
#Import "img/getReady.png"
#Import "sfx/playershoot.wav"
#Import "sfx/alienshoot.wav"
#Import "sfx/shuntdown.wav"
#Import "sfx/killplayer.wav"
#Import "sfx/hitalien.wav"
#Import "sfx/killalien.wav"
#Import "sfx/hitblock.wav"
#Import "sfx/ab_hitblock.wav"
#Import "sfx/ufo.wav"
#Import "sfx/killufo.wav"

Using std..
Using mojo..

Const VER := "v0.1"

Const GFX_Width:Int 	= 	520
Const GFX_Height:Int 	= 	600

Global player1:player
Global ufo1:ufo
Global wait1:wait
Global game:Game
Global Score:string
Global Hscore:string[][]
Global data:String[][]

Class Game Extends Window

	Const TITLESCREEN:Int=0 , PLAYING:Int=1 , INJURED:Int=2
	Const GAMEOVER:Int=3 , INITGAME:Int=4 ,GETREADY:Int=5
	Const ENTERNAME:Int=6,ENDGAME:Int=7, EXITGAME:Int=9
	Global SpeedIncrease:Float
	Global mode:Int
	Global TimeOut:Int
										 
	Method New( title:String="Pocket Invaders "+VER,width:Int=GFX_Width,height:Int=GFX_Height,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )

		data = New String[][10]
		
		data[0] = New String[]( "xx....xx",
								".xx..xx.",
								"..x..x..",
								"........",
								".xxxxxx.",
								"..xxxx..")
								
		data[1] = New String[]( "...xx...",
								"...xx...",
								"...xx...",
								"..xxxx..",
								".xxxxxx.",
								"xxxxxxxx")
								
		data[2] = New String[]( "..x..x..",
								".xxxxxx.",
								"xx.xx.xx",
								"xx.xx.xx",
								"..x..x..",
								".x.xx.x.")
								
		data[3] = New String[]( ".xxxxxx.",
								"x..xx..x",
								"x.x..x.x",
								"xx....xx",
								"x......x",
								".x....x.")
								
		data[4] = New String[]( "..xxxx..",
								".xxxxxx.",
								".x....x.",
								".xxxxxx.",
								"xxxxxxxx",
								"..xxxx..")
								
		data[5] = New String[]( "..x.x.x.x..",
								"x.x.x.x.x.x",
								"..x.x.x.x..",
								"x.x.x.x.x.x",
								"..x.x.x.x..",
								"..x.x.x.x..")
								
		data[6] = New String[]( "xxxxxxxxx",
								"..x.x.x.",
								"xxxxxxxxx",
								"...x.x..",
								"xxxxxxxxx",
								"..xxxxx..")
								
		data[7] = New String[]( ".xx......",
								"x..x.....",
								"x..x..xx.",
								".xx..x..x",
								".....x..x",
								"......xx.")
								
		data[8] = New String[]( "..xxxxxx..",
								".xx....xx.",
								"xxx....xxx",
								"..xxxxxx..",
								"...xxxx...",
								"..xxxxxx..")
								
		data[9] = New String[]( "..xxxxxxxxx.",
								".x.xx......x",
								".x..xxx....x",
								".x....xxx..x",
								".x......xx.x",
								"..xxxxxxxxx.")

		Hscore = New String[5+1][]
		For Local looper:Int=0 Until Hscore.Length	
			Hscore[looper] = New String[2+1]
			Hscore[looper][1]="Name-"+String(looper+1)
			If looper < 5
				Hscore[looper][2]="99"
			Else
				Hscore[looper][2]= "00"
			EndIf
		Next
		Gfx.Bkg 			= Image.Load("asset::bkg2.png")
		Gfx.Menu 			= Image.Load("asset::titlescreen.png")
		Gfx.GameOver 		= Image.Load("asset::gameover.png")
		Gfx.Block 			= Image.Load("asset::block.png")
		Gfx.playerBullet 	= Image.Load("asset::playerbullet.png")
		Local img:Image 	= Image.Load("asset::ship.png")
		Gfx.Player[0] 		= New Image(img,0,0,40,40)
		Gfx.Player[1]		= New Image(img,40,0,40,40) 'Image.Load("asset::ship.png",40,40,0,2)
		Local aln:Image		= Image.Load("asset::alienset.png")
		For Local i:Int = 0 Until NUMALIENTYPES*2
			Gfx.alien[i]	= New Image(aln,i*32,0,32,32)
			Gfx.alien[i].Handle = New Vec2f(.5,.5)
		next
		Local bullet:Image 	= Image.Load("asset::alienBullet.png")
		Gfx.alienBullet[0]	= New Image(bullet, 0,0,10,20)
		Gfx.alienBullet[1]	= New Image(bullet,10,0,10,20)
		Gfx.alienBullet[2]	= New Image(bullet,20,0,10,20)
		Gfx.Ufo				= Image.Load("asset::ufo.png")
		Gfx.GetReady		= Image.Load("asset::getReady.png")

		Gfx.Block.Handle' = New Vec2f(.5,.5)
		Gfx.playerBullet.Handle = New Vec2f(.5,.5)
		Gfx.alienBullet[0].Handle = New Vec2f(.5,.5)
		Gfx.alienBullet[1].Handle = New Vec2f(.5,.5)
		Gfx.alienBullet[2].Handle = New Vec2f(.5,.5)
		Gfx.GetReady.Handle = New Vec2f(.5,.5)

		Sfx.PlayerShoot 	= Sound.Load("asset::playershoot.wav")
		Sfx.AlienShoot 		= Sound.Load("asset::alienshoot.wav")
		Sfx.AlienShunt 		= Sound.Load("asset::shuntdown.wav")
		Sfx.PlayerDie		= Sound.Load("asset::killplayer.wav")
		Sfx.AlienHit 		= Sound.Load("asset::hitalien.wav")
		Sfx.AlienDie 		= Sound.Load("asset::killalien.wav")
		Sfx.BlockHit		= Sound.Load("asset::hitblock.wav")
		Sfx.abBlockHit		= Sound.Load("asset::ab_hitblock.wav")
		Sfx.UfoAppear 		= Sound.Load("asset::ufo.wav")
		Sfx.UfoDie 			= Sound.Load("asset::killufo.wav")
		'********************************************************************
		' GAME INITIALISATION
		'********************************************************************
		player1 = New player
		ufo1 =New ufo
		wait1 = New wait
	End

	Method OnRender( canvas:Canvas ) Override
		'********************************************************************
		' RUN THE GAME LOOP
		'********************************************************************
			Select mode
				Case TITLESCREEN
					MainTitle(canvas)
				Case INITGAME
					Init()
				Case GETREADY
					Ready(canvas)
				Case PLAYING, INJURED
					Play(canvas)
				Case GAMEOVER
					Died(canvas)
				Case EXITGAME
					_Exit()
				Case ENDGAME
					App.Terminate()
			End Select
	
		App.RequestRender()
	
	End

	Function Init()
		SeedRnd(Millisecs())
		SpeedIncrease=1.1
		block.Init()
		player1.level=0
		player1.score=0
		player1.life=3
		LoadWave(player1.level)
		mode=GETREADY
		wait1.init()
		
	End Function
	'
	Function Reset()
		alien.list.Clear()
		playerBullet.list.Clear()
		alienBullet.list.Clear()
		particle.list.Clear()
		player1.level=1
		player1.x=GFX_Width/2
		player1.y=GFX_Height-(Gfx.Player[0].Height)
		player1.life=3
		ufo1.life=0
	End Function
	'
	'
	Function MainTitle(canvas:Canvas)
		canvas.Clear(Color.Black)
		canvas.Color = New Color(1,1,1)
		canvas.DrawImage(Gfx.Menu,0,0)
		canvas.Color = New Color(0,1,0)
		canvas.DrawText("PRESS SPACE",158,GFX_Height-72)
		If Keyboard.KeyHit(Key.Space)
			Game.mode=Game.INITGAME 
		EndIf
		If Keyboard.KeyHit(Key.Escape) Game.mode=Game.EXITGAME
	End Function 
	'
	Function Play(canvas:Canvas)
		Game.Update(canvas)
		Game.Render(canvas)
		If player1.life=0 And Game.TimeOut<80
			Game.mode=Game.GAMEOVER
			Game.Reset()
			Return
		EndIf
		If Keyboard.KeyHit(Key.Escape)
			Game.mode=Game.TITLESCREEN
			Game.Reset()
		EndIf
	End Function
	
	Function Ready(canvas:Canvas)
		game.Render(canvas)
		game.Update(canvas)
		wait1.update()
		wait1.Render(canvas)
		If Keyboard.KeyHit(Key.Escape)
			Game.mode=Game.TITLESCREEN 
			'FlushKeys()
			Game.Reset()
		EndIf
	End Function 
	'
	Function Update(canvas:Canvas)
		Global timeelapsed:Int
		' simple update limiter
		If Millisecs()<timeelapsed+12 Return
		timeelapsed=Millisecs()
		ufo1.Update()
		player1.Update()
		playerBullet.Update(canvas)
		alienBullet.Update(canvas)
		alien.Update()
		particle.Update()
		' Proceeds to next level when aliens are cleared
		If alien.list.Count()=0
			player1.level+=1
			If player1.level >= 11 player1.level=1
				
			LoadWave(player1.level)
			player1.score+= (block.list.Count()*50)
			block.Init()
			Game.mode = Game.GETREADY
			wait1.init()
			playerBullet.list.Clear()
		End If
		' if player got hit .. out of action for a while
		If Game.mode=Game.INJURED
			Game.TimeOut-=1
			If Game.TimeOut=0 Then Game.mode=Game.PLAYING
		EndIf
	End Function
	'
	Function Render(canvas:Canvas)
		Global oldTime:Int,frameCount:Int,FPS:Int
		canvas.Scale( Float(GFX_Width)/Float(Gfx.Bkg.Width) , Float(GFX_Height)/Float(Gfx.Bkg.Height))
		canvas.Color = New Color(1,1,1)
		canvas.DrawImage(Gfx.Bkg,0,0)
		canvas.Scale(1.0,1.0)
		canvas.DrawText("Scr: "+player1.score,1,3)
		canvas.DrawText("Lvl: "+player1.level,GFX_Width-58,3)
		If player1.score > Int(Hscore[0][2])
			canvas.DrawText("Hsc: "+player1.score,GFX_Width/2,3)
		Else
			canvas.DrawText("Hsc: "+Int(Hscore[0][2]),GFX_Width/2,3)
		EndIf
		' draw lives
		For Local n:Int=0 Until player1.life
			canvas.DrawImage(Gfx.Player[0],8+n*38,GFX_Height-26)
		Next
		canvas.Scale(1.0,1.0)
		playerBullet.Render(canvas)
		alienBullet.Render(canvas)
		block.Render(canvas)
		alien.Render(canvas)
		ufo1.Render(canvas)
		player1.Render(canvas)
		particle.Render(canvas)
		' FPS timer
		If Millisecs()>oldTime
		   oldTime=Millisecs()+1000
		   FPS=frameCount ; frameCount=0
		Else
		   frameCount+=1
		EndIf
		'
	End Function
	'
	Function Died(canvas:Canvas)
		canvas.Clear(Color.Black)
		canvas.Color = New Color(1,1,1)
		canvas.DrawImage(Gfx.GameOver,0,0)
		canvas.Color = New Color(0,1,0)
		canvas.DrawText("PRESS SPACE / ESCAPE",158,GFX_Height-72)
		'
		' TODO: manual hi-score name entry not implemented
		' this part is not properly implemented
		'
		If Keyboard.KeyHit(Key.Space) Or Keyboard.KeyHit(Key.Escape)
			game.mode = game.TITLESCREEN
		Endif
		
	End Function
	'
	Function _Exit()
		game.mode = game.ENDGAME
	End Function
	
End Class

Function Main()

	New AppInstance
	
	New Game
	
	App.Run()
End




' Variable declarations
Const NUMALIENTYPES:Int=6 ' number of unique alien designs

'Create the main graphics window
'SeImageFont LoadImageFont("arial",32)


'********************************************************************
' load the media
'********************************************************************
Class Gfx
	Global Bkg:Image , Menu:Image , GameOver:Image
	Global Block:Image , playerBullet:Image 
	Global Player:Image[] = New Image[2]
	Global alien:Image[] = New Image[NUMALIENTYPES*2] 
	Global alienBullet:Image[] = New Image[3]
	Global Ufo:Image
	Global GetReady:Image
	
	Method New()
		Player = New Image[2]
	End Method
End Class 



Class Sfx
	Global PlayerShoot:Sound 
	Global AlienShoot:Sound
	Global AlienShunt:Sound
	Global PlayerDie:Sound
	Global AlienHit:Sound
	Global AlienDie:Sound
	Global BlockHit:Sound
	Global abBlockHit:Sound
	Global UfoAppear:Sound
	Global UfoDie:Sound
End Class


'********************************************************************
' Fields common to all game objects
'********************************************************************
Class CommonFields
	Field x:Float
	Field y:Float
	Field frame:Int
	Field speed:Float
	Field life:Int
End Class


'********************************************************************
' PARTICLE CODE
'********************************************************************
Class particle
	Global list := New List<particle>
	Field x     :Float
	Field y     :Float
	Field velx  :Float
	Field vely  :Float
	Field speed :Float
	Field life  :Int
	Field sz:Int
	Field r:Int,g:Int,b:Int
	'
	Method New()	
		Local angle := Rnd(1,360) 
		speed=2 ; life=50
		velx=Cos(angle)*(speed+Int(Rnd(-1,1)))
		vely=Sin(angle)*(speed+Int(Rnd(-1,1)))
		list.AddLast(Self)
	End Method
	'
	Function Explode(x:Float,y:Float,rad:Int,r:Int,g:Int,b:Int , size:Int=4)
		For Local looper:Int= 1 To 30
			Local p:particle = New particle
			p.position(x,y,rad)
			p.r=r ; p.g=g ; p.b=b
			p.sz=size
		Next
	End Function
	'
	Function position(x:Float,y:Float,rad:Int=5)
		For Local p:particle = EachIn particle.list
			If p.x=0 And p.y=0
				p.x=x+Rnd(-rad,rad+1)
				p.y=y+Rnd(-rad,rad+1)
			End If
		Next
	End Function
	'
	Function Update()
		For Local p:particle = EachIn particle.list
			p.x+=p.velx ;	p.y+=p.vely
			p.r-=5 ; p.g-=5 ; p.b-=5
			If p.r<0 p.r=0
			If p.g<0 p.g=0
			If p.b<0 p.b=0
			p.life-=1
			If p.life <= 0 particle.list.Remove(p)
		Next
	End Function
	'
	Function Render(canvas:Canvas)
		For Local p:particle = EachIn particle.list
			canvas.Color = New Color(p.r/255.0,p.g/255.0,p.b/255.0)
			canvas.DrawRect(p.x,p.y,p.sz,p.sz)
		Next
	End Function
End Class



'********************************************************************
' PLAYER CODE
''********************************************************************
Class player Extends CommonFields
	Field score:Int
	Field level:Int
	Field gunTimer:Int
	Field gunInterval:Int
	'
	Method New()
		gunTimer=Millisecs()
		gunInterval=170 ; life=3 ; speed=2.0
		level=0 ; score=0
		x=GFX_Width/2 ; y=GFX_Height-(Gfx.Player[0].Height)
	End Method
	'
	Method Update()
		' move player left
		If Keyboard.KeyDown(Key.Left) And player1.life>0
			x -= speed
			If x<1 Then x=1
		EndIf
		' move player right
		If Keyboard.KeyDown(Key.Right) And player1.life>0
			x+=speed
			If x>GFX_Width-(Gfx.Player[0].Width) Then x=GFX_Width-(Gfx.Player[0].Width)
		EndIf
		' shoot a player bullet
		If Keyboard.KeyDown(Key.Up) Or Keyboard.KeyDown(Key.Space)
			If Game.mode=Game.PLAYING And playerBullet.list.Count()<=2
				If Millisecs()-gunTimer >= gunInterval
					' fire off a new bullet
					playerBullet.Create(player1.x+(Gfx.Player[0].Width/2)-2,player1.y-2)
					gunTimer=Millisecs() 
					frame=6
				EndIf
			EndIf		
		EndIf
	End Method
	'	
	Method Render(canvas:Canvas)
		If game.mode=game.INJURED
			canvas.Color = New Color((128+Sin(Millisecs())*90)/255.0,0,0)
		Else
			canvas.Color = New Color(1,1,1)
		EndIf
		canvas.DrawImage(Gfx.Player[Sgn(frame)],x,y)
		If frame>0 Then frame-=1
		canvas.Alpha = 1.0
	End Method
End Class



'********************************************************************
' ALIEN CODE
'********************************************************************
Class alien Extends CommonFields
	Global list := New List<alien>
	Global animframe:Int
	Global animframetimer:Int
	Global MoveSpeed:Float
	Global gunTimer:Int
	Global gunInterval:Int
	Field value:Int
	Field level:Int
	Field count:Int
	Field counter:Int
	Field img:Image

	'
	Method New()
		gunTimer=Millisecs()
		gunInterval=700-(player1.level*50)
		count = 500+Rnd(2000)
		counter = Rnd(count)
		alien.list.AddLast(Self)
	End Method
	'
	Function ShuntAllDown()
		alien.MoveSpeed=-alien.MoveSpeed
		Sfx.AlienShunt.Play()
		For Local a:alien = EachIn alien.list
			a.x += alien.MoveSpeed 
			If game.mode = game.PLAYING Then a.y += 10
		Next
		If alien.MoveSpeed<0 Then alien.MoveSpeed-=.15 Else alien.MoveSpeed+=.15
	End Function
	'
	Function Update()
		If alien.list.Count()=0 Return
		For Local thisAlien:alien=EachIn alien.list
			If thisAlien.counter  > 0 And game.mode = game.PLAYING Then thisAlien.counter -=1
			' decide if this alien should shoot
			If Game.mode=Game.PLAYING
				'added semi-smart shooting ****************************************************
				If ImageInRange(thisAlien,player1,Gfx.alien[0],Gfx.Player[0]) And thisAlien.counter = 0
					alien.gunTimer=Millisecs()+Rnd(500)
					alienBullet.Create(thisAlien.x,thisAlien.y)
					thisAlien.counter = thisAlien.count
				'***********************************************************************************
				ElseIf Millisecs()-alien.gunTimer>alien.gunInterval
					alien.gunTimer=Millisecs()+Rnd(500)
					alienBullet.Create(thisAlien.x,thisAlien.y)
				EndIf
			EndIf
			' check if each block collides with alien
			For Local thisBlock:block = EachIn block.list
				If ImagesOverlap(thisBlock,thisAlien , Gfx.Block,Gfx.alien[0])
					thisBlock.y+=5 ; thisBlock.life-=2
					thisAlien.life-=1
					If thisAlien.life<=0
						thisAlien.Destroy()
						Return
					EndIf
				End If
			Next
			' check if player gets hit by alien
			If Game.mode=Game.PLAYING
				If ImagesOverlap(thisAlien,player1 , Gfx.alien[0],Gfx.Player[0])
					particle.Explode(player1.x,player1.y,3,255,40,255)
					particle.Explode(player1.x,player1.y,4,160,140,30)
					particle.Explode(player1.x,player1.y,5,16,140,230)
					Game.mode=Game.INJURED ; Game.TimeOut=180
					Sfx.PlayerDie.Play()
					player1.life-=1 ; thisAlien.Destroy()
					Return
				End If
			EndIf
			' move the aliens sideways
			thisAlien.x+=alien.MoveSpeed
			If alien.MoveSpeed<0 ' check left
				If (thisAlien.x+alien.MoveSpeed)<=0 Then alien.ShuntAllDown()
			Else ' check to the right
				If (thisAlien.x+alien.MoveSpeed)>=GFX_Width Then alien.ShuntAllDown()
			EndIf
			' check Y postion and life
			If thisAlien.y > GFX_Height Or thisAlien.life <= 0
				thisAlien.Destroy()
			EndIf
		Next
		' update animation frame
		alien.animframetimer+=1
		If alien.animframetimer=32
			alien.animframe=1-alien.animframe
			alien.animframetimer=0
		EndIf
	End Function
		'
	Function Render(canvas:Canvas)
		For Local thisAlien:alien=EachIn alien.list
			Select thisAlien.level
				Case 1 
					canvas.Color = New Color(185/255.0,1,155/255.0)
				Case 2 
					canvas.Color = New Color(1,1,0)
				Case 3 
					canvas.Color = New Color(1,0,0)
				Case 4 
					canvas.Color = New Color(0,1,1)
				Case 5
					canvas.Color = New Color(0,0,1)
				Case 6 
					canvas.Color = New Color(1,0,1)
			End Select
			canvas.DrawImage(Gfx.alien[6-thisAlien.level + (alien.animframe*NUMALIENTYPES)] , thisAlien.x , thisAlien.y )
		Next
	End Function
	'
	Method Destroy()
		Select level
			Case 1   particle.Explode(x,y,4,185,255,155)
			Case 2   particle.Explode(x,y,4,255,255,0)
			Case 3   particle.Explode(x,y,4,255,0,0)
			Case 4   particle.Explode(x,y,4,0,255,255)
			Case 5   particle.Explode(x,y,4,0,0,255)
			Case 6   particle.Explode(x,y,4,255,0,255)
		End Select
		alien.list.Remove(Self)
	End Method
End Class


'********************************************************************
' UFO CODE
'********************************************************************
Class ufo Extends CommonFields
	'
	Method Appear()
		If life<>0 Return
		x=-20 ; speed=1.4
		If Rnd(1)>.5
			speed=-speed ; x=GFX_Width+20
		EndIf
		y=24 
		life=1 
		Sfx.UfoAppear.Play()
	End Method
	'
	Method Update()
		If life=0
			If Int(Rnd(1000))=8 ufo1.Appear()
		EndIf
		x+=speed
		If x<-28 Or x>GFX_Width+28
			life=0 ; Return
		EndIf
	End Method
	'
	Method Render(canvas:Canvas)
		If life<>0
			canvas.Color = New Color(1,1,1)
			canvas.DrawImage(Gfx.Ufo,x,y)
		EndIf
	End Method
End Class


'********************************************************************'
' BLOCK CODE
'********************************************************************
Class block Extends CommonFields
	Global list := New List<block>
	Field origin:Int	
	'
	Function Init()
		block.list.Clear()
		For Local n:Int =1 To 3
			Local b:block = New block
			b.x=n*(GFX_Width/3)-Gfx.Block.Width*2
			b.y=GFX_Height-10-Gfx.Player[0].Height
			b.origin = GFX_Height-20-(Gfx.Player[0].Height)
			b.life=250
			block.list.AddLast(b)
		Next
	End Function
	'
	Function Render(canvas:Canvas)
		For Local thisBlock:block=EachIn block.list
			canvas.Color = New Color(1,thisBlock.life/255.0,thisBlock.life/255.0)
			canvas.DrawImage(Gfx.Block,thisBlock.x,thisBlock.y)
			If thisBlock.life <= 0 Then block.list.Remove (thisBlock)
		Next
	End Function
End Class


'********************************************************************
'	playerBullet CODE
'********************************************************************
Class playerBullet Extends CommonFields
	Global list := New List<playerBullet>
	' create a new player bullet
	Function Create(xPos:Int,yPos:Int)
		Local b:playerBullet=New playerBullet
		b.x=xPos ; b.y=yPos ; b.speed=3.8 ; b.life=1
		playerBullet.list.AddLast(b)
		Sfx.PlayerShoot.Play()
	End Function
	' check player bullets against blocks, aliens, and ufo
	' update the bullet position and draw it too
	Function Update(canvas:Canvas)
		canvas.Color = New Color(1,1,1)
		For Local thisBullet:playerBullet=EachIn playerBullet.list
			' check 'player bullets' collide with Blocks
				For Local thisBlock:block = EachIn block.list
					If ImagesOverlap(thisBullet,thisBlock , Gfx.playerBullet,Gfx.Block)
						thisBullet.life=0 ; thisBlock.life-=20
						If thisBlock.life <=0 Then thisBlock.life=0
						If thisBlock.y>thisBlock.origin
							thisBlock.y-=2
							If thisBlock.y<thisBlock.origin Then thisBlock.y=thisBlock.origin
						End If
						Sfx.BlockHit.Play()
						particle.Explode(thisBlock.x,thisBlock.y,1,150,150,100)
					End If
				Next
				' check 'player bullets' collide with aliens
				For Local thisAlien:alien = EachIn alien.list
					If ImagesOverlap(thisBullet,thisAlien , Gfx.playerBullet,Gfx.alien[0])
						thisBullet.life=0 ; thisAlien.life-=1
						If thisAlien.life <=0
							player1.score+=thisAlien.value
							thisAlien.Destroy()
							Sfx.AlienDie.Play()
						Else
							particle.Explode(thisAlien.x,thisAlien.y,48,155,155,155 , 2)
							Sfx.AlienHit.Play()
						EndIf
					End If
				Next
				' check 'player bullets' collide with ufo
				If ufo1.life<>0
					If ImagesOverlap(thisBullet,ufo1 , Gfx.playerBullet,Gfx.Ufo)
						player1.score+=50
						ufo1.life=0
						particle.Explode (ufo1.x,ufo1.y,3,$ff,$ff,$ff)
						Sfx.UfoDie.Play()
					EndIf
				EndIf
			' update 'player bullets' position
			thisBullet.y -= thisBullet.speed
			If thisBullet.y < 0 Or thisBullet.life = 0 playerBullet.list.Remove(thisBullet)
		Next
	End Function
	'
	Function Render(canvas:Canvas)
		For Local thisBullet:playerBullet=EachIn playerBullet.list
			canvas.DrawImage(Gfx.playerBullet,thisBullet.x,thisBullet.y)
		Next
	End Function
End Class



'********************************************************************
'	alienBullet CODE
'********************************************************************

Class alienBullet Extends CommonFields
	Global list := New List<alienBullet>
	' create a new alien bullet
	Function Create(posX:Int,posY:Int)
		Local ab:alienBullet=New alienBullet
		ab.x=posX ; ab.y=posY ; ab.life=1 ; ab.frame=0
		ab.speed+=(Game.SpeedIncrease+(player1.level)+Rnd(2.8))/1.0
		alienBullet.list.AddLast(ab)
		Sfx.AlienShoot.Play()
	End Function
	'
	Function Update(canvas:Canvas)
		canvas.Color = New Color(1,1,1)
		For Local thisalienBullet:alienBullet=EachIn alienBullet.list
		' check 'alien bullets' against blocks
			For Local thisBlock:block = EachIn block.list
				If ImagesOverlap(thisalienBullet,thisBlock , Gfx.alienBullet[0],Gfx.Block)
					thisalienBullet.life=0 ; thisBlock.life-=30
					If thisBlock.life<=0  thisBlock.life=0
					Sfx.abBlockHit.Play()
					particle.Explode(thisBlock.x,thisBlock.y,1,100,100,100)
				End If
			Next
			' check if player gets hit
			If Game.mode=Game.PLAYING
				If ImagesOverlap(thisalienBullet,player1 , Gfx.alienBullet[0],Gfx.Player[0])
					particle.Explode(player1.x,player1.y,3,255,40,255)
					particle.Explode(player1.x,player1.y,4,160,140,30)
					particle.Explode(player1.x,player1.y,5,16,140,230)
					Game.mode=Game.INJURED ; Game.TimeOut=180
					Sfx.PlayerDie.Play()
					player1.life-=1 ; thisalienBullet.life=0
				End If
			EndIf
			' update position
			thisalienBullet.y+=thisalienBullet.speed
			thisalienBullet.frame = (thisalienBullet.frame+1)Mod 3
			If thisalienBullet.y>GFX_Height Or thisalienBullet.life <= 0 Then alienBullet.list.Remove(thisalienBullet)
		Next
	End Function
	'
	Function Render(canvas:Canvas)
		canvas.Color = New Color(1,1,1)
		For Local thisalienBullet:alienBullet=EachIn alienBullet.list
			canvas.DrawImage(Gfx.alienBullet[thisalienBullet.frame],thisalienBullet.x,thisalienBullet.y)
		Next
	End Function
End Class

Class wait Extends CommonFields
	Field Duration:Int
	Field time:Int
	Field angle:Float
	
	Method New()
		x = GFX_Width/2
		y = GFX_Height/2
		Duration = 3000
		angle = 0
	End Method
	
	Method init()
		time = Millisecs()
		angle = 0
	End Method
	
	Method update()
		If time +Duration < Millisecs()game.mode = game.PLAYING
		angle = (angle + 1.57/Duration) Mod TwoPi

	End Method
	
	Method Render(canvas:Canvas)
		canvas.Scale(1+Sin(angle)*2,1+Sin(angle)*2)
		canvas.Color = New Color(1,1,1)
		canvas.DrawImage(Gfx.GetReady,x,y)
		canvas.Scale(New Vec2f(1,1))
	End Method
End Class
		
'********************************************************************
'	RETURN 'TRUE' IF TWO IMAGES ARE OVERLAPPING
'********************************************************************

Function ImagesOverlap:Int(i1:CommonFields,i2:CommonFields , img1:Image,img2:Image)
	' sprite 1 rect area
	Local x0:Int = i1.x - img1.Handle.X
	Local y0:Int = i1.y - img1.Handle.Y
	Local x1:Int = x0   + img1.Width
	Local y1:Int = y0   + img1.Height
	' sprite 2 rect area
	Local x2:Int = i2.x - img2.Handle.x
	Local y2:Int = i2.y - img2.Handle.y
	Local x3:Int = x2   + img2.Width
	Local y3:Int = y2   + img2.Height
	' check overlapping
	If x0 > x3 Or x1 < x2 Then Return False
	If y0 > y3 Or y1 < y2 Then Return False
	Return True
End Function

Function ImageInRange:Int(i1:CommonFields,i2:CommonFields,img1:Image,img2:Image)
	' sprite 1 pos
	Local x0:Int = i1.x - img1.Handle.X * 3
	Local x1:Int = x0   + img1.Width
	' sprite 2 pos
	Local x2:Int = i2.x - img2.Handle.X
	Local x3:Int = x2   +img2.Width
	' check overlapping
	If x0 > x3 Or x1 < x2 Then Return False
	Return True
End Function

'********************************************************************
'	ALIEN PATTERN WAVE LOADER
'********************************************************************

Function LoadWave(id:Int)
	Game.SpeedIncrease+=0.2
	alien.MoveSpeed=Game.SpeedIncrease
	Local px:Int , py:Int , w:String
	Local lvl:Float = id Mod 10
	For py = 1 To 6
		w =  data[py][lvl]
		For px =0 Until w.Length
			If w[px]=120 ' character 'x'
				Local a:alien=New alien
				a.x=px*Gfx.alien[0].Width ; a.y=24+(py*Gfx.alien[0].Height)
				a.value=6-py ; a.level=py ; a.life = 6 - (py+1)/1.5
			End If			
		Next
	Next
End Function




'********************************************************************
' ALIEN WAVE PATTERN DATA
'********************************************************************
'level 1
	
