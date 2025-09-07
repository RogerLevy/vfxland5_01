@echo off

IF exist %1 (
    cd %1
    exit
) 

mkdir %1
cd %1
mkdir scripts
mkdir dat
mkdir dat\gfx
mkdir dat\smp
mkdir dat\bgm

echo \ ------------------------------------------------------------------------------ > main.vfx
echo \ %1 >> main.vfx
echo \ ------------------------------------------------------------------------------ >> main.vfx
echo. >> main.vfx
echo include %%idir%%\..\spunk\loader.vfx >> main.vfx

echo \ Game >> game.vfx
echo : render  sprites animate ; >> game.vfx
echo : think  step ; >> game.vfx
echo : game  show^> think render ; >> game.vfx
echo game >> game.vfx
echo. >> game.vfx

echo \ Integrations >> game.vfx
echo : boot-%1  init-supershow game ; >> game.vfx
echo ' boot-%1 is boot >> game.vfx
echo init-supershow >> game.vfx

touch constants.vfx
touch testing.vfx
touch common.vfx
touch checks.vfx
touch modules.vfx
touch modes.vfx
