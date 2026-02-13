#!/bin/bash
set -e

echo "Starting SQL Server container..."

echo "Waiting for Docker daemon to be ready..."
for i in {1..60}; do
  if docker info > /dev/null 2>&1; then
    echo "Docker daemon is ready."
    break
  fi

  if [ $i -eq 60 ]; then
    echo "Timeout waiting for Docker daemon"
    exit 1
  fi

  echo "Waiting for Docker daemon... ($i/60)"
  sleep 1
done

# 既存のコンテナを確認
if docker ps -a --format '{{.Names}}' | grep -q '^sqlserver$'; then
  echo "SQL Server container already exists. Starting it..."
  docker start sqlserver
else
  echo "Creating new SQL Server container..."
  docker run -d \
    --name sqlserver \
    -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=YourStrong@Passw0rd" \
    -e "MSSQL_PID=Developer" \
    -p 1433:1433 \
    mcr.microsoft.com/mssql/server:2022-latest
fi

echo "Waiting for SQL Server to be ready..."

# SQL Server が起動するまで待機（最大60秒）
for i in {1..60}; do
  if docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "YourStrong@Passw0rd" -C \
    -Q "SELECT 1" &> /dev/null; then
    echo "SQL Server is ready!"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "Timeout waiting for SQL Server"
    exit 1
  fi
  echo "Waiting... ($i/60)"
  sleep 1
done

# データベースが存在するかチェック
DB_EXISTS=$(docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong@Passw0rd" -C -h -1 \
  -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'pubs'" | tr -d '[:space:]')

# 初期化SQLスクリプトを実行（データベースが存在しない場合のみ）
if [ "$DB_EXISTS" = "0" ] && [ -f ".devcontainer/init-db.sql" ]; then
  echo "Copying init-db.sql to container..."
  docker cp .devcontainer/init-db.sql sqlserver:/tmp/init-db.sql
  
  echo "Executing initialization SQL script..."
  docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "YourStrong@Passw0rd" -C \
    -i /tmp/init-db.sql
  echo "Database initialization completed!"
elif [ "$DB_EXISTS" != "0" ]; then
  echo "Database 'pubs' already exists, skipping initialization."
else
  echo "Warning: .devcontainer/init-db.sql not found, skipping database initialization."
fi

echo "SQL Server setup completed successfully!"
echo "Connection string: Server=localhost,1433;Database=pubs;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True"
