@echo off
set PATH=D:\flutter\bin;%PATH%
cd /d %~dp0
echo 星助校园 - Web 开发服务器
echo 启动后请在浏览器打开: http://localhost:8080
echo 按 Ctrl+C 停止
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080
