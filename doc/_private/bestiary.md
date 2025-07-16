# Bestiary 

The `bestiary` is a dictionary with this structure:

    {
        "enemy1" : {
            <properties>
        } ,
        "enemy2" : {
            <properties>
        }
    }

Each entry is itself a dictionary.  Lookup example:

```forth
\ Get an entry's starting HP
c" enemy1" bestiary lookup @ c" hp" lookup @   
```

Definition words (interpret only)

`for:` - add an enemy or edit an existing one.  sets current enemy
`hp:` - set the starting hp value of the current enemy (int)
`spd:` - set the starting speed of the current enemy (fixed)
`path:` - set the starting path of the current enemy (string)

`save` - save the bestiary to enemies.vfx in this format:
```forth
\ id            hp      atk         gold        spd         path
for: enemy1     hp: 2   atk: 5      gold: 10    spd: 1.0    path: path1 
for: enemy2     hp: 5   atk: 10     gold: 1000  spd: 2.0    path: path2
... etc
```
