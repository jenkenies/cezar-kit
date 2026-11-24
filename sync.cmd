@echo off
REM ============================================================
REM Distribute the master workflow + pipeline skills to target
REM projects. Edit the PROJECTS list when repos change. ASCII only.
REM After syncing, commit each project's .ai/cezar/workflows and
REM .ai/cezar/skills so worktrees and teammates get them via git.
REM ============================================================
set "MASTER=%~dp0workflows"
set "SKILLS=%~dp0skills"

for %%P in (
    "D:\code\crm-sale-server\crm-sale-server"
    "D:\code\fcbox-ad-server"
    "D:\code\fcad-dsp-server"
) do (
    if not exist "%%~P\.ai\cezar\workflows" mkdir "%%~P\.ai\cezar\workflows"
    if not exist "%%~P\.ai\cezar\skills" mkdir "%%~P\.ai\cezar\skills"
    copy /Y "%MASTER%\dev-pipeline.yaml" "%%~P\.ai\cezar\workflows\" >nul && echo OK workflow %%~P
    for /d %%S in ("%SKILLS%\*") do (
        xcopy /E /I /Y "%%S" "%%~P\.ai\cezar\skills\%%~nS" >nul && echo OK skill %%~nS
    )
)
echo Sync done. Commit .ai/cezar/workflows + .ai/cezar/skills in each repo to share with the team.
