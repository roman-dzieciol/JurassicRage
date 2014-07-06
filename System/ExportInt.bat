::
:: Environment
::
@SET MOD_NAME=JurassicRage
@SET MOD_SYS=..\..\%MOD_NAME%\System
@SET MOD_HELP=If you need assistance please visit our Help Desk forum.
@SET MOD_URL=http://forums.jurassic-rage.com

@ECHO // ---------------------------------------------------------------------------
@ECHO // INT Exporter for %MOD_NAME%.
@ECHO // ---------------------------------------------------------------------------

CD %MOD_SYS%
@if ERRORLEVEL 1 GOTO FAILURE

@FOR %%a IN (*.u) DO START /B /WAIT ..\..\System\ucc.exe editor.dumpint %%a -mod=%MOD_NAME%
@FOR %%a IN (*.u) DO MOVE /Y ..\..\System\%%~na.int %%~na.int
@if ERRORLEVEL 1 GOTO FAILURE


::
:: Success 
::
@GOTO SUCCESS

::
:: Something's wrong
::
:FAILURE
@COLOR 4F
@ECHO.
@ECHO.
@ECHO !!! ERROR !!!
@ECHO.
@ECHO %MOD_HELP%
@ECHO %MOD_URL%
@ECHO.
@PAUSE
@COLOR


:SUCCESS