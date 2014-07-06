@ECHO OFF
SET MOD_NAME=JurassicRage
COPY System\%MOD_NAME%.log System\%MOD_NAME%.old.log
START ..\System\UT2004.exe %1 %2 %3 %4 %5 %6 %7 %8 %9 -MOD=%MOD_NAME%