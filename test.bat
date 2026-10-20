call ant
if %errorlevel% neq 0 exit /b %errorlevel% 
set testLabels=zip
set testFilter=
set testAdditional=C:\work\lucee-extensions\extension-compress\tests

ant -buildfile="C:\work\script-runner" -DluceeVersion="light-6.0.0.491-SNAPSHOT" -Dwebroot="C:\work\lucee6\test" -Dexecute="/bootstrap-tests.cfm" -DextensionDir="C:\work\lucee-extensions\extension-compress\dist" -autoproxy

rem ant -buildfile="C:\work\script-runner" -DluceeVersion="6.0.0.151-SNAPSHOT" -Dexecute="/debug.cfm" -DextensionDir="C:\work\lucee-extensions\extension-compress\dist" -autoproxy