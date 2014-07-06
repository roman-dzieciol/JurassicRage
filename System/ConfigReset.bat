
@SET MOD_NAME=JurassicRage
@SET MOD_SYS=..\..\%MOD_NAME%\System
@SET MOD_HELP=If you need assistance please visit our Help Desk forum.
@SET MOD_URL=http://forums.jurassic-rage.com

@ECHO // ---------------------------------------------------------------------------
@ECHO // Creates default config files, uses default UT2004 settings.
@ECHO // ---------------------------------------------------------------------------

CD %MOD_SYS%
@if ERRORLEVEL 1 GOTO FAILURE


::
:: Delete old config
::
DEL /F %MOD_NAME%.ini
@if ERRORLEVEL 1 GOTO FAILURE
DEL /F %MOD_NAME%User.ini
@if ERRORLEVEL 1 GOTO FAILURE

::
:: Backup original defaults
::
COPY /Y Default.ini Default.ref.ini
@if ERRORLEVEL 1 GOTO FAILURE
COPY /Y DefUser.ini DefUser.ref.ini
@if ERRORLEVEL 1 GOTO FAILURE

::
:: Prepare defaults for appending
::
@ECHO.>>Default.ini
@ECHO.>>DefUser.ini

::
:: Append personal defaults
::
COPY /Y Default.ini +My.ini Default.ini 
@if ERRORLEVEL 1 GOTO FAILURE
COPY /Y DefUser.ini +MyUser.ini DefUser.ini 
@if ERRORLEVEL 1 GOTO FAILURE
@ECHO.>>Default.ini
@ECHO.>>DefUser.ini

::
:: Append development defaults
::
COPY /Y Default.ini +Dev.ini Default.ini 
@if ERRORLEVEL 1 GOTO FAILURE
COPY /Y DefUser.ini +DevUser.ini DefUser.ini 
@if ERRORLEVEL 1 GOTO FAILURE
@ECHO.>>Default.ini
@ECHO.>>DefUser.ini

::
:: Let engine generate new config
::
START /B /WAIT ..\..\System\ucc.exe Help Core.Commandlet -MOD=%MOD_NAME%
@if ERRORLEVEL 1 GOTO FAILURE


::
:: Restore original defaults
::
MOVE /Y Default.ref.ini Default.ini
@if ERRORLEVEL 1 GOTO FAILURE
MOVE /Y DefUser.ref.ini DefUser.ini
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
@IF EXIST Default.ref.ini MOVE /Y Default.ref.ini Default.ini
@IF EXIST DefUser.ref.ini MOVE /Y DefUser.ref.ini DefUser.ini
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


