#!/bin/bash
# =============================================
#  Kit Piloto Automático V30 — Instalador macOS
#  Execute no Terminal: bash instalar.sh
# =============================================

set -e

# ---- Cores ----
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
echo -e "${BOLD}  Kit Piloto Automático V30 — Instalador macOS${NC}"
echo "  ============================================"
echo ""

step()  { echo -e "\n${BLUE}${BOLD}[ETAPA $1]${NC} $2"; }
ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()   { echo -e "  ${RED}✗${NC} $1"; }
info()  { echo -e "  ${CYAN}→${NC} $1"; }

ERRORS=()

# ============================================================
step "1/9" "Verificando conexão com a internet..."
# ============================================================
if ! curl -s --connect-timeout 5 https://example.com &>/dev/null; then
    err "Sem internet. Conecte-se à rede e tente novamente."
    exit 1
fi
ok "Internet OK"

# ============================================================
step "2/9" "Instalando Homebrew (gerenciador de programas)..."
# ============================================================
if ! command -v brew &>/dev/null; then
    info "Isso pode demorar alguns minutos — normal..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon path
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    ok "Homebrew instalado"
else
    ok "Homebrew já instalado"
fi

# ============================================================
step "3/9" "Instalando Node.js (necessário para o Claude)..."
# ============================================================
if ! command -v node &>/dev/null; then
    brew install node
    ok "Node.js instalado: $(node --version)"
else
    ok "Node.js já instalado: $(node --version)"
fi

# ============================================================
step "4/9" "Instalando Python 3 (automações)..."
# ============================================================
if ! command -v python3 &>/dev/null; then
    brew install python3
    ok "Python 3 instalado"
else
    ok "Python 3 já instalado: $(python3 --version)"
fi

# ============================================================
step "5/9" "Instalando Git (controle de versão)..."
# ============================================================
if ! command -v git &>/dev/null; then
    brew install git
    ok "Git instalado"
else
    ok "Git disponível"
fi

# ============================================================
step "6/9" "Instalando aplicativos principais..."
# ============================================================
install_cask() {
    local name="$1" cask="$2"
    if brew list --cask "$cask" &>/dev/null 2>&1; then
        ok "$name já instalado"
    else
        info "Instalando $name..."
        if brew install --cask "$cask" 2>/dev/null; then
            ok "$name instalado com sucesso"
        else
            warn "$name — não foi possível instalar via brew (pode já estar instalado)"
            ERRORS+=("$name")
        fi
    fi
}

install_cask "Claude Desktop" "claude"
install_cask "Obsidian"       "obsidian"
install_cask "WhatsApp"       "whatsapp"
install_cask "Docker Desktop" "docker"

# ============================================================
step "7/9" "Instalando Claude Code (interface de linha de comando)..."
# ============================================================
if ! command -v claude &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code instalado: $(claude --version 2>/dev/null || echo 'OK')"
else
    ok "Claude Code já instalado"
fi

# ============================================================
step "8/9" "Instalando n8n (automações avançadas)..."
# ============================================================
if ! command -v n8n &>/dev/null; then
    npm install -g n8n
    ok "n8n instalado"
else
    ok "n8n já disponível"
fi

# ============================================================
step "9/9" "Configurando WhatsApp MCP e Claude Desktop..."
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
        warn "WhatsApp MCP não pôde ser clonado agora — configure manualmente depois"
    fi
else
    ok "WhatsApp MCP já presente"
fi

# Detectar pasta do kit
KIT_PATH=""
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Kit-Piloto-Automatico-V30-DISTRIB"
DESKTOP="$HOME/Desktop/Kit-Piloto-Automatico-V30-DISTRIB"
DOCS="$HOME/Documents/Kit-Piloto-Automatico-V30-DISTRIB"

if [ -d "$ICLOUD" ];  then KIT_PATH="$ICLOUD";  ok "Kit encontrado no iCloud"
elif [ -d "$DESKTOP" ]; then KIT_PATH="$DESKTOP"; ok "Kit encontrado na Área de Trabalho"
elif [ -d "$DOCS" ];    then KIT_PATH="$DOCS";    ok "Kit encontrado em Documentos"
else
    warn "Pasta do kit não encontrada — configure o caminho manualmente em:"
    info "~/Library/Application Support/Claude/claude_desktop_config.json"
    KIT_PATH="$HOME/Documents/Kit-Piloto-Automatico-V30-DISTRIB"
fi

# Escrever config Claude Desktop
CONFIG_DIR="$HOME/Library/Application Support/Claude"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/claude_desktop_config.json" << JSONEOF
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
        "$KIT_PATH",
        "$HOME/Desktop",
        "$HOME/Documents"
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

ok "Configuração do Claude Desktop salva"

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
echo -e "  ${CYAN}1.${NC} Abra ${BOLD}Claude Desktop${NC} (Launchpad ou Aplicativos)"
echo -e "  ${CYAN}2.${NC} Crie uma conta em ${BOLD}claude.ai${NC} e faça login"
echo -e "  ${CYAN}3.${NC} Obtenha sua chave API em:"
echo -e "     ${BOLD}https://console.anthropic.com${NC}"
echo -e "     → Crie conta → API Keys → Create Key"
echo -e "  ${CYAN}4.${NC} No Claude Desktop, digite:"
echo -e "     ${BOLD}instalar kpa30${NC}"
echo -e "  ${CYAN}5.${NC} Siga o guia visual: abra ${BOLD}../ABRA-ME.html${NC} no Safari"
echo ""
echo -e "${YELLOW}Para WhatsApp e Facebook, siga os passos do guia HTML.${NC}"
echo ""
