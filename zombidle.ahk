#SingleInstance, Force
#NoEnv

CoordMode, Pixel, Screen
SetTitleMatchMode, 3
SendMode Input
SysGet, workArea, Monitor, 2

fullcurrentversion := "2.0.1"

exitThread := false
pauser := false
deal := false
slothonly := false
chestfound := false
hasfocus := false
mainscreen := false
autolevelon := false
autoabilityon := true
autoscrollon := true
autolevelon := true
autocheston := true

world := "unknown"
currenttab := "unknown"
checkworldtimer := 0
upgrademonstertimer := 0
lootarray := []

IniRead, clicks, stats.log, stats, clicks, 0
IniRead, scrolls, stats.log, stats, scrolls, 0

IniRead, skullmuliplier, stats.log, loot, skullmuliplier, 0
IniRead, minuslevel, stats.log, loot, minuslevel, 0
IniRead, crafttime, stats.log, loot, crafttime, 0
IniRead, fivediamond, stats.log, loot, fivediamond, 0
IniRead, tendiamond, stats.log, loot, tendiamond, 0
IniRead, doubledmg, stats.log, loot, doubledmg, 0
IniRead, chest3, stats.log, loot, chest3, 0

IniRead, guipos, privatesettings.ini, general, guipos, x0 y0
IniRead, browserposx, privatesettings.ini, general, browserposx, 0
IniRead, browserposy, privatesettings.ini, general, browserposy, 0
IniRead, windowtitle, privatesettings.ini, general, windowtitle, Zombidle
IniRead, windowwidth, privatesettings.ini, general, windowwidth, 995
IniRead, windowheight, privatesettings.ini, general, windowheight, 760
IniRead, graphiteenable, privatesettings.ini, general, graphiteenable, false
IniRead, graphitehost, privatesettings.ini, general, graphitehost, 127.0.0.1
IniRead, graphiteport, privatesettings.ini, general, graphiteport, 2003

IniRead, portal, privatesettings.ini, game, portal, 1

IniRead, idletime, privatesettings.ini, timer, idletime, 60000
IniRead, interval, privatesettings.ini, timer, interval, 50
IniRead, abilitytimer, privatesettings.ini, timer, abilitytimer, 325000
IniRead, switchworldinterval, privatesettings.ini, timer, switchworldinterval, 10
IniRead, upgradeinterval, privatesettings.ini, timer, upgradeinterval, 300
IniRead, upgradecarlinterval, privatesettings.ini, timer, upgradecarlinterval, 10

IniRead, autoclick, settings.ini, positions, autoclick
IniRead, worldtab, settings.ini, positions, worldtab
IniRead, monstertab, settings.ini, positions, monstertab
IniRead, scrollright, settings.ini, positions, scrollright
IniRead, scrollleft, settings.ini, positions, scrollleft
IniRead, tombking, settings.ini, positions, tombking
IniRead, maxbuy, settings.ini, positions, maxbuy
IniRead, buyskills, settings.ini, positions, buyskills

IniRead, lootpriolist, privatesettings.ini, lootpriolist
if (lootpriolist) {
	initcount:=0
	Loop, parse, lootpriolist, `n
		initcount++
	Loop, %initcount% {
		IniRead, prio%A_Index%, privatesettings.ini, lootpriolist, prio%A_Index%
		lootarray.Push(prio%A_Index%)
	}
} else {
	lootarray := ["tablet", "ring", "potion", "chalice", "king", "lich", "zombie", "bat", "mace", "plague", "specter", "squid", "axe", "sword"]
	for k, v in lootarray {
		IniWrite, %v%, privatesettings.ini, lootpriolist, prio%A_Index%
	}
}

checkupdate()

SetTimer, AutoFire, %interval%
SetTimer, guiupdate, 1000
SetTimer, saveini, 60000
SetTimer, checkforgame, Off
SetTimer, abilities, %abilitytimer%
if graphiteenable = true
	SetTimer, savechests, 600000

abilitycountown := Ceil(abilitytimer / 1000)

;=============================
;======= GUI =================
;=============================

Gui, +AlwaysOnTop -SysMenu +Owner
Gui, Add, Text, x12 y30 , Click:
Gui, Add, Radio, xp+75 yp gclicker vautoclickeron checked, On
Gui, Add, Radio, xp+50 yp gclicker, Off
Gui, Add, Text, xp+70 yp, find chests:
Gui, Add, Radio, xp+75 yp gautochest vautocheston checked, On
Gui, Add, Radio, xp+50 yp gautochest, Off
Gui, Add, Text, x12 yp+20, Buy monster:
Gui, Add, Radio, xp+75 yp gautolevel vautolevelon checked, On
Gui, Add, Radio, xp+50 yp gautolevel, Off
Gui, Add, Text, x12 yp+20, use abilities:
Gui, Add, Radio, xp+75 yp gautoability vautoabilityon checked, On
Gui, Add, Radio, xp+50 yp gautoability, Off
Gui, Add, Text, x12 yp+20, click scrolls:
Gui, Add, Radio, xp+75 yp gautoscroll vautoscrollon checked, On
Gui, Add, Radio, xp+50 yp gautoscroll, Off
Gui, Add, GroupBox, x2 y9 w180 h100 , automatic actions
Gui, Add, GroupBox, xp+190 y9 w180 h100 , world actions
Gui, Add, Text, vStatus x12 w400, Starting Bot!
Gui, Add, Text,vstatus2 x12 w400,
Gui, Add, Text,vstatus4 x12 w400,
Gui, Add, Button, x12 w100 gPauseButton Default, pause Bot
Gui, Add, Button, xp+300 w100 gResetButton Default, Reset World
Gui, Color, daffb4
Gui, Show, %guipos% NoActivate, Zombidle Status

logger("[GAME] Bot initialized. Start generalLoop")
OnExit("saveinifunc")

generalLoop()

return

;=============================
;======= Timers ==============
;=============================

AutoFire:
	Critical
	ControlClick, %autoclick%, %windowtitle%,,,, Pos NA
	clicks++
return

abilities:
	Critical
	abilitycountown := Ceil(abilitytimer / 1000)
	if (!autoabilityon or pauser = true) {
		return
	}

	if (slothonly = true) {
		loop, 4 {
			ControlSend,, {1 down}{1 up}, %windowtitle%
			sleep, 50
		}
		logger("[PROGRESS] Start only Sloths Form")
		slothonly := false
	} else {
		loop, 4 {
			ControlSend,, {1 down}{1 up}, %windowtitle%
			sleep, 50
			ControlSend,, {2 down}{2 up}, %windowtitle%
			sleep, 50
			ControlSend,, {3 down}{3 up}, %windowtitle%
			sleep, 50
			ControlSend,, {4 down}{4 up}, %windowtitle%
			sleep, 50
			ControlSend,, {5 down}{5 up}, %windowtitle%
			sleep, 50
			ControlSend,, {6 down}{6 up}, %windowtitle%
			sleep, 50
			ControlSend,, {7 down}{7 up}, %windowtitle%
			sleep, 50
		}
		logger("[PROGRESS] Start all abilities")
		slothonly := true
	}
return

checkforgame:
	checkgame("timer")
return

saveini:
	saveinifunc()
return

guiupdate:
	abilitycountown--
	GuiControl,,Status2, Clicks: %clicks%    Scrolls: %scrolls%     Ability countdown: %abilitycountown%
	GuiControl,,Status4, Upgrading in: %upgrademonstertimer% (%upgradeinterval%) - Check World in:  %checkworldtimer% (%switchworldinterval%) - current tab: %currenttab%
return

savechests:
	T2 = %A_NowUTC%
	T2 -= 19700101000000,seconds
	for k, v in lootarray {
		if (%v%_loot >= 1) {
			temploot := %v%_loot
			Run %comspec% /c "echo zombidle.chest.%v% %temploot% %T2% | nc.exe %graphitehost% %graphiteport%",, Hide
		}

		%v%_loot := 0
	}
return

;=============================
;======= Functions ===========
;=============================

generalLoop() {
	global
	; WinMove, %windowtitle%,, %browserposx%, %browserposy%, %windowwidth%, %windowheight%
	logger("[GAME] GeneralLoop started")
	loop {
		checkgame("looper")
		if (exitThread) OR (pauser) {
			SetTimer, AutoFire, Off
			sleep 1000
			continue
		}
		WinGetPos, posx, posy, endposx, endposy, %windowtitle%
		MouseGetPos, , , id, control
		WinGetClass, class, ahk_id %id%
		WinGetTitle, title, ahk_id %id%

		if (class = "ApolloRuntimeContentWindow" and title = "Zombidle") {
			if (A_TimeIdle>=idletime) {
				GuiControl,,Status, Active! Mouse pointer in zombidle window but inactive for more than %idletime% seconds.
				hasfocus := false
				activateautofire()
			} else {
				GuiControl,,Status, Inactive! Mouse pointer in zombidle window.
				hasfocus := true
				SetTimer, AutoFire, Off
			}
		} else {
			activateautofire()
			GuiControl,,Status, Active!
			hasfocus := false
		}
		if (hasfocus = false) {
			lootprio()
			upgrademonster()
			checkworld()
			; scrollHandle()
		}
		sleep 1000
	}
}

checkgame(stat) {
	global
	if (stat = "timer") {
			if WinExist(windowtitle) {
				GuiControl,,Status, Zombidle window found.
				exitThread := false
				SetTimer, checkforgame, Off
			} else {
				logger("[GAME] **** ERROR **** - Checkgame (timer) - Zombilde window not found")
			}
	}
	if (stat = "looper") {
		if NOT WinExist(windowtitle) {
			GuiControl,,Status, Zombidle window not found. Pause.
			exitThread := true
			SetTimer, checkforgame, 60000, On
		}
	}
}

switchworld(curworld, reset:=false) {
	global
	SetTimer, AutoFire, Off
	currenttab := gettab()
	if (currenttab != "worldtab") {
		sleep 1000
		ControlClick, %worldtab% ,%windowtitle%,,,, Pos NA
		sleep 1000
	}

	if (autocheston and curworld != "new") {
		collectchests(curworld)
	}

	logger("[PROGRESS] Switching world")

	sleep, 3000
	loop, 15 {
		ControlClick, %scrollleft%, %windowtitle%,,,, Pos NA
		sleep 75
	}

	sleep 1000

	if (curworld = "new") {
		ControlClick, x600 y670,%windowtitle%,,,, Pos NA
		sleep 1000
		ControlClick, x400 y400,%windowtitle%,,,, Pos NA
	}

	if (curworld = "1") {
		ControlClick, x670 y515,%windowtitle%,,,, Pos NA
		sleep 1000
		ControlClick, x330 y700,%windowtitle%,,,, Pos NA
	}
	if (curworld = "2") {
		ControlClick, x590 y700,%windowtitle%,,,, Pos NA
		sleep 1000
		ControlClick, x230 y430,%windowtitle%,,,, Pos NA
	}
	if (curworld = "3") {
		ControlClick, x550 y500,%windowtitle%,,,, Pos NA
		sleep 1000
		ControlClick, x600 y300,%windowtitle%,,,, Pos NA
	}
	if (curworld = "4") {
		if (reset = false) {
			ControlClick, x600 y670,%windowtitle%,,,, Pos NA
			sleep 1000
			ControlClick, x690 y560,%windowtitle%,,,, Pos NA
		} else {
			loop, 5 {
				ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
				sleep 75
			}
			ControlClick, x940 y460,%windowtitle%,,,, Pos NA
			sleep 1000
		}
	}
	if (curworld = "5") {
		if (reset = false) {
			ControlClick, x600 y670,%windowtitle%,,,, Pos NA
			sleep 1000
			ControlClick, x690 y560,%windowtitle%,,,, Pos NA
		} else {
			; loop, 5 {
				; ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
				; sleep 75
			; }
			ControlClick, x880 y700,%windowtitle%,,,, Pos NA
			sleep 1000
		}
	}

	if (reset = true) {
		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/reset.png
		if (ErrorLevel = 0) {
			logger("[PROGRESS] Resetting world")
			ControlClick, x250 y700,%windowtitle%,,,, Pos NA
			sleep 1000
			ControlClick, x550 y520,%windowtitle%,,,, Pos NA
			sleep 5000
			switchworld("new")
		}
	} else {
		sleep 1000
		ControlClick, x700 y530,%windowtitle%,,,, Pos NA
		sleep 500
	}

	activateautofire()
}

collectchests(curworld) {
	global
	logger("[PROGRESS] Collecting chest")

	loop, 15 {
		ControlClick, %scrollleft%, %windowtitle%,,,, Pos NA
		sleep 75
	}
	if (curworld = "1") {
		loop, 3 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}
		sleep 500
		ControlClick, x560 y606,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x860 y620,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x860 y620,%windowtitle%,,,, Pos NA
		sleep 5000
		loop, 3 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}
		ControlClick, x864 y451,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x864 y451,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x874 y532,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x874 y532,%windowtitle%,,,, Pos NA
		sleep 5000
		loop, 5 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}
		sleep 500
		ControlClick, x911 y470,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		; ControlClick, x911 y470,%windowtitle%,,,, Pos NA
		; sleep 5000
		; loop, 30 {
			; ControlClick, %autoclick%, %windowtitle%,,,, Pos NA
			; sleep 100
		; }
		; ControlClick, x842 y521,%windowtitle%,,,, Pos NA
		; sleep 5000
		; lootprio()
		; sleep 1000
	}

	if (curworld = "2") {
		ControlClick, x544 y515,%windowtitle%,,,, Pos NA
		sleep 5000
		loop, 9 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}
		ControlClick, x521 y379,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x521 y379,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x904 y636,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x904 y636,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x850 y580,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x904 y636,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x850 y580,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		; sleep 5000
		; ControlClick, x904 y636,%windowtitle%,,,, Pos NA
		; sleep 5000
		; loop, 30 {
			; ControlClick, %autoclick%, %windowtitle%,,,, Pos NA
			; sleep 100
		; }
		; ControlClick, x904 y636,%windowtitle%,,,, Pos NA
		; sleep 5000
	}

	if (curworld = "3") {
		ControlClick, x513 y596,%windowtitle%,,,, Pos NA
		sleep 5000
		loop, 3 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}
		ControlClick, x702 y365,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x702 y365,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x954 y621,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x954 y621,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x809 y400,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		; ControlClick, x809 y400,%windowtitle%,,,, Pos NA
		; sleep 1000
		; loop, 30 {
			; ControlClick, %autoclick%, %windowtitle%,,,, Pos NA
			; sleep 100
		; }
		; ControlClick, x954 y621,%windowtitle%,,,, Pos NA
		; sleep 5000
		; lootprio()
		; sleep 1000
	}

	if (curworld = "4") {
		loop, 5 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}
		ControlClick, x520 y460,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x670 y670,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x670 y670,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x960 y650,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		ControlClick, x960 y650,%windowtitle%,,,, Pos NA
		sleep 5000
		ControlClick, x670 y670,%windowtitle%,,,, Pos NA
		sleep 5000
		lootprio()
		sleep 5000
		; ControlClick, x670 y670,%windowtitle%,,,, Pos NA
		; sleep 1000
		; loop, 6 {
			; ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			; sleep 75
		; }
		; ControlClick, x900 y400,%windowtitle%,,,, Pos NA
		; sleep 5000
		; loop, 30 {
			; ControlClick, %autoclick%, %windowtitle%,,,, Pos NA
			; sleep 100
		; }
		; ControlClick, x700 y520,%windowtitle%,,,, Pos NA
		; sleep 5000
		; lootprio()
		; sleep 1000
	}

}

gettab() {
	global
	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/monstertab.png
	if (ErrorLevel = 0) {
		tab := "monstertab"
	} else {
		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/worldtab.png
		if (ErrorLevel = 0) {
			tab := "worldtab"
		} else {
			tab := "unknown"
		}
	}
	return tab
}

checkworld() {
	global
	checkworldtimer++
	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/tohell.png
	if (ErrorLevel = 0) {
		mainscreen := true
	} else {
		mainscreen := false
	}

	if (checkworldtimer >= switchworldinterval) {
		checkworldtimer := 0
		world := "unknown"
		currenttab := gettab()

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world1complete.png
		if (ErrorLevel = 0) {
			sleep, 4000
			ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world1complete.png
			if (ErrorLevel = 0) {
				world := "1"
				logger("[PROGRESS] World 1 is complete.")
			}
		} else {
			ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world2complete.png
			if (ErrorLevel = 0) {
				sleep 4000
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world2complete.png
				if (ErrorLevel = 0) {
					world := "2"
					logger("[PROGRESS] World 2 is complete.")
				}
			} else {
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world3complete.png
				if (ErrorLevel = 0) {
					world := "3"
					logger("[PROGRESS] World 3 is complete.")
				} else {
					ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world4complete.png
					if (ErrorLevel = 0) {
						sleep 4000
						ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world4complete.png
						if (ErrorLevel = 0) {
							world := "4"
							logger("[PROGRESS] World 4 is complete.")
						}
					}
				}
			}
		}
		if (world != "unknown") {
			switchworld(world)
		}
	}
}

upgrademonster() {
	global
	upgrademonstertimer++
	if (!autolevelon) {
		return
	}

	if (Mod(upgrademonstertimer, upgradecarlinterval) = 0) {
		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/upgrade.png
		if (ErrorLevel = 0) {
			logger("[PROGRESS] Leveling Carl.")
			SetTimer, AutoFire, Off
			sleep 1000
			clickx := FoundX - posx + 0
			clicky := FoundY - posy + 0
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
			sleep 1000
			activateautofire()

		}
	}

	if (upgrademonstertimer >= upgradeinterval) {
		upgrademonstertimer := 0
		SetTimer, AutoFire, Off

		logger("[PROGRESS] Leveling monsters")
		currenttab := gettab()
		if (currenttab != "monstertab") {
			sleep 500
			ControlClick, %monstertab% ,%windowtitle%,,,, Pos NA
			logger("[PROGRESS] Switching to Monstertab")

			sleep 500
		}

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/maxbuy.png
		if (ErrorLevel != 0) {
			logger("[PROGRESS] Set buy size to MAX")
			loop, 10 {
				ControlClick, %maxbuy% ,%windowtitle%,,,, Pos NA
				sleep, 100
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/maxbuy.png
			} until (ErrorLevel = 0)
		}

		loop, 15 {
			ControlClick, %scrollright%, %windowtitle%,,,, Pos NA
			sleep 75
		}

		ControlClick, %buyskills%, %windowtitle%,,,, Pos NA
		sleep 75

		ControlClick, %scrollleft%, %windowtitle%,,,, Pos NA
		sleep 250

		sleep 75

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/upgrade.png
		if (ErrorLevel = 0) {
			logger("[PROGRESS] Leveling Carl.")
			clickx := FoundX - posx + 0
			clicky := FoundY - posy + 0
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
		}
		sleep 75

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/upgradetombking.png
		if (ErrorLevel = 0) {
			logger("[PROGRESS] Leveling Tomb King.")
			clickx := FoundX - posx + 0
			clicky := FoundY - posy + 160
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
			sleep 75
			clicky += 70
			loop, 2 {
				ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
				sleep 100
			}
		}
		sleep 75

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/upgradesquid.png
		if (ErrorLevel = 0) {
			logger("[PROGRESS] Leveling Squid.")
			clickx := FoundX - posx + 0
			clicky := FoundY - posy + 160
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
			sleep 75
			clicky += 70
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
		}

		activateautofire()
	}
}

scrollHandle() {
	global
	if (!autoscrollon) {
		return
	}
	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/thedeal.png
	if (ErrorLevel = 0) {
		logger("[LOOT] Found deal without clicking scroll")
		deal := true
	}
	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/scroll.png
	if (ErrorLevel = 0 or deal = true) {
		SetTimer, AutoFire, Off
		if (deal = false) {
			logger("[LOOT] Scroll found")
			clickx := FoundX - posx + 20
			clicky := FoundY - posy + 20
			loop {
				ControlClick, x%clickx% y%clicky%,%windowtitle%,,,, Pos NA
				sleep, 100
				logger("[LOOT] Clicking scroll")
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/scroll.png
				if (ErrorLevel = 1) {
					ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/scrollinactive.png
				}
			} until (ErrorLevel = 1)
			sleep 2000
		}
		identifiyloot()
		sleep, 1000
		loop, 5 {
			ControlClick, x660 y562,%windowtitle%,,,, Pos NA
			sleep, 100
		}
		if (graph != "10_Diamonds") {
			sleep 18000
			loop, 5 {
				ControlClick, x680 y246,%windowtitle%,,,, Pos NA
				sleep, 100
			}
		}
		scrolls++

		activateautofire()
		deal := false
	}
}

activateautofire() {
	global
	if (pauser = true or autoclickeron = false or mainscreen = false) {
		return
	} else {
		SetTimer, AutoFire, %interval%, On
	}
}

logger(logtext) {
	FileAppend ,  %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec% %logtext%`n, status.log
}

identifiyloot() {
	global
	T = %A_NowUTC%
	T -= 19700101000000,seconds
	graph := "null"
	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/skullmultiplier.png
	if (ErrorLevel = 0) {
		logger("[LOOT] x4 Skulls found")
		skullmuliplier++
		graph := "x4_Skull"
	} else {
		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/minushouse.png
		if (ErrorLevel = 0) {
			logger("[LOOT] -5 level found")
			minuslevel++
			graph := "5_Level"
		} else {
			ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/craftboost.png
			if (ErrorLevel = 0) {
				logger("[LOOT] reduced 4h crafting time")
				crafttime++
				graph := "craftingTime"
			} else {
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/diamonds.png
				if (ErrorLevel = 0) {
					logger("[LOOT] 5 diamonds found")
					fivediamond++
					graph := "5_Diamonds"
				} else {
					ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/specialadd.png
					if (ErrorLevel = 0) {
						logger("[LOOT] 10 diamonds found")
						tendiamond++
						graph := "10_Diamonds"
					} else {
						ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/doubledmg.png
						if (ErrorLevel = 0) {
							logger("[LOOT] x2 DMG")
							doubledmg++
							graph := "x2_DMG"
						} else {
							ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/3star.png
							if (ErrorLevel = 0) {
								logger("[LOOT] 3 star chest found")
								chest3++
								graph := "Chest"
								chestfound := true
							} else {
								logger("[LOOT] **** ERROR **** - could not identify loot")
								TrayTip, WTF Loot, WTF Loot, 10, 1
								graph := "NA"
							}
						}
					}
				}
			}
		}
	}

	if graphiteenable = true
		Run %comspec% /c "echo zombidle.loot.%graph% 1 %T% | nc.exe %graphitehost% %graphiteport%",, Hide
}

lootprio() {
	global
	if (pauser = true) {
		return
	}

	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/reward.png
	if (ErrorLevel = 0) {
		knownloot := false
		logger("[LOOT] found chest loot.")
		for k, v in lootarray {
			quality = 0
			loop, 3 {
				quality++
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, *50 imgs/lootprio/%v%_%quality%.png
				if (ErrorLevel = 0) {
					logger("[LOOT] " . v . "_" . quality . " found.")
					%v%_loot++
					clickx := FoundX - posx + 60
					clicky := FoundY - posy + 240
					ControlClick, x%clickx% y%clicky%,%windowtitle%,,,, Pos NA
					knownloot := true
					break 2
				}
			}
		}
		if (knownloot = false) {
			logger("[LOOT] could not identify chest loot. Taking the first item")
		}
	}
}

saveinifunc() {
	global
	IniWrite, %clicks%, stats.log, stats, clicks
	IniWrite, %scrolls%, stats.log, stats, scrolls
	IniWrite, %skullmuliplier%, stats.log, loot, skullmuliplier
	IniWrite, %minuslevel%, stats.log, loot, minuslevel
	IniWrite, %crafttime%, stats.log, loot, crafttime
	IniWrite, %fivediamond%, stats.log, loot, fivediamond
	IniWrite, %tendiamond%, stats.log, loot, tendiamond
	IniWrite, %doubledmg%, stats.log, loot, doubledmg
	IniWrite, %chest3%, stats.log, loot, chest3

	Gui +lastfound
	WinGetPos, x, y
	IniWrite, x%x% y%y%, privatesettings.ini, general, guipos
	if WinExist(windowtitle) {
		WinGetPos, posx, posy, endposx, endposy, %windowtitle%
		IniWrite, %posx%, privatesettings.ini, general, browserposx
		IniWrite, %posy%, privatesettings.ini, general, browserposy
		IniWrite, %endposx%, privatesettings.ini, general, windowwidth
		IniWrite, %endposy%, privatesettings.ini, general, windowheight
	}

	IniWrite, %graphitehost%, privatesettings.ini, general, graphitehost
	IniWrite, %graphiteport%, privatesettings.ini, general, graphiteport
	IniWrite, %graphiteenable%, privatesettings.ini, general, graphiteenable
	IniWrite, "%windowtitle%", privatesettings.ini, general, windowtitle

	IniWrite, %portal%, privatesettings.ini, game, portal

	IniWrite, %idletime%, privatesettings.ini, timer, idletime
	IniWrite, %interval%, privatesettings.ini, timer, interval
	IniWrite, %abilitytimer%, privatesettings.ini, timer, abilitytimer
	IniWrite, %switchworldinterval%, privatesettings.ini, timer, switchworldinterval
	IniWrite, %upgradeinterval%, privatesettings.ini, timer, upgradeinterval
	IniWrite, %upgradecarlinterval%, privatesettings.ini, timer, upgradecarlinterval
}

checkupdate() {
	global
	logger("[GAME] Checking for Bot Updates on Github")
	StringSplit, partcurrentversion, fullcurrentversion, ".", .

	url:="https://github.com/cottiAC/zombidleBot/releases/latest"
	fileName := "tmpversion.txt"

	UrlDownloadToFile, %url%, %A_ScriptDir%\%fileName%
	If (!ErrorLevel) {
		FileRead, html, %A_ScriptDir%\%fileName%
		FileDelete, %A_ScriptDir%\%fileName%
		Loop , parse , html , `n
		{
			line := A_LoopField
			if line contains <title>
				RegExMatch(line, "Release v(.*) ", latestversion)
		}

		fulllatestversion := RegExReplace(latestversion1, " .*", "")
		StringSplit, partlatestversion, fulllatestversion, ".", .
		logger("[GAME] Current Bot version: " . fullcurrentversion)
		logger("[GAME] Latest Bot version on Github: " . fulllatestversion)

		if (partlatestversion1 > partcurrentversion1 or partlatestversion2 > partcurrentversion2 or partlatestversion3 > partcurrentversion3) {
					logger("[GAME] New release available!")
					Gui, UpdateNotification:Font,, Consolas
					Gui, UpdateNotification:Add, GroupBox, w300 h80 cGreen, Update available!
					Gui, UpdateNotification:Add, Text, x20 yp+20, Installed version:
					Gui, UpdateNotification:Add, Text, x150 yp+0,  %fullcurrentversion%
					Gui, UpdateNotification:Add, Text, x20 y+0, Latest version:
					Gui, UpdateNotification:Add, Text, x150 yp+0,  %fulllatestversion%
					Gui, UpdateNotification:Add, Link, x+20 yp+0 cBlue, <a href="%url%">Download it here</a>
					Gui, UpdateNotification:Add, Button, gCloseUpdateWindow, Close
					Gui, UpdateNotification:Show, w320 xCenter yCenter, Update
					WinWaitClose, Update
		} else {
			logger("[GAME] No new release version found")
		}
	} else {
		logger("[GAME] Could not download version info from github")
	}
}

;=============================
;=== Buttons and Controlls ===
;=============================

PauseButton:
	if (pauser = false) {
		SetTimer, AutoFire, Off
		pauser := true
		Gui, Color, EEAA99
		logger("[GAME] Pause button pressed")
		return
	}
	if (pauser = true) {
		activateautofire()
		SetTimer, abilities, %abilitytimer%, On
		pauser := false
		Gui, Color, daffb4
		logger("[GAME] Resuming")

	}
return

ResetButton:
	numportal := Ceil(portal / 2)
	switchworld(numportal, true)
return

CloseUpdateWindow:
	Gui, Cancel
Return

clicker:
	GuiControlGet, autoclickeron
	if autoclickeron
		activateautofire()
	else
		SetTimer, AutoFire, Off
return

autolevel:
GuiControlGet, autolevelon

autoability:
GuiControlGet, autoabilityon

autochest:
GuiControlGet, autocheston

autoscroll:
GuiControlGet, autoscrollon
