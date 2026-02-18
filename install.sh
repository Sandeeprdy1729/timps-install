#!/usr/bin/env bash

set -e

echo "🚀 Installing TIMPs - Trustworthy Intelligent Memory & Privacy System"
echo "---------------------------------------------------------------------"

# 1️⃣ Check Node
if ! command -v node &> /dev/null
then
    echo "❌ Node.js not found. Please install Node 18+ and rerun."
    exit 1
fi

echo "✅ Node detected: $(node -v)"

# 2️⃣ Check Docker
if ! command -v docker &> /dev/null
then
    echo "⚠️ Docker not found. TIMPs requires Docker for PostgreSQL & Qdrant."
    echo "Install Docker Desktop and rerun."
    exit 1
fi

echo "✅ Docker detected"

# 3️⃣ Clone TIMPs
if [ -d "timps" ]; then
    echo "📂 TIMPs folder already exists. Skipping clone."
else
    echo "📥 Cloning TIMPs..."
    git clone https://github.com/YOUR_USERNAME/timps.git
fi

cd timps

# 4️⃣ Install dependencies
echo "📦 Installing dependencies..."
npm install

# 5️⃣ Setup .env
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
fi

# 6️⃣ Start PostgreSQL
echo "🐘 Starting PostgreSQL..."
docker run -d \
  --name timps-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=sandeep_ai \
  postgres:14 || true

# 7️⃣ Start Qdrant
echo "🧠 Starting Qdrant..."
docker run -d \
  --name timps-qdrant \
  -p 6333:6333 \
  qdrant/qdrant || true

sleep 5

# 8️⃣ Build project
echo "🔨 Building TIMPs..."
npm run build

echo ""
echo "🎉 TIMPs installed successfully!"
echo ""
echo "Run it with:"
echo "   cd timps"
echo "   npm run cli -- --user-id 1 --interactive"
echo ""
