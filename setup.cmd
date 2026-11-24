@echo off
REM ============================================================
REM Cezar one-click environment setup. ASCII only.
REM Run once on a new machine, then open a NEW terminal.
REM ============================================================
echo [1/5] Checking prerequisites...
where node >nul 2>nul || (echo ERROR: Node.js 20+ is required. Install from https://nodejs.org & goto :eof)
where git >nul 2>nul || (echo ERROR: git is required. Install git first. & goto :eof)
node --version

echo [2/5] Installing Cezar permanently (~/.cezar, adds 'cezar' launcher)...
call npx -y cezar-run install

echo [3/5] Detecting agent CLI shims (fixes the Windows "Not installed" false negative)...
set "CEZ_CODEX_BIN="
set "CEZ_OPENCODE_BIN="
where /q codex.cmd && for /f "delims=" %%i in ('where codex.cmd 2^>nul') do if not defined CEZ_CODEX_BIN set "CEZ_CODEX_BIN=%%i"
where /q opencode.cmd && for /f "delims=" %%i in ('where opencode.cmd 2^>nul') do if not defined CEZ_OPENCODE_BIN set "CEZ_OPENCODE_BIN=%%i"
if defined CEZ_CODEX_BIN (setx CEZ_CODEX_BIN "%CEZ_CODEX_BIN%" >nul && echo   codex shim: %CEZ_CODEX_BIN%) else (echo   [skip] codex.cmd not found - install Codex CLI later and rerun)
if defined CEZ_OPENCODE_BIN (setx CEZ_OPENCODE_BIN "%CEZ_OPENCODE_BIN%" >nul && echo   opencode shim: %CEZ_OPENCODE_BIN%) else (echo   [skip] opencode.cmd not found - install OpenCode later and rerun)

echo [4/5] Adding %%USERPROFILE%%\.cezar\bin to user PATH...
powershell -NoProfile -Command "$bin = Join-Path $env:USERPROFILE '.cezar\bin'; $p = [Environment]::GetEnvironmentVariable('Path','User'); if ($p -notlike '*'+$bin+'*') { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $bin), 'User'); Write-Output '  PATH updated' } else { Write-Output '  already in PATH' }"

echo [5/5] Setup done. Next steps:
echo   1. Open a NEW terminal so env vars take effect
echo   2. Log in to at least one agent CLI, e.g.:  codex login   or   claude
echo   3. cd into a git repo, then:  cezar projects add D:\path\to\repo  and run  cezar
echo   4. Or double-click start-cezar.cmd
