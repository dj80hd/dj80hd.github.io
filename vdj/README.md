# VDJ config bible 

## MIC & SAMPLER midi layout
```
                  | b. CC0 speed
 _                | c. CC1 ke
(X)a              | d. CC2 song_po
                  |
 _          _     | e. 49 syn
(_)b       |_|e   | f. 50 dum
            _     | g. 51 keylock
 _         |_|f   | h. 52 pitch reset
(_)c        _     | i. 53 flipdbl
           |_|g   | j.k. CC3/95 DRILL
 _	        _     | l. 97 left
(_)d       |_|h   | m. 96 right
      __          | n. 102 play/pause
     |__|i        | o. 104 nudge back
 _          _     | p. 103 nudge foward
(_)j       |_|k   | q. 109 loopexit HC1
                  | r. 110 loopexit HC2
  . . . . . .     | s. 115 loopexit HC3
 (.)l      (.)m   | t. 108 delete HC1
      __          | u. 113 delete HC2
     |__|n        | v. 118 delete HC3
                  | w. beatseek -1 
  . . . . . .     | x. beatseek +2
 (.)o      (.)p   |
                  |
  __        _     |
 |__|q     |_|t   |
  __        _     |
 |__|r     |_|u   |
  __        _     |
 |__|s     |_|v   |
  __        _     |
 |__|w     |_|x   |
                  |
            _     |
  (.)      |_|    |

```

## CHANNEL LAYOUTS (CH 1-4)

```
                  | a. trim pot (no midi)
                  | b. CC? speed
 _                | c. CC? key
(X)a              | d. CC? song_po
                  |
 _          _     | e. ?? syn
(_)b       |_|e   | f. ?? dum
            _     | g. ?? keylock
 _         |_|f   | h. ?? pitch reset
(_)c        _     |
           |_|g   |
 _	        _     |
(_)d       |_|h   |

```

## CROSSFADER LAYOUT

```
```


## USEFUL VDJ SCRIPT

### Basics

```
  deck default pitch_slider
  deck default key_smooth
  deck default song_pos
  deck default sync
  deck default dump
  deck default key_lock
  deck default play_pause
  deck 1 select
  deck 2 select
  deck default loop_in
  deck default loop_out

```

### Loop drill

```
  param_equal 100% ? deck default loop_exit : param_smaller 3% ? deck default  loop 0.0312 : param_smaller 6% ? deck default  loop 0.0625 : param_smaller 12% ? deck default  loop 0.125 ? nothing : deck default   loop 0.125 : param_smaller 24% ? deck default  loop 0.25 ? nothing : deck default  loop 0.25 : param_smaller 36% ? deck default  loop 0.5 ? nothing : deck default  loop 0.5 : param_smaller 48% ? deck default  loop 1 ? nothing : deck default  loop 1 : param_smaller 60% ? deck default  loop 2 ? nothing : deck default  loop 2 : param_smaller 72% ? deck default  loop 4 ? nothing : deck default  loop 4 : param_smaller 84% ? deck default  loop 8 ? nothing : deck default  loop 8 : deck default  loop 16 ? nothing : deck active loop 16
```

  <map value="15-CC45" action="param_greater 50% ? deck 2 jogwheel -0.02 : deck 2 jogwheel +0.02" />
### What is the difference between nudge and seek ?

```
  <map value="0-104" action="deck default nudge -4ms" />
  <map value="0-103" action="deck default nudge +4ms" />
  <map value="0-120" action="deck default seek -2" />
  <map value="0-121" action="deck default seek +2" />
```


## Video Design

1. random vid on deck default at random point
