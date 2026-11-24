@echo off
REM ============================================================
REM Portable Cezar launcher. Run inside a git repo (recommended)
REM or anywhere - registered projects stay selectable in the UI.
REM ASCII only. Auto-detects npm .cmd shims because Cezar cannot
REM spawn bare npm shim names on Windows (codex/opencode show as
REM "Not installed" without this).
REM ============================================================
where codex.cmd >nul 2>nul && for /f "delims=" %%i in ('where codex.cmd') do set "CEZ_CODEX_BIN=%%i"
where opencode.cmd >nul 2>nul && for /f "delims=" %%i in ('where opencode.cmd') do set "CEZ_OPENCODE_BIN=%%i"

echo Starting Cezar cockpit...
echo Open http://localhost:4321/ after it starts
echo (Tasks need at least one logged-in agent CLI, e.g. codex login)

where /q cezar
if %errorlevel%==0 (
    cezar
) else (
    echo [hint] 'cezar' launcher not found. Run setup.cmd first.
    echo Starting via npx instead...
    npx -y cezar-run
)
