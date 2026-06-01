#!/usr/bin/env bash
#
# nox-dots — Nox Design System theme installer
# https://github.com/pebrd/nox-dots
#
# Uso: curl -fsSL https://raw.githubusercontent.com/pebrd/nox-dots/main/install.sh | bash
#
set -euo pipefail

REPO="https://raw.githubusercontent.com/pebrd/nox-dots/main"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[-]${NC} $*"; }
info() { echo -e "${CYAN}[*]${NC} $*"; }

fetch() {
    local path="$1" out="$2"
    curl -fsSL "$REPO/$path" -o "$out"
}

# ────────────────────────────────────────────────────────────
# MENU
# ────────────────────────────────────────────────────────────

menu() {
    local title="$1"; shift
    local items=("$@")
    local len=${#items[@]}
    local sel=0

    # soporte interactive si hay stdin
    if [ -t 0 ]; then
        echo -e "\n${CYAN}╔══ ${title} ══╗${NC}"
        for i in "${!items[@]}"; do
            echo -e "${CYAN}║${NC}  $((i+1)). ${items[$i]}"
        done
        echo -e "${CYAN}╚════════════════════════╝${NC}"
        echo ""
        read -rp "Elegi una opcion (1-${len}): " sel
    else
        # modo pipe — mostrar lista y pedir input
        echo ""
        echo "=== ${title} ==="
        for i in "${!items[@]}"; do
            echo "  $((i+1)). ${items[$i]}"
        done
        echo ""
        read -rp "Elegi una opcion (1-${len}): " sel
    fi

    echo "$sel"
}

confirm() {
    local msg="$1"
    local resp
    read -rp "${msg} (s/N): " resp
    [[ "$resp" =~ ^[sSyY] ]]
}

# ────────────────────────────────────────────────────────────
# INSTALADORES
# ────────────────────────────────────────────────────────────

install_discord() {
    echo ""
    info "Instalando tema Discord / Vencord..."

    # detectar carpeta de themes
    local theme_dir
    if [ -d "$HOME/.config/vesktop/themes" ]; then
        theme_dir="$HOME/.config/vesktop/themes"
    elif [ -d "$HOME/.config/Vencord/themes" ]; then
        theme_dir="$HOME/.config/Vencord/themes"
    else
        warn "No se encontro ~/.config/vesktop/themes ni ~/.config/Vencord/themes"
        info "Creando ~/.config/vesktop/themes..."
        mkdir -p "$HOME/.config/vesktop/themes"
        theme_dir="$HOME/.config/vesktop/themes"
    fi

    fetch "discord/nox-void-vencord.css" "$TMPDIR/nox-void-vencord.css"
    cp "$TMPDIR/nox-void-vencord.css" "$theme_dir/nox-void-vencord.theme.css"
    log "Instalado en $theme_dir/nox-void-vencord.theme.css"
    info "Recorda activarlo en Vencord: Settings > Themes > Enable 'nox-void-vencord'"
    echo ""
    info "Requisito: Discord > Apariencia > Tema base > Onyx"
}

install_firefox() {
    echo ""
    info "Instalando tema Firefox / LibreWolf (Cascade)..."

    # detectar perfil de Firefox/LibreWolf
    local profile_dir=""
    local browser=""

    # buscar perfiles de LibreWolf
    for d in "$HOME/.librewolf/"*.default-*/; do
        if [ -d "$d" ]; then
            profile_dir="$d"
            browser="librewolf"
            break
        fi
    done

    # si no, buscar Firefox
    if [ -z "$profile_dir" ]; then
        for d in "$HOME/.mozilla/firefox/"*.default-*/ "$HOME/.mozilla/firefox/"*.default/; do
            if [ -d "$d" ]; then
                profile_dir="$d"
                browser="firefox"
                break
            fi
        done
    fi

    if [ -z "$profile_dir" ]; then
        err "No se encontro perfil de Firefox ni LibreWolf"
        err "Copia manual: clona nox-dots y copia firefox/chrome/ a tu perfil"
        return 1
    fi

    log "Perfil detectado: ${browser} → $(basename "$profile_dir")"

    # descargar carpeta chrome
    mkdir -p "$TMPDIR/chrome/includes"
    for f in \
        userChrome.css \
        includes/cascade-colours.css \
        includes/cascade-config.css \
        includes/cascade-layout.css \
        includes/cascade-responsive.css \
        includes/cascade-floating-panel.css \
        includes/cascade-nav-bar.css \
        includes/cascade-tabs.css \
        includes/cascade-responsive-windows-fix.css; do
        fetch "firefox/chrome/$f" "$TMPDIR/chrome/$f"
    done

    # copiar al perfil (merge)
    mkdir -p "$profile_dir/chrome"
    cp -r "$TMPDIR/chrome/"* "$profile_dir/chrome/"
    log "Instalado en $profile_dir/chrome/"
    info "Reinicia ${browser} para aplicar el tema"
}

install_kde() {
    echo ""
    info "Instalando tema KDE Plasma..."

    fetch "kde/NoxVoid/contents/colors/NoxVoid.colors" "$TMPDIR/NoxVoid.colors"
    mkdir -p "$HOME/.local/share/color-schemes"
    cp "$TMPDIR/NoxVoid.colors" "$HOME/.local/share/color-schemes/NoxVoid.colors"
    log "Color scheme instalado"

    # Look and Feel completo (opcional)
    if confirm "Instalar Look and Feel completo de KDE (recomendado)"; then
        mkdir -p "$TMPDIR/NoxVoid"
        # descargar estructura
        for f in \
            metadata.json \
            contents/colors/NoxVoid.colors \
            contents/layouts/org.kde.plasma.desktop-layout.js; do
            mkdir -p "$TMPDIR/NoxVoid/$(dirname "$f")"
            fetch "kde/NoxVoid/$f" "$TMPDIR/NoxVoid/$f"
        done

        # el contents/defaults es un directorio vacio
        mkdir -p "$TMPDIR/NoxVoid/contents/defaults"

        mkdir -p "$HOME/.local/share/plasma/look-and-feel"
        cp -r "$TMPDIR/NoxVoid" "$HOME/.local/share/plasma/look-and-feel/NoxVoid"
        log "Look and Feel instalado"
        info "Aplicar: System Settings > Appearance > Look and Feel > NoxVoid"
    fi
}

install_kitty() {
    echo ""
    info "Instalando tema Kitty..."

    fetch "kitty/nox-void.conf" "$TMPDIR/nox-void.conf"

    # opcion 1: como tema nombrado
    mkdir -p "$HOME/.config/kitty/themes"
    cp "$TMPDIR/nox-void.conf" "$HOME/.config/kitty/themes/nox-void.conf"

    if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
        if grep -q "nox-void" "$HOME/.config/kitty/kitty.conf" 2>/dev/null; then
            log "Ya esta configurado en kitty.conf"
        elif confirm "Agregar include de nox-void a kitty.conf"; then
            echo "" >> "$HOME/.config/kitty/kitty.conf"
            echo "# Nox Void theme" >> "$HOME/.config/kitty/kitty.conf"
            echo "include themes/nox-void.conf" >> "$HOME/.config/kitty/kitty.conf"
            log "Include agregado a kitty.conf"
        fi
    else
        warn "No se encontro kitty.conf. Tema copiado a ~/.config/kitty/themes/"
        info "Agrega manualmente: 'include themes/nox-void.conf' a tu kitty.conf"
    fi

    log "Tema Kitty instalado"
}

install_all() {
    install_discord
    install_firefox
    install_kde
    install_kitty
}

# ────────────────────────────────────────────────────────────
# MAIN
# ────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Nox Void — Theme Installer       ║${NC}"
echo -e "${CYAN}║   github.com/pebrd/nox-dots              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

while true; do
    echo ""
    echo "Que tema queres instalar?"
    echo "  1. Discord (Vencord)"
    echo "  2. Firefox / LibreWolf"
    echo "  3. KDE Plasma"
    echo "  4. Kitty (terminal)"
    echo "  5. Todos"
    echo "  0. Salir"
    echo ""
    read -rp "Opcion: " opt

    case "$opt" in
        1) install_discord ;;
        2) install_firefox ;;
        3) install_kde ;;
        4) install_kitty ;;
        5) install_all ;;
        0) echo ""; log "Chau!"; exit 0 ;;
        *) warn "Opcion invalida: $opt" ;;
    esac

    if [ "$opt" != "0" ]; then
        echo ""
        confirm "Instalar otro tema" || break
    fi
done

echo ""
log "Hecho!"
