#!/bin/bash
# Landing page deployment script for Advogada Parceira

set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}    Advogada Parceira Landing Deploy    ${NC}"
echo -e "${GREEN}=========================================${NC}"

# Configurações
SERVER="ubuntu@18.217.19.191"
KEY_PATH="/Users/gregoryoliveira/AP/admin.pem"
REMOTE_DIR="/var/www/html/advogadaparceira.com.br"
REPO_URL="https://github.com/gregoryoliveiraa/advogadaparceira.git"
BRANCH="main"

echo -e "${YELLOW}Iniciando deploy do site estático...${NC}"

# Clona o repositório diretamente no servidor
echo -e "${YELLOW}Atualizando arquivos do site...${NC}"
ssh -i "$KEY_PATH" "$SERVER" "sudo rm -rf $REMOTE_DIR && \
    sudo mkdir -p $REMOTE_DIR && \
    sudo git clone -b $BRANCH $REPO_URL $REMOTE_DIR && \
    sudo chown -R www-data:www-data $REMOTE_DIR"

echo -e "${GREEN}Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}O site está disponível em: https://advogadaparceira.com.br${NC}" 