@echo OFF
pushd %~dp0

:top
set version=2.0.13
set author=audioscavenger

:defaults
set commitFile=commit.txt
set editor=notepad
set removeDangling=true
set PROJECT=%~dp0
for %%a in (%PROJECT:\= %) DO set PROJECT=%%a

:custom
:: WHAT2BACKUP= list of files and subfolders to backup, default is everything recursively
set WHAT2BACKUP=%~dp0\*
:: WHAT2EXCLUDE= list of files and subfolders to exclude, 7z format
set WHAT2EXCLUDE=-xr!*.7z -xr!*.log -xr!.svn -xr!.git
:: BACKUP_FOLDER=%~dp0\backup by default, defaine another path here
set BACKUP_FOLDER=%~dp0\backup
:: rotation=how many backup-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z to append to the main backup.7z before rebuilding it from scratch
set rotation=20
:: editor must be able to lock on the commit file, notepad does that, notepad++ does not. Test with your own
set editor=notepad
:: PROJECT= should match the root folder
REM set PROJECT=gitsync
:: projectConfig= can be empty == the main batch file that holds a line that says "set version=x.y.z", scrapped to fill in commit file header
set projectConfig=%PROJECT%.cmd
:: buildVersion= a version string like x.y.z used as header in the commit file, coming from %projectConfig%
:: If your project does not have such a file, and buildVersionAutomated=empty, your will be prompted for a version == not unattended
:: setting up buildVersionAutomated=x.y.z avoids this prompt pause, if you want this script to be fully unattended and not have a projectConfig file
set buildVersionAutomated=
:: textFiles are textFiles extensions, add your own to the list
set textFiles=*.cmd *.bat *.ini *.cfg *.config *.properties
:: is true, process textFiles with busybox unix2dos before :local_backup
set doUnix2dos=true

:prechecks
call "%~dpn0.cfg.cmd" >NUL 2>&1
IF "%~d0"=="%PROJECT%\" echo ERROR: this cannot work at the root drive without a PROJECT name & timeout /t 5 & exit 1
:: redirect origin: git remote set-url origin https://gitea.derewonko.com/audioscavenger/nQpupeteer
git config core.autocrlf true
call :setup_time
call :set_colors
:: WIP: notepad++ unfortunately does not work with start /wait
REM IF EXIST "%ProgramFiles%\Notepad++\notepad++.exe" set editor="%ProgramFiles%\Notepad++\notepad++.exe"
IF NOT EXIST "%BACKUP_FOLDER%\" set BACKUP_FOLDER=%~dp0\backup

:main
title %~n0 %version% by %author%: syncing %PROJECT%
call :local_backup
call :getBuildVersion

call :fetch
call :status_uptodate && goto :end
call :status_ff       && call :pull_ff
call :status_uptodate && goto :end
call :status_diverged && call :pull_merge
call :status_uptodate && goto :end
call :status_modified && call :add
call :commitMessage
call :local_backup_named %commitFile% %buildName%
call :createTag %commitFile% %buildVersion%
call :commit %commitFile%
call :push
goto :end

REM git config merge.tool vimdiff
REM git config merge.conflictstyle diff3
REM git config mergetool.prompt false

REM git config --global user.email you@example.com
REM git commit --amend --reset-author


:pull_ff
echo %HIGH%%b%  %~0 %END% 1>&2

:: These REM blocks are to account for when we pull a different version of this batch.
:: It will eventually crash if the modifications moves the cursor above or below.
:: The solution is to encaps the pull line with commented REM and eventually the cursor will move within the REMs.
:: Indeed this works only if the quantity of modifications that take place BEFORE the pull line stay within +/- 2064 chars.
:: To further protect this sritical line, :pull_ff has been move to the top just afer :main
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 

git merge --ff-only origin/master || git reset --hard origin/master

:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
:: REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM REM 
exit /b %ERRORLEVEL%
goto :EOF

:local_backup
echo %HIGH%%b%  %~0 %END% 1>&2

IF /I "%doUnix2dos%"=="true" where busybox >NUL 2>&1 && FOR /f "tokens=*" %%F in ('dir /b /s %textFiles%') DO busybox unix2dos "%%~F"

md "%BACKUP_FOLDER%" 2>NUL
del /f /q "%BACKUP_FOLDER%\%PROJECT%.7z.tmp*" 2>NUL
echo testing "%BACKUP_FOLDER%\%PROJECT%.7z" ... 1>&2
IF EXIST "%BACKUP_FOLDER%\%PROJECT%.7z" 7z t "%BACKUP_FOLDER%\%PROJECT%.7z" -bse1 2>NUL | findstr ERROR: >NUL && del /f /q "%BACKUP_FOLDER%\%PROJECT%.7z"

:: every nth rotation differential backups, we reset the master backup to decrease its size
for /f %%n in ('dir /b "%BACKUP_FOLDER%\*.7z" 2^>NUL') DO set /A _num=1
set /a "_num%%=rotation"
IF %_num% EQU 0 del /f /q "%BACKUP_FOLDER%\%PROJECT%.7z" 2>NUL

REM -slp : set Large Pages mode
REM -ms=off : disable solid
REM -bso0 : standard output messages to NUL
REM -bsp2 : progress information to stderr
REM -uq0 : File exists in archive, but deleted on disk = Ignore file
REM -uq3 : File exists in archive, but deleted on disk = Create Anti-item
IF EXIST "%BACKUP_FOLDER%\%PROJECT%.7z" (
  call :local_backup_update
) ELSE (
  echo %c%7z a "%BACKUP_FOLDER%\%PROJECT%.7z" -ms=off -slp -bso0 -bsp2 -uq3 %WHAT2BACKUP% %HIGH%%k%%WHAT2EXCLUDE%
  7z a "%BACKUP_FOLDER%\%PROJECT%.7z" -ms=off -slp -bso0 -bsp2 -uq3 %WHAT2BACKUP% %WHAT2EXCLUDE%
  echo:%END%
)

goto :EOF

:local_backup_update
echo %HIGH%%b%  %~0 %END% 1>&2

:: creates a new archive %PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z and writes to this archive all files from current directory which differ from files in %PROJECT%.7z archive
:: %PROJECT%.7z archive will also be updated after.

echo %c%7z u "%BACKUP_FOLDER%\%PROJECT%.7z" -ms=off -bso0 -bsp2 -up0q3x2z0!"%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z" %WHAT2BACKUP% %HIGH%%k%%WHAT2EXCLUDE%
7z u "%BACKUP_FOLDER%\%PROJECT%.7z" -ms=off -bso0 -bsp2 -up0q3x2z0!"%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z" %WHAT2BACKUP% %WHAT2EXCLUDE%
echo:%END% 1>&2
7z t "%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z" | findstr /C:"No files" && del /f /q "%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z"

goto :EOF

:local_backup_named commitFile buildName
echo %HIGH%%b%  %~0 %END% 1>&2
set commitFile=%1
set buildName=%2

IF DEFINED buildName (
  IF EXIST "%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z" (
    move /y "%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%.7z" "%BACKUP_FOLDER%\%PROJECT%-%CURRENT_DATE_NOSEP%-%CURRENT_TIME%-%buildName%.7z" >NUL 2>&1
  )
)

exit /b %ERRORLEVEL%
goto :EOF

:getBuildVersion
echo %HIGH%%b%  %~0 %END% 1>&2

IF EXIST "%projectConfig%" for /F "tokens=3 delims== " %%v in ('findstr /B /C:"set version=" "%projectConfig%"') DO set buildVersion=%%v
IF NOT DEFINED buildVersion IF EXIST README.md      for /F "tokens=2 delims== " %%v in ('findstr /B /C:"version=" README.md') DO set buildVersion=%%v
IF NOT DEFINED buildVersion set buildVersion=%buildVersionAutomated%
IF NOT DEFINED buildVersion set /p buildVersion=buildVersion? 

goto :EOF

:fetch
echo %HIGH%%b%  %~0 %END% 1>&2
git fetch --all
goto :EOF

:status_ff
echo %HIGH%%b%  %~0 %END% 1>&2
git status | findstr /C:"can be fast-forwarded" && exit /b 0
exit /b 1
goto :EOF

:pull_merge
echo %HIGH%%b%  %~0 %END% 1>&2
git merge origin/master && exit /b 0
git add .
git status >>%commitFile%
git commit -a -F %commitFile%
exit /b %ERRORLEVEL%
goto :EOF

:pull_force
echo %HIGH%%b%  %~0 %END% 1>&2
git pull --force || git reset --hard origin/master
exit /b %ERRORLEVEL%
goto :EOF

:status_diverged
echo %HIGH%%b%  %~0 %END% 1>&2

git status | findstr /C:"have diverged" >NUL && git status && exit /b 0
exit /b 1
goto :EOF

:status_modified
echo %HIGH%%b%  %~0 %END% 1>&2

git status | findstr /C:"Untracked files:" >NUL && git status && exit /b 0
git status | findstr /C:"Changes not staged for commit:" >NUL && git status && exit /b 0
exit /b 1
goto :EOF

:status_uptodate
echo %HIGH%%b%  %~0 %END% 1>&2

git status | findstr /C:"nothing to commit" && exit /b 0

git status
exit /b 1
goto :EOF

:add
echo %HIGH%%b%  %~0 %END% 1>&2
git add .
exit /b %ERRORLEVEL%
goto :EOF

:commitMessage
echo %HIGH%%b%  %~0 %END% 1>&2

set commitFile=commit.%PROJECT%.%buildVersion%.txt

:: get remote message over local message; we must assume that the remote is always the current one
git tag -l %buildVersion% -n999 >%commitFile%
call :isEmpty %commitFile% && echo Pulling message for tag %buildVersion%: EMPTY || echo Pulling message for tag %buildVersion%: EXIST

:: we now reuse older commitFile if exist. Commit again over same version will also recreate the tag
call :isEmpty %commitFile% && echo WIP %buildVersion% >%commitFile%
:: we now append modifications to the same commit message and replace the tag each time. Makes more sense.
git status | findstr "modified: deleted:" >>%commitFile%

:: insert smth like "release 1.2.3 tidy" or "WIP 1.2.3" as the first line
start "" /wait %editor% %commitFile%

:: if you input smth like "release 1.2.3 tidy" as the first line, buildName=tidy and a named differential zipfile will be created
set buildName=
for /f "tokens=3*" %%n in ('findstr /B release %commitFile%') DO set "buildName=%%n"

exit /b %ERRORLEVEL%
goto :EOF

:createTag commitFile buildVersion
echo %HIGH%%b%  %~0 %END% 1>&2
set commitFile=%1
set buildVersion=%2

git tag -d %buildVersion%
git push --delete origin %buildVersion%
git tag -a %buildVersion% --file=%commitFile%
:: what to do with error: failed to push some refs to 'https://git/name/project'?

exit /b %ERRORLEVEL%
goto :EOF

:commit commitFile
echo %HIGH%%b%  %~0 %END% 1>&2

git commit -a -F %1

exit /b %ERRORLEVEL%
goto :EOF

:push
echo %HIGH%%b%  %~0 %END% 1>&2
REM git push
git push --tags --set-upstream origin master
exit /b %ERRORLEVEL%
goto :EOF

:set_colors
set END=[0m
set HIGH=[1m
set Underline=[4m
set REVERSE=[7m

REM echo [101;93m NORMAL FOREGROUND COLORS [0m
set k=[30m
set r=[31m
set g=[32m
set y=[33m
set b=[34m
set m=[35m
set c=[36m
set w=[37m

goto :EOF


:setup_time
IF DEFINED DEBUG echo DEBUG: %m%%~n0 %~0 %HIGH%%*%END% 1>&2

set CURRENT_DATE=%DATE:/=-%
set GOOD_DATE=%CURRENT_DATE:~0,10%
:: ISO
if "%CURRENT_DATE:~2,1%" EQU "-" set GOOD_DATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
:: US
if "%CURRENT_DATE:~3,1%" EQU " " set GOOD_DATE=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%
set CURRENT_DATE_NOSEP=%GOOD_DATE:-=%

set CURRENT_TIME=%TIME::=%

:: BUG: cannot add numbers that start with 0
set /A nextHour=%CURRENT_TIME:~0,2% + 1
set nextHour=%nextHour%%TIME:~3,2%

if "%CURRENT_TIME:~0,1%" == " " set CURRENT_TIME=0%CURRENT_TIME:~1%
set CURRENT_TIME=%CURRENT_TIME:~0,4%
goto :EOF


:isEmpty
IF NOT EXIST %1 exit /b 0
exit /b 0%~z1
goto :EOF


:end
echo -------------------- THE END -------------------- 1>&2
git gc --auto
IF NOT DEFINED removeDangling git fsck | findstr dangling && (
  echo: 1>&2
  set /p removeDangling=remove danglings? [N/y] 
)
IF DEFINED removeDangling (
  git reflog expire --expire=now --all
  git gc --prune=now
)
