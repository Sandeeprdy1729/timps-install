#!/usr/bin/env bash
set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "████████╗██╗███╗   ███╗██████╗ ███████╗"
echo "╚══██╔══╝██║████╗ ████║██╔══██╗██╔════╝"
echo "   ██║   ██║██╔████╔██║██████╔╝███████╗"
echo "   ██║   ██║██║╚██╔╝██║██╔═══╝ ╚════██║"
echo "   ██║   ██║██║ ╚═╝ ██║██║     ███████║"
echo "   ╚═╝   ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝"
echo ""
echo "${BLUE}Trustworthy Intelligent Memory & Privacy System${NC}"
echo "=================================================="
echo ""

# Function to check commands
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $2${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $3${NC}"
}

# Checks
check_command "node" "Node.js 18+ required. Install from https://nodejs.org" "Node: $(node -v)"
check_command "docker" "Docker required. Install from https://docker.com" "Docker: $(docker --version)"
check_command "git" "Git required. Install from https://git-scm.com" "Git: $(git --version | head -n1)"

# Clone or update TIMPs
if [ -d "timps" ]; then
    echo -e "${BLUE}📂 TIMPs exists. Pulling latest...${NC}"
    cd timps
    git pull origin main 2>/dev/null || git pull
else
    echo -e "${BLUE}📥 Cloning TIMPs...${NC}"
    git clone https://github.com/Sandeeprdy1729/timps.git
    cd timps
fi

# Install deps
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install --prefer-offline --no-audit

# Setup .env
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}📝 .env created from template${NC}"
    else
        echo -e "${BLUE}📝 Creating .env...${NC}"
        cat > .env << 'EOF'
NODE_ENV=development
PORT=3000
OPENAI_API_KEY=your_key_here
POSTGRES_URL=postgresql://postgres:postgres@localhost:5432/sandeep_ai
QDRANT_URL=http://localhost:6333
EOF
    fi
fi

# Docker containers
docker_start() {
    local name=$1
    local image=$2
    local args=$3
    
    if docker ps -a --filter "name=^${name}$" --format '{{.Names}}' | grep -q "^${name}$"; then
        echo -e "${BLUE}🔄 ${name} exists. Starting...${NC}"
        docker start "$name" 2>/dev/null || true
    else
        echo -e "${BLUE}🚀 Creating ${name}...${NC}"
        docker run -d --name "$name" $args "$image"
    fi
}

echo -e "${BLUE}🐳 Setting up Docker services...${NC}"
docker_start "timps-postgres" "postgres:14" \
    "-p 5432:5432 \
     -e POSTGRES_USER=postgres \
     -e POSTGRES_PASSWORD=postgres \
     -e POSTGRES_DB=sandeep_ai"

docker_start "timps-qdrant" "qdrant/qdrant" "-p 6333:6333"

sleep 3

# Build
echo -e "${BLUE}🔨 Building...${NC}"
npm run build 2>/dev/null || echo -e "${BLUE}ℹ️  Build step skipped${NC}"

echo ""
echo -e "${GREEN}🎉 TIMPs installed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "   cd timps/sandeep-ai"
echo "   npm run cli -- --user-id 1 --interactive"
echo ""
echo -e "${BLUE}Documentation:${NC} https://github.com/Sandeeprdy1729/timps"
echo ""
