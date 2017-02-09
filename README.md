# zombidleBot
Autohotkey project for idle game [Zombidle] (http://www.zombidle.de)

## Features
* visual detection
* detect scrolls and collect them
* auto clicking and collecting ghosts
* level up Carl and TombKing
* change world if current world is finished
* use abilities
* simple GUI

![octocat](https://github.com/cottiAC/zombidleBot/blob/master/imgs/readme/gui.png)
* most timers and click positions are configurable in ini-file
* stats about items found
* write stats to graphite to create awesome dashboards

![octocat](https://github.com/cottiAC/zombidleBot/blob/master/imgs/readme/graph.png)

## Limitation
* works only with Firefox right now
* in order to find scrolls, the browser windows must be visible
* you need [Autohotkey v1.1.*] (https://autohotkey.com/) to run the script

## Graphite Instruction (optional)
* [Install Graphite] (https://graphite.readthedocs.io/en/latest/install.html#id2)
* configure your Graphite host and port in settings.ini (**general** tab)
* create a file named `graphite.enable` in your zombidleBot folder
* Download netcat (nc.exe) from [netcat Homepage] (http://netcat.sourceforge.net/) or use the [cygwin netcat] (https://cygwin.com/) and include it to your PATH variable
* structure of whisper paths are `zombidle.loot.%graph%`. %graph% can be:
  * x4_Skull
  * 5_Level
  * craftingTime
  * 5_Diamonds
  * 10_Diamonds
  * x2_DMG
  * Chest
  * NA

* you can use [Grafana] (http://grafana.org/) to visualize it

## Known issues
* Bot get stuck if you find a chest (need to improve lootprio function)
* If its too laggy farming mode can be clicked during monster upgrade process
* When game is paused, ability timer can go negative until next activation
* With too much lag you sometimes get stuck on world map during world switch
* "COME ON! CHOP CHOP!" message not handled

## Ideas for later releases
* Reset World
* open chests on maps
* identify and prioritize loot from chests
* craft items

## Thanks
Thanks to kojaktsl and Lachhh for this awesome game. Keep up the good work.
If you like Zombidle please support the developers. 

