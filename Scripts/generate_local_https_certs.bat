@echo off
setlocal

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "CERT_DIR=%ROOT_DIR%\docker\certs"

where openssl >nul 2>&1
if errorlevel 1 (
  echo [ERROR] OpenSSL was not found in PATH.
  exit /b 1
)

where certutil >nul 2>&1
if errorlevel 1 (
  echo [ERROR] certutil was not found in PATH.
  exit /b 1
)

if not exist "%CERT_DIR%" mkdir "%CERT_DIR%"
if errorlevel 1 (
  echo [ERROR] Failed to create cert directory: "%CERT_DIR%"
  exit /b 1
)

echo [INFO] Writing cert files to "%CERT_DIR%"
pushd "%CERT_DIR%"
if errorlevel 1 (
  echo [ERROR] Failed to enter cert directory.
  exit /b 1
)

echo [INFO] Generating local dev CA key...
openssl genrsa -out local-dev-ca.key 4096
if errorlevel 1 goto :fail

echo [INFO] Generating local dev CA certificate...
openssl req -x509 -new -nodes -key local-dev-ca.key -sha256 -days 3650 -out local-dev-ca.pem -subj "/CN=Django Local Dev CA"
if errorlevel 1 goto :fail

echo [INFO] Generating localhost server key...
openssl genrsa -out key.pem 2048
if errorlevel 1 goto :fail

echo [INFO] Generating localhost CSR with SAN entries...
openssl req -new -key key.pem -out localhost.csr -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
if errorlevel 1 goto :fail

(
  echo authorityKeyIdentifier=keyid,issuer
  echo basicConstraints=CA:FALSE
  echo keyUsage = digitalSignature, keyEncipherment
  echo extendedKeyUsage = serverAuth
  echo subjectAltName = @alt_names
  echo.
  echo [alt_names]
  echo DNS.1 = localhost
  echo IP.1 = 127.0.0.1
) > localhost.ext
if errorlevel 1 goto :fail

echo [INFO] Signing localhost certificate with local dev CA...
openssl x509 -req -in localhost.csr -CA local-dev-ca.pem -CAkey local-dev-ca.key -CAcreateserial -out cert.pem -days 825 -sha256 -extfile localhost.ext
if errorlevel 1 goto :fail

echo [INFO] Trusting local dev CA in current user's root certificate store...
certutil -user -delstore Root "Django Local Dev CA" >nul 2>&1
certutil -user -addstore Root "%CERT_DIR%\local-dev-ca.pem"
if errorlevel 1 goto :fail

if exist localhost.csr del /q localhost.csr
if exist localhost.ext del /q localhost.ext
if exist local-dev-ca.srl del /q local-dev-ca.srl

echo [SUCCESS] Local HTTPS certificates are ready.
echo [SUCCESS] Server cert: "%CERT_DIR%\cert.pem"
echo [SUCCESS] Server key : "%CERT_DIR%\key.pem"
echo [SUCCESS] CA cert    : "%CERT_DIR%\local-dev-ca.pem"
popd
exit /b 0

:fail
echo [ERROR] Certificate generation failed.
popd
exit /b 1
