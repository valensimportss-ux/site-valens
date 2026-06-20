#!/bin/bash

# ============================================================
#  PARAR AUTO-SAVE
# ============================================================

PID_FILE="/Users/luisribeiro/site valens/.autosave.pid"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm "$PID_FILE"
        echo -e "${GREEN}✅ Auto-save parado (PID: $PID)${NC}"
    else
        echo -e "${RED}⚠️  Processo não encontrado (já estava parado?)${NC}"
        rm "$PID_FILE"
    fi
else
    echo -e "${RED}❌ Auto-save não está ativo${NC}"
fi
