@echo off

mkdir ..\build
pushd ..\build
cl -Zi ..\..\me_handmadehero\code\w32_handmadehero.cpp
popd
