# zombidleBot
Autohotkey project for idle game [Zombidle](http://www.zombidle.de)

## Overview
* [Getting Started and Upgrading to latest Bot version](#getting-started)
* [Features](#features)
* [Limitation](#limitation)
* [Graphite Setup](#graphite-instruction-optional)
* [Known Issues](#known-issues)
* [Later releases](#ideas-for-later-releases)
* [Thanks](#thanks)

## Getting Started
* Install  [Autohotkey v1.1.*](https://autohotkey.com/)
* Download [latest zombildeBot release](https://github.com/cottiAC/zombidleBot/releases/latest) and unpack
* Start the game and change the game resolution to 1136x640 
* Start zombidle.ahk 

### Upgrading to latest version
* Download [latest zombildeBot release](https://github.com/cottiAC/zombidleBot/releases/latest) and unpack
* Copy over following files from old release, to restore settings and progress:
  * privatesettings.ini
  * stats.log
  * status.log

## Features
* visual detection
* detect scrolls and collect them
* auto clicking and collecting ghosts
* level up Carl, TombKing and Squid
* change world if current world is finished
* use abilities
* simple GUI

![](https://github.com/cottiAC/zombidleBot/blob/master/imgs/readme/gui.png)
* most timers and click positions are configurable in ini-file
* stats about items found
* write stats to graphite to create awesome dashboards

![](https://github.com/cottiAC/zombidleBot/blob/master/imgs/readme/graph.png)

## Limitation
* works only with Steam release right now
* You need to change the game resolution to 1136x640
* if you use another browser window, the bot will not click to avoid take away focus
* in order to find scrolls, the browser windows must be visible
* Bot will switch from world 2 to 1, 1 to 3, 3 to 4 and so on. So you need to start with world 2 
* you need [Autohotkey v1.1.*](https://autohotkey.com/) to run the script


## Graphite Instruction (optional)
* [Install Graphite](https://graphite.readthedocs.io/en/latest/install.html#id2)
* configure your Graphite host and port in privatesettings.ini (privatesettings.ini will be created after first Bot start)
* change **graphiteenable** to true in your privatesettings.ini
* Download netcat (nc.exe) from [netcat Homepage](http://netcat.sourceforge.net/) or use the [cygwin netcat](https://cygwin.com/) and include it to your PATH variable
* structure of whisper paths are `zombidle.loot.%graph%`. %graph% can be:
  * x4_Skull
  * 5_Level
  * craftingTime
  * 5_Diamonds
  * 10_Diamonds
  * x2_DMG
  * Chest
  * NA

* you can use [Grafana](http://grafana.org/) to visualize it

## Known issues
* When game is paused, ability timer can go negative until next activation
* With too much lag you sometimes get stuck on world map during world switch
* "COME ON! CHOP CHOP!" message not handled

## Ideas for later releases
* Reset World

## Thanks
Thanks to kojaktsl and Lachhh for this awesome game. Keep up the good work.
If you like Zombidle please support the developers. 

