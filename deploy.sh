#!/bin/bash
# Landing page deployment script for Advogada Parceira

set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Cria diretório temporário e clona o repositório localmente
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}Clonando repositório localmente...${NC}"
git clone -b $BRANCH $REPO_URL $TEMP_DIR

# Copia os arquivos para o servidor
echo -e "${YELLOW}Copiando arquivos para o servidor...${NC}"
REMOTE_TEMP_DIR="/tmp/ap-landing-deploy"
ssh -i "$KEY_PATH" "$SERVER" "rm -rf $REMOTE_TEMP_DIR && mkdir -p $REMOTE_TEMP_DIR"
scp -i "$KEY_PATH" -r $TEMP_DIR/* "$SERVER:$REMOTE_TEMP_DIR/"

# Move os arquivos para o diretório final
echo -e "${YELLOW}Movendo arquivos para o diretório final...${NC}"
ssh -i "$KEY_PATH" "$SERVER" "sudo rm -rf $REMOTE_DIR && \
    sudo mkdir -p $REMOTE_DIR && \
    sudo cp -r $REMOTE_TEMP_DIR/* $REMOTE_DIR/ && \
    sudo chown -R www-data:www-data $REMOTE_DIR && \
    rm -rf $REMOTE_TEMP_DIR"

# Configura o Nginx
echo -e "${YELLOW}Configurando Nginx...${NC}"
ssh -i "$KEY_PATH" "$SERVER" "sudo bash -c 'cat > /etc/nginx/sites-available/advogadaparceira.conf << EOL
server {
    listen 80;
    server_name advogadaparceira.com.br www.advogadaparceira.com.br;
    root $REMOTE_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
        expires 1h;
        add_header Cache-Control \"public, no-transform\";
    }

    location /api {
        proxy_pass https://api.advogadaparceira.com.br;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL'"

# Habilita o site e recarrega o Nginx
echo -e "${YELLOW}Habilitando site e recarregando Nginx...${NC}"
ssh -i "$KEY_PATH" "$SERVER" "sudo ln -sf /etc/nginx/sites-available/advogadaparceira.conf /etc/nginx/sites-enabled/ && sudo nginx -t && sudo systemctl reload nginx"

# Limpa o diretório temporário local
echo -e "${YELLOW}Limpando arquivos temporários...${NC}"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}O site está disponível em: https://advogadaparceira.com.br${NC}" 