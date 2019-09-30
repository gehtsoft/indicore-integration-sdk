@echo off


@echo ************************************************************************
@echo ------------------Start Cleaning sample. --------------------

@if exist bin\*.*   del bin\*.* /f /q /s
@if exist bin       rmdir bin /q /s
@if exist lib\*.*   del lib\*.* /f /q /s
@if exist lib       rmdir lib /q /s
@if exist obj\*.*   del obj\*.* /f /q /s
@if exist obj       rmdir obj /q /s
@if exist ..\bin\*.*   del ..\bin\*.* /f /q /s
@del fxbuild.err
:end
