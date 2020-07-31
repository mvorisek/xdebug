@echo off
setlocal enableextensions enabledelayedexpansion

del /f php_xdebug.dll

REM run in a new console without affecting the current env
if not "%PHP_MAHA_REALPATH_TURBO_JTUAMUC4AM2FZMR7%" == "GEDKVQPMABBRZFFV" (
    cmd /c "set "PHP_MAHA_REALPATH_TURBO_JTUAMUC4AM2FZMR7=GEDKVQPMABBRZFFV" & %~0 vc15 x64 nts & exit ^!errorlevel^!"
    exit /b %errorlevel%
)

set "vc_ver=%1"  REM like vc15
set "vc_arch=%2" REM x86 or x64
set "php_zts=%3" REM ts or nts

REM configure VC env
@call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars%vc_arch:~1%.bat"

REM configure PHP SDK env
if not exist "%~dp0\build" (
    mkdir "%~dp0\build"
)
if not exist "%~dp0\build\php-sdk-binary-tools" (
    git clone https://github.com/microsoft/php-sdk-binary-tools "%~dp0\build\php-sdk-binary-tools"
)

@call "%~dp0\build\php-sdk-binary-tools\phpsdk-starter.bat" -c %vc_ver% -a %vc_arch% -t "REM"
@call "%~dp0\build\php-sdk-binary-tools\bin\phpsdk_setvars.bat"

REM create configure.bat file inside current directory
REM download "Development package (SDK to develop PHP extensions)" from https://windows.php.net/download, example:
REM https://windows.php.net/downloads/releases/php-devel-pack-7.4.2-nts-Win32-vc15-x64.zip
@call "%~dp0\build\php-7.4.8-devel-vc%vc_ver:~2%-%vc_arch%\phpize.bat"

REM run configure and compile
@call configure.bat --disable-all --with-xdebug
findstr "PHP_COMPILER_SHORT=[Vv][Cc]%vc_ver:~2%" Makefile
if not "%errorlevel%" == "0" (
   echo VC version mismatch, update the VC path
   exit /b 1
)
nmake clean > nul 2>&1
nmake

copy x64\Release\php_xdebug.dll php_xdebug.dll

REM test realpath turbo
php --no-php-ini -d display_errors=1 -d display_startup_errors=1 -d error_reporting=-1 -d open_basedir="""""""%~dp0/""""""" ^
    -d zend_extension="""""""%~dp0\%vc_arch%\Release\php_xdebug.dll""""""" ^
    -r "echo PHP_EOL . PHP_EOL . 'xdebug debug: '; if (^!in_array('xdebug', get_loaded_extensions())) { throw new \Exception('Module not loaded^!'); } echo 'loaded...' . PHP_EOL;"
