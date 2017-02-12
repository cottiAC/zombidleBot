#SingleInstance, Force
#NoEnv

CoordMode, Pixel, Screen
SetTitleMatchMode, 3
SendMode Input
SysGet, workArea, Monitor, 2

exitThread := false
pauser := false
deal := false
slothonly := false
chestfound := false
hasfocus := false
autolevel := false
mainscreen := false
autoabilityon := true
autolevelon := true

world := "unknown"
currenttab := "unknown"
checkworldtimer := 0
upgrademonstertimer := 0

IniRead, clicks, stats.log, stats, clicks, 0
IniRead, scrolls, stats.log, stats, scrolls, 0

IniRead, skullmuliplier, stats.log, loot, skullmuliplier, 0
IniRead, minuslevel, stats.log, loot, minuslevel, 0
IniRead, crafttime, stats.log, loot, crafttime, 0
IniRead, fivediamond, stats.log, loot, fivediamond, 0
IniRead, tendiamond, stats.log, loot, tendiamond, 0
IniRead, doubledmg, stats.log, loot, doubledmg, 0
IniRead, chest3, stats.log, loot, chest3, 0

IniRead, windowtitle, settings.ini, general, windowtitle
IniRead, windowwidth, settings.ini, general, windowwidth
IniRead, windowheight, settings.ini, general, windowheight
IniRead, graphitehost, settings.ini, general, graphitehost
IniRead, graphiteport, settings.ini, general, graphiteport
IniRead, idletime, settings.ini, game, idletime
IniRead, interval, settings.ini, game, interval
IniRead, abilitytimer, settings.ini, game, abilitytimer
IniRead, switchworldinterval, settings.ini, game, switchworldinterval
IniRead, upgradeinterval, settings.ini, game, upgradeinterval
IniRead, upgradecarlinterval, settings.ini, game, upgradecarlinterval
IniRead, autoclick, settings.ini, positions, autoclick
IniRead, worldtab, settings.ini, positions, worldtab
IniRead, monstertab, settings.ini, positions, monstertab
IniRead, scrollright, settings.ini, positions, scrollright
IniRead, scrollleft, settings.ini, positions, scrollleft
IniRead, carl, settings.ini, positions, carl
IniRead, tombking, settings.ini, positions, tombking
IniRead, maxbuy, settings.ini, positions, maxbuy
IniRead, buyskills, settings.ini, positions, buyskills

SetTimer, AutoFire, %interval%
SetTimer, guiupdate, 1000
SetTimer, saveini, 60000
SetTimer, checkforgame, Off
SetTimer, abilities, %abilitytimer%

abilitycountown := Ceil(abilitytimer / 1000)

;=============================
;======= GUI =================
;=============================

xgui := A_ScreenWidth + A_ScreenWidth - 400
ygui := A_ScreenHeight - 260

Gui, +AlwaysOnTop -SysMenu +Owner
Gui, Add, Text, x12 y30 , Click:
Gui, Add, Radio, xp+120 yp gclicker vautoclickeron checked, On
Gui, Add, Radio, xp+50 yp gclicker, Off
Gui, Add, Text, x12 yp+20, Buy monster upgrades:
Gui, Add, Radio, xp+120 yp gautolevel vautolevelon checked, On
Gui, Add, Radio, xp+50 yp gautolevel, Off
Gui, Add, Text, x12 yp+20, use abilities:
Gui, Add, Radio, xp+120 yp gautoability vautoabilityon checked, On
Gui, Add, Radio, xp+50 yp gautoability, Off
Gui, Add, GroupBox, x2 y9 w230 h80 , automatic actions
Gui, Add, Text, vStatus x12 w400, Starting Bot!
Gui, Add, Text,vstatus2 x12 w400,
Gui, Add, Text,vstatus3 x12 w400,
Gui, Add, Text,vstatus4 x12 w400,
Gui, Add, Button, x12 w100 gPauseButton Default, pause Bot
Gui, Color, daffb4
Gui, Show, x%xgui% y%ygui% NoActivate, Zombidle Status

logger("[GAME] Bot initialized. Start generalLoop")

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
	if (!autoabilityon) {
		return
	}

	if (slothonly = true) {
		loop, 4 {
			ControlSend,, 1, %windowtitle%
			sleep, 50
		}
		logger("[PROGRESS] Start only Sloths Form")
		slothonly := false
	} else {
		loop, 4 {
			ControlSend,, 1, %windowtitle%
			sleep, 50
			ControlSend,, 2, %windowtitle%
			sleep, 50
			ControlSend,, 3, %windowtitle%
			sleep, 50
			ControlSend,, 4, %windowtitle%
			sleep, 50
			ControlSend,, 5, %windowtitle%
			sleep, 50
			ControlSend,, 6, %windowtitle%
			sleep, 50
			ControlSend,, 7, %windowtitle%
		}
		logger("[PROGRESS] Starte all abilities")
		slothonly := true
	}
	abilitycountown := Ceil(abilitytimer / 1000)
return

checkforgame:
	checkgame("timer")
return

saveini:
	IniWrite, %clicks%, stats.log, stats, clicks
	IniWrite, %scrolls%, stats.log, stats, scrolls
	IniWrite, %skullmuliplier%, stats.log, loot, skullmuliplier
	IniWrite, %minuslevel%, stats.log, loot, minuslevel
	IniWrite, %crafttime%, stats.log, loot, crafttime
	IniWrite, %fivediamond%, stats.log, loot, fivediamond
	IniWrite, %tendiamond%, stats.log, loot, tendiamond
	IniWrite, %doubledmg%, stats.log, loot, doubledmg
	IniWrite, %chest3%, stats.log, loot, chest3
return

guiupdate:
	if (pauser = false) {
		abilitycountown--
	}
	GuiControl,,Status2, Clicks: %clicks%    Scrolls: %scrolls%     Ability countdown: %abilitycountown%
	GuiControl,,Status4, Upgrading in: %upgrademonstertimer% (%upgradeinterval%) - Check World in:  %checkworldtimer% (%switchworldinterval%) - current tab: %currenttab%
return

;=============================
;======= Functions ===========
;=============================

generalLoop() {
	global
	WinMove, %windowtitle%,, A_ScreenWidth, 0, %windowwidth%, %windowheight%
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
		upgrademonster()
		checkworld()
		scrollHandle()

		if (control = "GeckoFPSandboxChildWindow1") {
			if (A_TimeIdle>=idletime) {
				GuiControl,,Status, Active! Mouse pointer in zombidle window but inactive for more than %idletime% seconds.
				hasfocus := false
				activateautofire()
			} else {
				GuiControl,,Status, Inactive! Mouse pointer in zombidle window.
				hasfocus := true
				SetTimer, AutoFire, Off
			}
		} else if (class = "MozillaWindowClass" or class = "MozillaDropShadowWindowClass" or class = "MozillaDialogClass") {
			if (A_TimeIdle>=idletime) {
				activateautofire()
				GuiControl,,Status, Active! Mouse pointer in some browser window but inactive for more than %idletime% seconds.
				hasfocus := false
			} else {
				SetTimer, AutoFire, Off
				waittime := Ceil(A_TimeIdle / 1000)
				GuiControl,,Status, Inactive! Mouse pointer in some browser window. Idle since: %waittime% seconds.
				hasfocus := true
				SetTimer, AutoFire, Off
			}
		} else {
			activateautofire()
			GuiControl,,Status, Active!
			hasfocus := false
		}
		if (chestfound = false and hasfocus = false) {
			lootprio()
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

switchworld(curworld) {
	global
	logger("[PROGRESS] Switching world")
	SetTimer, AutoFire, Off
	if (currenttab != "worldtab") {
		sleep 1000
		ControlClick, %worldtab% ,%windowtitle%,,,, Pos NA
		sleep 1000
	}

	loop, 15 {
		ControlClick, %scrollleft%, %windowtitle%,,,, Pos NA
	}

	sleep 1000
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
	sleep 1000
	ControlClick, x700 y530,%windowtitle%,,,, Pos NA
	sleep 500
	activateautofire()
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

	if (checkworldtimer = switchworldinterval) {
		checkworldtimer := 0
		world := "unknown"
		currenttab := gettab()

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world1complete.png
		if (ErrorLevel = 0) {
			world := "1"
			logger("[PROGRESS] World 1 is complete.")
		} else {
			ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world2complete.png
			if (ErrorLevel = 0) {
				world := "2"
				logger("[PROGRESS] World 2 is complete.")
				} else {
				ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/world3complete.png
				if (ErrorLevel = 0) {
					world := "3"
					logger("[PROGRESS] World 3 is complete.")
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
			clickx := FoundX - posx + 0
			clicky := FoundY - posy + 0
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
		}
	}

	if (upgrademonstertimer = upgradeinterval) {
		upgrademonstertimer := 0
		SetTimer, AutoFire, Off

		logger("[PROGRESS] Leveling monsters")
		currenttab := gettab()
		if (currenttab != "monstertab") {
			sleep 500
			ControlClick, %monstertab% ,%windowtitle%,,,, Pos NA
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

		ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/upgradetombking.png
		if (ErrorLevel = 0) {
			logger("[PROGRESS] Leveling Tomb King.")
			clickx := FoundX - posx + 0
			clicky := FoundY - posy + 160
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
			sleep 75
			clicky += 70
			ControlClick, x%clickx% y%clicky%, %windowtitle%,,,, Pos NA
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
			GuiControl,,Status3, %FoundX% %FoundY%
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
		sleep 18000
		loop, 5 {
			ControlClick, x680 y246,%windowtitle%,,,, Pos NA
			sleep, 100
		}
		scrolls++
		if (chestfound = true) {
			sleep 20000
			lootprio()
			chestfound := false
		}
		activateautofire()
		deal := false
	} else if (ErrorLevel = 1) {
		GuiControl,,Status3, Waiting for a scroll ....
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
			ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/crafttime.png
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

	IfExist, graphite.enable
		Run %comspec% /c "echo zombidle.loot.%graph% 1 %T% | nc.exe %graphitehost% %graphiteport%",, Hide
}

lootprio() {
	global
	if (pauser = true) {
		return
	}

	ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/reward.png
	if (ErrorLevel = 0) {
		logger("[LOOT] found chest loot.")
		lootlist := ["StoneTablet_2", "StoneTablet_2", "KingsCollar_2_3", "KingsCollar_2_4", "KingsCollar_3_2", "deathChalice_2", "MagicRing_2", "PowerPotion_2"]
		for k, v in lootlist {
			ImageSearch, FoundX, FoundY, %posx%, %posy%, posx + endposx, posy + endposy, imgs/lootprio/%v%.png
			if (ErrorLevel = 0) {
				logger("[LOOT] " . v . " found.")
				clickx := FoundX - posx + 60
				clicky := FoundY - posy + 240
				ControlClick, x%clickx% y%clicky%,%windowtitle%,,,, Pos NA
				break
			}
			logger("[LOOT] Could not identify loot.")
		}
		sleep 10000
		ControlClick, x220 y580,%windowtitle%,,,, Pos NA
	}
}

PauseButton:
	if (pauser = false) {
		SetTimer, AutoFire, Off
		SetTimer, abilities, Off
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

