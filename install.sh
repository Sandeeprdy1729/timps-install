#!/usr/bin/env bash
set -e

echo ""
echo "████████╗██╗███╗   ███╗██████╗ ███████╗"
echo "╚══██╔══╝██║████╗ ████║██╔══██╗██╔════╝"
echo "   ██║   ██║██╔████╔██║██████╔╝███████╗"
echo "   ██║   ██║██║╚██╔╝██║██╔═══╝ ╚════██║"
echo "   ██║   ██║██║ ╚═╝ ██║██║     ███████║"
echo "   ╚═╝   ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝"
echo ""
echo "Trustworthy Intelligent Memory & Privacy System"
echo "------------------------------------------------"
echo ""

# 1️⃣ Check Node
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 18+ required. Install from https://nodejs.org"
    exit 1
fi

echo "✅ Node: $(node -v)"

# 2️⃣ Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker required. Install Docker Desktop."
    exit 1
fi

echo "✅ Docker detected"

# 3️⃣ Clone or update TIMPs
if [ -d "timps" ]; then
    echo "📂 TIMPs exists. Pulling latest..."
    cd timps
    git pull
else
    echo "📥 Cloning TIMPs..."
    git clone https://github.com/Sandeeprdy1729/timps.git
    cd timps
fi

# 4️⃣ Install deps
echo "📦 Installing dependencies..."
npm install

# 5️⃣ Setup .env
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "📝 .env created"
fi

# 6️⃣ Start PostgreSQL (safe mode)
if docker ps -a | grep -q timps-postgres; then
    echo "🐘 PostgreSQL container exists. Starting..."
    docker start timps-postgres || true
else
    echo "🐘 Creating PostgreSQL container..."
    docker run -d \
      --name timps-postgres \
      -p 5432:5432 \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=postgres \
      -e POSTGRES_DB=sandeep_ai \
      postgres:14
fi

# 7️⃣ Start Qdrant
if docker ps -a | grep -q timps-qdrant; then
    echo "🧠 Qdrant container exists. Starting..."
    docker start timps-qdrant || true
else
    echo "🧠 Creating Qdrant container..."
    docker run -d \
      --name timps-qdrant \
      -p 6333:6333 \
      qdrant/qdrant
fi

sleep 5

# 8️⃣ Build
echo "🔨 Building..."
npm run build

echo ""
echo "🎉 TIMPs installed successfully!"
echo ""
echo "Run with:"
echo "   cd timps"
echo "   npm run cli -- --user-id 1 --interactive"
echo ""
echo "Welcome to privacy-first AI."
