#!/bin/bash
# =============================================
#  Kit Piloto Automático V30 — Instalador Linux
#  Execute no Terminal: bash instalar.sh
# =============================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}"
echo "  ██╗  ██╗██████╗  █████╗ ██████╗  ██████╗"
echo "  ██║ ██╔╝██╔══██╗██╔══██╗╚════██╗██╔═████╗"
echo "  █████╔╝ ██████╔╝███████║ █████╔╝██║██╔██║"
echo "  ██╔═██╗ ██╔═══╝ ██╔══██║ ╚═══██╗████╔╝██║"
echo "  ██║  ██╗██║     ██║  ██║██████╔╝╚██████╔╝"
echo "  ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═════╝  ╚═════╝"
echo -e "${NC}"
echo -e "${BOLD}  Kit Piloto Automático V30 — Instalador Linux${NC}"
echo "  ============================================"
echo ""

step()  { echo -e "\n${BLUE}${BOLD}[ETAPA $1]${NC} $2"; }
ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
info()  { echo -e "  ${CYAN}→${NC} $1"; }

ERRORS=()

# ============================================================
step "1/7" "Verificando conexão com a internet..."
# ============================================================
if ! curl -s --connect-timeout 5 https://example.com &>/dev/null; then
    echo -e "  ${RED}✗${NC} Sem internet. Conecte-se à rede e tente novamente."
    exit 1
fi
ok "Internet OK"

# ============================================================
step "2/7" "Verificando/Instalando Node.js..."
# ============================================================
if ! command -v node &>/dev/null; then
    info "Instalando Node.js via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    ok "Node.js instalado: $(node --version)"
else
    ok "Node.js já instalado: $(node --version)"
fi

# ============================================================
step "3/7" "Verificando/Instalando Python 3..."
# ============================================================
if ! command -v python3 &>/dev/null; then
    sudo apt-get install -y python3 python3-pip
    ok "Python 3 instalado"
else
    ok "Python 3 já instalado: $(python3 --version)"
fi

# ============================================================
step "4/7" "Verificando/Instalando Git..."
# ============================================================
if ! command -v git &>/dev/null; then
    sudo apt-get install -y git
    ok "Git instalado"
else
    ok "Git disponível: $(git --version)"
fi

# ============================================================
step "5/7" "Instalando Claude Code..."
# ============================================================
if ! command -v claude &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code instalado"
else
    ok "Claude Code já instalado: $(claude --version 2>/dev/null | head -1)"
fi

# ============================================================
step "6/7" "Instalando n8n (automações avançadas)..."
# ============================================================
if ! command -v n8n &>/dev/null; then
    npm install -g n8n
    ok "n8n instalado: $(n8n --version)"
else
    ok "n8n já instalado: $(n8n --version)"
fi

# ============================================================
step "7/7" "Configurando MCPs do Claude Code..."
# ============================================================
MCP_DIR="$HOME/mcps"
mkdir -p "$MCP_DIR"

# Clone WhatsApp MCP
if [ ! -d "$MCP_DIR/whatsapp-mcp" ]; then
    info "Clonando WhatsApp MCP..."
    if git clone https://github.com/lharries/whatsapp-mcp.git "$MCP_DIR/whatsapp-mcp" 2>/dev/null; then
        cd "$MCP_DIR/whatsapp-mcp" && npm install --silent 2>/dev/null && cd - >/dev/null
        ok "WhatsApp MCP configurado em ~/mcps/whatsapp-mcp"
    else
        warn "WhatsApp MCP não pôde ser clonado — configure manualmente depois"
        ERRORS+=("whatsapp-mcp")
    fi
else
    ok "WhatsApp MCP já presente"
fi

# Configurar settings do Claude Code com MCPs
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

cat > "$CLAUDE_DIR/settings.json" << 'JSONEOF'
{
  "mcpServers": {
    "composio": {
      "command": "npx",
      "args": ["-y", "@composio/rube-mcp"]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "~/Documents",
        "~/Desktop"
      ]
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
JSONEOF

ok "MCPs configurados em ~/.claude/settings.json"

# ============================================================
#  RESUMO FINAL
# ============================================================
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║       ✅  INSTALAÇÃO CONCLUÍDA!          ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

if [ ${#ERRORS[@]} -gt 0 ]; then
    warn "Alguns itens precisam de atenção: ${ERRORS[*]}"
    echo ""
fi

echo -e "${BOLD}PRÓXIMOS PASSOS:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} Obtenha sua chave API em ${BOLD}https://console.anthropic.com${NC}"
echo -e "     → Crie conta → API Keys → Create Key"
echo -e "  ${CYAN}2.${NC} No terminal, execute:"
echo -e "     ${BOLD}claude login${NC}"
echo -e "  ${CYAN}3.${NC} No Claude, digite:"
echo -e "     ${BOLD}instalar kpa30${NC}"
echo ""
