#!/usr/bin/env bash
#
# pos-os-postinstall.sh - Instalar e configura programas no Pop!_OS (20.04 LTS ou superior)
#
# Website:       https://diolinux.com.br
# Autor:         Dionatan Simioni
#
# ------------------------------------------------------------------------ #
#
# COMO USAR?
#   $ ./pos-os-postinstall.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #

##URLS

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_4K_VIDEO_DOWNLOADER="https://dl.4kdownload.com/app/4kvideodownloader_4.20.0-1_amd64.deb?source=website"
URL_INSYNC="https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.7.2.50318-impish_amd64.deb"
URL_SYNOLOGY_DRIVE="https://global.download.synology.com/download/Utility/SynologyDriveClient/3.0.3-12689/Ubuntu/Installer/x86_64/synology-drive-client-12689.x86_64.deb"
URL_WINFF_CONFIG="1d4axPEtdtaxVh6Aiw3m1mkuqhh9RfPRl"
URL_RESOLVE_CONFIG="1Uq2cv_C2UOznqvXa7AA6HRg4p49lWcMY"
URL_RESOLVE_DATABASE="URL_DE_PREFERENCIA"
URL_PHOTOGIMP="https://github.com/Diolinux/PhotoGIMP/releases/download/1.0/PhotoGIMP.by.Diolinux.v2020.for.Flatpak.zip"
URL_OBS_STUDIO_CONFIG="URL_DE_PREFERENCIA"
URL_ELECTRUM_APPIMAGE="https://download.electrum.org/4.1.5/electrum-4.1.5-x86_64.AppImage"

##DIRETÓRIOS E ARQUIVOS

DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
FILE="/home/$USER/.config/gtk-3.0/bookmarks"


#CORES

VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'


#FUNÇÕES

apt_update(){
  sudo apt update && sudo apt dist-upgrade
}

# -------------------------------TESTES E REQUISITOS----------------------------------------- #

# Internet conectando?
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${SEM_COR}"
  exit 1
else
  echo -e "${VERDE}[INFO] - Conexão com a Internet funcionando normalmente.${SEM_COR}"
fi

# wget está instalado?
if [[ ! -x $(which wget) ]]; then
  echo -e "${VERMELHO}[ERRO] - O programa wget não está instalado.${SEM_COR}"
  echo -e "${VERDE}[INFO] - Instalando o wget...${SEM_COR}"
  sudo apt install wget -y &> /dev/null
else
  echo -e "${VERDE}[INFO] - O programa wget já está instalado.${SEM_COR}"
fi
# ------------------------------------------------------------------------------ #
## Removendo travas eventuais do apt ##
travas_apt(){
  sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock
}
travas_apt

## Adicionando/Confirmando arquitetura de 32 bits ##
sudo dpkg --add-architecture i386

## Atualizando o repositório ##
sudo apt update -y


##DEB SOFTWARES TO INSTALL

PROGRAMAS_PARA_INSTALAR=(
  snapd
  steam-installer
  steam-devices
  winff
  virtualbox
  ratbagd
  lutris
  gparted
  timeshift
  gufw
  synaptic
  solaar
  vlc
  code
  gnome-sushi 
  folder-color
  git
 
)
# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##

echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"

mkdir "$DIRETORIO_DOWNLOADS"
wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_4K_VIDEO_DOWNLOADER" -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_INSYNC"              -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_SYNOLOGY_DRIVE"      -P "$DIRETORIO_DOWNLOADS"

##Download de arquivos do Google Drive##

echo -e "${VERDE}[INFO] - Baixando backups do Google Drive${SEM_COR}"


#Configuração de teclado Davinci Resolve

wget -c --no-check-certificate 'https://docs.google.com/uc?export=download&id='$URL_RESOLVE_CONFIG'' -O resolve-keyboard-diolinux.txt -P "$DIRETORIO_DOWNLOADS"

#Configuração do WINFF

wget -c --no-check-certificate 'https://docs.google.com/uc?export=download&id='$URL_WINFF_CONFIG'' -O winff_resolve_diolinux_.xml      -P "$DIRETORIO_DOWNLOADS"

#Configuração do OBS Studio Flatpak

cd "$DIRETORIO_DOWNLOADS"

#Baixa database do DaVinci Resolve
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id='$URL_RESOLVE_DATABASE'' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$URL_RESOLVE_DATABASE" -O "Local Database.resolve.diskdb" && rm -rf /tmp/cookies.txt


## Instalando pacotes .deb baixados na sessão anterior ##
echo -e "${VERDE}[INFO] - Instalando pacotes .deb baixados${SEM_COR}"
sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

# Instalar programas no apt
echo -e "${VERDE}[INFO] - Instalando pacotes apt do repositório${SEM_COR}"

travas_apt

for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_programa" -y
  else
    echo "[INSTALADO] - $nome_do_programa"
  fi
done

## Instalando pacotes Flatpak ##
  echo -e "${VERDE}[INFO] - Instalando pacotes flatpak${SEM_COR}"


flatpak install flathub com.obsproject.Studio -y
flatpak install flathub org.gimp.GIMP -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub com.bitwarden.desktop -y
flatpak install flathub org.telegram.desktop -y
flatpak install flathub org.freedesktop.Piper -y
flatpak install flathub org.chromium.Chromium -y
flatpak install flathub org.gnome.Boxes -y
flatpak install flathub org.onlyoffice.desktopeditors -y
flatpak install flathub org.qbittorrent.qBittorrent -y
flatpak install flathub org.flameshot.Flameshot -y


## Instalando pacotes Snap ##
echo -e "${VERDE}[INFO] - Instalando pacotes snap${SEM_COR}"

sudo snap install authy

# ---------------------------------------------------------------------- #

# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #
## Finalização, atualização e limpeza##
apt_update -y
flatpak update
sudo apt autoclean
sudo apt autoremove -y
nautilus -q
# -------------------------------------------------------------------------- #
# ----------------------------- CONFIGS ----------------------------- #

## Download de extensões GNOME e configurações ##


echo -e "${VERDE}[INFO] - Configurando o sistema${SEM_COR}"

#Configura o preset de configuração do WINFF

cp "$DIRETORIO_DOWNLOADS"/winff_resolve_diolinux_.xml /$USER/.winff/presets.xml

#Cria pastas para produtividade no nautilus

mkdir /home/$USER/TEMP
mkdir /home/$USER/EDITAR 
mkdir /home/$USER/Resolve
mkdir /home/$USER/AppImage
mkdir /home/$USER/Vídeos/'OBS Rec'

#Adiciona atalhos ao Nautilus

if test -f "$FILE"; then
    echo "$FILE já existe"
else
    echo "$FILE não existe, criando..."
    touch /home/$USER/.config/gkt-3.0/bookmarks
fi

echo "file:///home/$USER/EDITAR 🔵 EDITAR" >> $FILE
echo "file:///home/$USER/AppImage" >> $FILE
echo "file:///home/$USER/Resolve 🔴 Resolve" >> $FILE
echo "file:///home/$USER/TEMP 🕖 TEMP" >> $FILE

#Download do Electrum AppImage

wget -c "$URL_ELECTRUM_APPIMAGE" -P /home/$USER/AppImage

#Baixa e adiciona o PhotoGIMP ao GIMP Flatpak
wget -c "$URL_PHOTOGIMP"      -P "$DIRETORIO_DOWNLOADS"
unzip $DIRETORIO_DOWNLOADS/PhotoGIMP.by.Diolinux.v2020.for.Flatpak.zip
cd $DIRETORIO_DOWNLOADS/'PhotoGIMP by Diolinux v2020 for Flatpak'/
cp -R .local/ .var/ .icons/ /home/$USER/

#Baixa e adiciona configs ao OBS STUDIO flatpak
unzip $DIRETORIO_DOWNLOADS/com.obsproject.Studio.zip
cp -R com.obsproject.Studio /home/$USER/.var/app

## finalização

apt_update -y

  echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"



