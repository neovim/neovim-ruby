@echo off
rem Command line utility for themis.vim
rem Version: 1.5.4
rem Author : thinca <thinca+vim@gmail.com>
rem License: zlib License

setlocal

if "%THEMIS_HOME%"== "" call :get_realpath
if "%THEMIS_VIM%"== "" set THEMIS_VIM=vim
if "%THEMIS_ARGS%"== "" set THEMIS_ARGS=-e -s

set STARTUP_SCRIPT="%THEMIS_HOME%\macros\themis_startup.vim"
if not exist "%STARTUP_SCRIPT%" (
  echo %%THEMIS_HOME%% is not set up correctly. 1>&2
  exit /b 2
)

rem FIXME: Some wrong case exists in passing the argument list.
rem DO NOT directly output the result to command prompt while 'normal' command in Vim script
rem will move a cursor of command prompt in that case.
set THEMIS_LOG="%TMP%\themis.log"
%THEMIS_VIM% -u NONE -i NONE -n -N %THEMIS_ARGS% --cmd "source %STARTUP_SCRIPT%" -- %* 2>&1 > %THEMIS_LOG%
set THEMIS_ERRORLEVEL=%ERRORLEVEL%
type %THEMIS_LOG%
del %THEMIS_LOG%
exit /b %THEMIS_ERRORLEVEL%

:get_realpath
set realpath=..
for /F "skip=5 tokens=2,4 delims=<>[]" %%1 in ('dir /AL "%~pf0" 2^>NUL') do (
    if "%%1" == "SYMLINK" set realpath=%%~2\..\..
)
pushd "%~dp0\%realpath%" 2>NUL || pushd "%realpath%" 2>NUL
set THEMIS_HOME=%CD%
popd
exit /b 0
