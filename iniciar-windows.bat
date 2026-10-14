@echo off
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Instale o Node.js 24 ou superior em https://nodejs.org
  pause
  exit /b 1
)
echo O site vai iniciar. Abra http://localhost:3000 no navegador.
echo Mantenha esta janela aberta enquanto usa o site.
node --env-file-if-exists=.env server.mjs
pause
