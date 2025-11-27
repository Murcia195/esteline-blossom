@echo off
REM Script para compilar y ejecutar la app Flutter

echo ============================================
echo COMPILANDO TIENDA MAQUILLAJE ESTELINE
echo ============================================
echo.

cd /d "C:\Users\Admin\TiendaMaquillajeScript\tienda_maquillaje_completo\flutter_app"

echo [1/3] Instalando dependencias...
call flutter pub get

if %ERRORLEVEL% neq 0 (
    echo [ERROR] No se pudieron instalar las dependencias
    pause
    exit /b 1
)

echo.
echo [2/3] Limpiando compilaciones previas...
call flutter clean

echo.
echo [3/3] Compilando y ejecutando en Chrome...
call flutter run -d chrome

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo en la compilación
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✅ APP COMPILADA Y EJECUTADA CORRECTAMENTE
echo ✅ Abre tu navegador en: http://127.0.0.1:60139
echo ============================================
pause
