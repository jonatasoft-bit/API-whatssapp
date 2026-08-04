#!/usr/bin/env bash
# Gera impar-kit-v30.zip para distribuição no Windows.
# Execute a partir da raiz do repositório:
#   bash kit-windows/criar_kit.sh

set -euo pipefail

VERSAO="30"
NOME_KIT="impar-kit-v${VERSAO}"
SAIDA="${NOME_KIT}.zip"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
DEST="${TMP}/${NOME_KIT}"

echo "Montando kit ${NOME_KIT}..."
mkdir -p "${DEST}"

# Arquivos que vão dentro do zip
cp "${RAIZ}/manutencao_impar_v2.py"            "${DEST}/manutencao_impar_v2.py"
cp "${RAIZ}/kit-windows/instalar.ps1"          "${DEST}/instalar.ps1"
cp "${RAIZ}/kit-windows/instalar.bat"          "${DEST}/instalar.bat"
cp "${RAIZ}/GUIA_RAPIDO_V2.txt"               "${DEST}/GUIA_RAPIDO_V2.txt"
cp "${RAIZ}/MANUTENCAO_IMPAR_V2_MELHORIAS.md" "${DEST}/MANUTENCAO_IMPAR_V2_MELHORIAS.md"
cp "${RAIZ}/CHECKLIST_IMPLEMENTACAO.md"        "${DEST}/CHECKLIST_IMPLEMENTACAO.md"
cp "${RAIZ}/README.md"                         "${DEST}/README.md"

# Gerar o zip na raiz do repositório
cd "${TMP}"
zip -r "${RAIZ}/${SAIDA}" "${NOME_KIT}/" -x "*.DS_Store" "*/__MACOSX/*"

rm -rf "${TMP}"

echo ""
echo "Kit gerado: ${RAIZ}/${SAIDA}"
echo ""
echo "Instrucoes para o Windows:"
echo "  1. Copie ${SAIDA} para o PC com Windows"
echo "  2. Clique com botao direito > 'Extrair tudo'"
echo "  3. Abra a pasta extraida"
echo "  4. Clique com botao direito em 'instalar.bat' > 'Executar como administrador'"
