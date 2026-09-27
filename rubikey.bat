@echo off
setlocal
cd /d "%~dp0"

call bundle check >nul 2>&1
if errorlevel 1 (
  echo Rubikey dependencies are missing. Installing them now...
  call bundle install
  if errorlevel 1 (
    echo.
    echo Dependency installation failed. Check your Ruby and Bundler setup.
    pause
    exit /b 1
  )
)

call bundle exec ruby "%~dp0bin\rubikey"
if errorlevel 1 echo Rubikey could not start. Check the error above.
echo.
echo Rubikey has exited. Press any key to close this window.
pause >nul