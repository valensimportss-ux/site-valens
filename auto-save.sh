#!/bin/bash

# ============================================================
#  AUTO-SAVE → GITHUB + VERCEL
#  Monitoriza alterações, faz commit + push + deploy automático
# ============================================================

REPO_DIR="/Users/luisribeiro/site valens"
PID_FILE="$REPO_DIR/.autosave.pid"
LOG_FILE="$REPO_DIR/.autosave.log"
INTERVAL=10  # segundos entre verificações

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Guardar o PID do processo
echo $$ > "$PID_FILE"

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 AUTO-SAVE GITHUB + VERCEL - ATIVO  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo -e "${GREEN}✅ A monitorizar: $REPO_DIR${NC}"
echo -e "${GREEN}⏱  Intervalo: ${INTERVAL}s | PID: $$${NC}"
echo -e "${YELLOW}   Para parar: ./stop-autosave.sh${NC}\n"

cd "$REPO_DIR"

while true; do
    # Verificar se há alterações
    if [[ -n $(git status --porcelain) ]]; then
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        FILES_CHANGED=$(git status --porcelain | wc -l | tr -d ' ')

        echo -e "${YELLOW}[$TIMESTAMP] 📝 $FILES_CHANGED ficheiro(s) alterado(s) — a fazer commit...${NC}"

        # Adicionar tudo
        git add -A

        # Commit com timestamp
        COMMIT_MSG="auto-save: $TIMESTAMP"
        git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

        # Push para o GitHub
        if git push origin main >> "$LOG_FILE" 2>&1; then
            echo -e "${GREEN}[$TIMESTAMP] ✅ GitHub atualizado${NC}"
            echo "[$TIMESTAMP] ✅ Push OK: $COMMIT_MSG" >> "$LOG_FILE"

            # Deploy no Vercel
            echo -e "${YELLOW}[$TIMESTAMP] 🔄 A fazer deploy no Vercel...${NC}"
            if npx vercel --prod --yes >> "$LOG_FILE" 2>&1; then
                echo -e "${GREEN}[$TIMESTAMP] ✅ Site atualizado no Vercel!${NC}"
                echo "[$TIMESTAMP] ✅ Vercel deploy OK" >> "$LOG_FILE"
            else
                echo -e "${RED}[$TIMESTAMP] ❌ Erro no deploy Vercel — ver .autosave.log${NC}"
                echo "[$TIMESTAMP] ❌ Erro Vercel deploy" >> "$LOG_FILE"
            fi
        else
            echo -e "${RED}[$TIMESTAMP] ❌ Erro no push — ver .autosave.log${NC}"
            echo "[$TIMESTAMP] ❌ Erro no push" >> "$LOG_FILE"
        fi
    fi

    sleep "$INTERVAL"
done
