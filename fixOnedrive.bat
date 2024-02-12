@echo OFF


setlocal ENABLEEXTENSIONS
set KEY_NAME=HKEY_CURRENT_USER\Software\Microsoft\OneDrive
set VALUE_NAME=DisablePersonalSync

FOR /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set ValueName=%%A
    set ValueType=%%B
    set ValueValue=%%C
)

if defined ValueName (
    @echo Value Name = %ValueName%
    @echo Value Type = %ValueType%
    @echo Value Value = %ValueValue%
) else (
    @echo %KEY_NAME%\%VALUE_NAME% not found.
)

echo So, "%KEY_NAME%\%VALUE_NAME% has been found, let's see if we can alter its attribute..."

REG QUERY %KEY_NAME% /v %VALUE_NAME% | find "0x1"
::ECHO.%ERRORLEVEL%
if %errorlevel% == 0 (echo "%ValueValue% is 1 and needs to be changed to 0!"  
						goto :change)

if %errorlevel% == 1  (echo "%ValueValue% is 0, no change should be maken!!"  
						goto :end)


:change
echo Reached change
REG ADD %KEY_NAME% /v %VALUE_NAME% /t REG_DWORD /f /D 0
echo "%ValueValue% has be changed to 0!"
goto end

:end
echo Reached end, that's all!
ECHO.%ERRORLEVEL%
	
	

