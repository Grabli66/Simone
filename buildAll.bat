@echo off

echo Cleaning previous build...
if exist Server\out rmdir /S /Q Server\out
if exist Web\out rmdir /S /Q Web\out

echo Building Server...
cd Server
nimble build
if errorlevel 1 (
    echo Server build failed!
    exit /b 1
)
cd ..

echo Building Web...
cd Web
nimble build
if errorlevel 1 (
    echo Web build failed!
    exit /b 1
)
cd ..

echo Copying files to Distr...
if not exist Distr mkdir Distr
copy /Y Server\out\Server.exe Distr\
if errorlevel 1 (
    echo Failed to copy Server.exe!
    exit /b 1
)
copy /Y Web\out\index.js Distr\
if errorlevel 1 (
    echo Failed to copy index.js!
    exit /b 1
)

echo Build completed!
