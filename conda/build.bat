@echo off
REM build.bat - For Windows builds

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if not exist "%PREFIX%\lib" mkdir "%PREFIX%\lib"

copy bin\plugify-module-lua.dll "%PREFIX%\bin\" || exit 1
xcopy lib "%PREFIX%\lib" /E /Y /I || exit 1
copy plugify-module-lua.pmodule "%PREFIX%\" || exit 1

REM Create activation scripts
if not exist "%PREFIX%\etc\conda\activate.d" mkdir "%PREFIX%\etc\conda\activate.d"
if not exist "%PREFIX%\etc\conda\deactivate.d" mkdir "%PREFIX%\etc\conda\deactivate.d"

echo @echo off > "%PREFIX%\etc\conda\activate.d\plugify-module-lua.bat"
echo set "PLUGIFY_LUA_MODULE_PATH=%%CONDA_PREFIX%%;%%PLUGIFY_LUA_MODULE_PATH%%" >> "%PREFIX%\etc\conda\activate.d\plugify-module-lua.bat"

echo @echo off > "%PREFIX%\etc\conda\deactivate.d\plugify-module-lua.bat"
echo set "PLUGIFY_LUA_MODULE_PATH=%%PLUGIFY_LUA_MODULE_PATH:%%CONDA_PREFIX%%;=%%" >> "%PREFIX%\etc\conda\deactivate.d\plugify-module-lua.bat"

exit 0
