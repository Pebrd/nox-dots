#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# nox-dots — Nox Design System theme installer
# github.com/pebrd/nox-dots
#
# Uso: curl -fsSL https://raw.githubusercontent.com/pebrd/nox-dots/main/install.sh | bash
#      curl -fsSL https://raw.githubusercontent.com/pebrd/nox-dots/main/install.sh | bash -s -- install
# ──────────────────────────────────────────────────────────
set -euo pipefail

APP_NAME="nox-dots"
REPO="pebrd/nox-dots"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# ── Colors ──────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[1;34m'
NC='\033[0m'; BOLD='\033[1m'

info()  { printf "${G}%s${NC}\n" "$*"; }
ok()    { printf "${G}✔${NC} %s\n" "$*"; }
warn()  { printf "${Y}⚠${NC} %s\n" "$*"; }
err()   { printf "${R}✘${NC} %s\n" "$*"; exit 1; }
header(){ printf "\n${BOLD}%s${NC}\n" "$*"; }
dim()   { printf "\033[2m%s\033[0m\n" "$*"; }

# ── Input (compatible con curl | bash) ───────────────────
# Toma de /dev/tty si existe, sino de stdin.
read_choice() {
    local prompt="$1" var="$2"
    printf "%s" "$prompt"
    if (: </dev/tty) 2>/dev/null; then
        IFS= read -r "$var" </dev/tty
    else
        IFS= read -r "$var"
    fi
}

# ── Helpers ─────────────────────────────────────────────
fetch() {
    local path="$1" out="$2"
    if command -v curl &>/dev/null; then
        curl -fsSL "${RAW}/${path}" -o "$out"
    elif command -v wget &>/dev/null; then
        wget -q "${RAW}/${path}" -O "$out"
    else
        return 1
    fi
}

# ── Instaladores ────────────────────────────────────────

install_discord() {
    echo ""
    info "Installing Discord / Vencord..."

    local theme_dir
    if [ -d "$HOME/.config/vesktop/themes" ]; then
        theme_dir="$HOME/.config/vesktop/themes"
    elif [ -d "$HOME/.config/Vencord/themes" ]; then
        theme_dir="$HOME/.config/Vencord/themes"
    else
        warn "No se encontro ~/.config/vesktop/themes ni ~/.config/Vencord/themes"
        theme_dir="$HOME/.config/vesktop/themes"
        mkdir -p "$theme_dir"
    fi

    local tmp; tmp="$(mktemp)"
    fetch "discord/nox-void-vencord.css" "$tmp" || { err "No se pudo descargar el tema Discord"; return; }
    cp "$tmp" "$theme_dir/nox-void-vencord.theme.css"
    rm -f "$tmp"
    ok "Tema Discord instalado en ${theme_dir}/nox-void-vencord.theme.css"
    dim "  Activarlo: Vencord > Settings > Themes > Enable 'nox-void-vencord'"
    dim "  Requisito: Discord > Apariencia > Tema base > Onyx"
}

install_firefox() {
    echo ""
    info "Installing Firefox / LibreWolf..."

    local profile_dir="" browser=""

    for d in "$HOME/.librewolf/"*.default-*/ "$HOME/.librewolf/"*.default/; do
        if [ -d "$d" ]; then profile_dir="$d"; browser="librewolf"; break; fi
    done

    if [ -z "$profile_dir" ]; then
        for d in "$HOME/.mozilla/firefox/"*.default-*/ "$HOME/.mozilla/firefox/"*.default/; do
            if [ -d "$d" ]; then profile_dir="$d"; browser="firefox"; break; fi
        done
    fi

    if [ -z "$profile_dir" ]; then
        warn "No se encontro perfil de Firefox ni LibreWolf"
        dim "  Copia firefox/chrome/ manualmente a tu perfil"
        return
    fi

    ok "Perfil: ${browser} -> $(basename "$profile_dir")"

    local tmp; tmp="$(mktemp -d)"
    local files=(
        userChrome.css
        includes/cascade-colours.css
        includes/cascade-config.css
        includes/cascade-layout.css
        includes/cascade-responsive.css
        includes/cascade-floating-panel.css
        includes/cascade-nav-bar.css
        includes/cascade-tabs.css
        includes/cascade-responsive-windows-fix.css
    )
    local all_ok=true
    for f in "${files[@]}"; do
        mkdir -p "$(dirname "${tmp}/chrome/${f}")"
        fetch "firefox/chrome/${f}" "${tmp}/chrome/${f}" || { warn "Fallo ${f}"; all_ok=false; break; }
    done

    if $all_ok; then
        mkdir -p "$profile_dir/chrome"
        cp -r "${tmp}/chrome/"* "$profile_dir/chrome/"
        ok "Tema Firefox instalado en ${profile_dir}chrome/"
        dim "  Reinicia ${browser} para aplicar"
    fi
    rm -rf "$tmp"
}

install_kde() {
    echo ""
    info "Installing KDE Plasma..."

    local tmp; tmp="$(mktemp -d)"
    fetch "kde/NoxVoid/contents/colors/NoxVoid.colors" "${tmp}/NoxVoid.colors" || { err "No se pudo descargar KDE color scheme"; rm -rf "$tmp"; return; }
    mkdir -p "$HOME/.local/share/color-schemes"
    cp "${tmp}/NoxVoid.colors" "$HOME/.local/share/color-schemes/NoxVoid.colors"
    ok "Color scheme instalado en ~/.local/share/color-schemes/NoxVoid.colors"

    echo ""
    read_choice "Instalar Look and Feel completo de KDE? (s/N): " ans
    if [[ "$ans" =~ ^[sSyY] ]]; then
        local laf_dir="${tmp}/NoxVoid"
        mkdir -p "${laf_dir}/contents/colors" "${laf_dir}/contents/layouts" "${laf_dir}/contents/defaults"
        mkdir -p "${laf_dir}/contents/plasmoids"

        fetch "kde/NoxVoid/metadata.json" "${laf_dir}/metadata.json" || { warn "Fallo metadata.json"; rm -rf "$tmp"; return; }
        fetch "kde/NoxVoid/contents/colors/NoxVoid.colors" "${laf_dir}/contents/colors/NoxVoid.colors" || true
        fetch "kde/NoxVoid/contents/layouts/org.kde.plasma.desktop-layout.js" "${laf_dir}/contents/layouts/org.kde.plasma.desktop-layout.js" || true

        mkdir -p "$HOME/.local/share/plasma/look-and-feel"
        cp -r "${laf_dir}" "$HOME/.local/share/plasma/look-and-feel/NoxVoid"
        ok "Look and Feel instalado"
        dim "  Aplicar: System Settings > Appearance > Look and Feel > NoxVoid"
    fi
    rm -rf "$tmp"
}

install_kitty() {
    echo ""
    info "Installing Kitty..."

    local tmp; tmp="$(mktemp)"
    fetch "kitty/nox-void.conf" "$tmp" || { err "No se pudo descargar el tema Kitty"; rm -f "$tmp"; return; }

    mkdir -p "$HOME/.config/kitty/themes"
    cp "$tmp" "$HOME/.config/kitty/themes/nox-void.conf"
    ok "Tema copiado a ~/.config/kitty/themes/nox-void.conf"

    if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
        if ! grep -q "nox-void" "$HOME/.config/kitty/kitty.conf" 2>/dev/null; then
            read_choice "Agregar include de nox-void a kitty.conf? (s/N): " ans
            if [[ "$ans" =~ ^[sSyY] ]]; then
                echo "" >> "$HOME/.config/kitty/kitty.conf"
                echo "# Nox Void theme" >> "$HOME/.config/kitty/kitty.conf"
                echo "include themes/nox-void.conf" >> "$HOME/.config/kitty/kitty.conf"
                ok "Include agregado a kitty.conf"
            fi
        else
            ok "Ya configurado en kitty.conf"
        fi
    else
        warn "No existe kitty.conf"
        dim "  Agrega manualmente: 'include themes/nox-void.conf' a ~/.config/kitty/kitty.conf"
    fi

    rm -f "$tmp"
}

# ── Comandos ────────────────────────────────────────────

cmd_install() {
    dim "${APP_NAME} installer"
    echo ""
    echo "Que queres instalar?"
    echo "  1) Discord (Vencord)"
    echo "  2) Firefox / LibreWolf (Cascade)"
    echo "  3) KDE Plasma"
    echo "  4) Kitty (terminal)"
    echo "  5) Todo"
    echo ""
    read_choice "Opcion [1-5]: " opt

    case "$opt" in
        1) install_discord ;;
        2) install_firefox ;;
        3) install_kde ;;
        4) install_kitty ;;
        5) install_discord; install_firefox; install_kde; install_kitty ;;
        *) err "Opcion invalida" ;;
    esac
    echo ""
    ok "Listo!"
}

cmd_update() {
    header "Update"
    warn "Aun no implementado. Ejecuta el instalador de nuevo para reinstalar."
}

cmd_uninstall() {
    header "Uninstall"
    echo "Esto eliminara los archivos de temas instalados."
    echo ""
    echo "  1) Solo temas Discord/Kitty (no toca Firefox/KDE)"
    echo "  2) Todo"
    echo ""
    read_choice "Opcion [1/2]: " ans
    case "$ans" in
        1)
            rm -f "$HOME/.config/vesktop/themes/nox-void-vencord.theme.css" 2>/dev/null || true
            rm -f "$HOME/.config/Vencord/themes/nox-void-vencord.theme.css" 2>/dev/null || true
            rm -f "$HOME/.config/kitty/themes/nox-void.conf" 2>/dev/null || true
            ok "Removidos temas Discord y Kitty"
            ;;
        2)
            rm -f "$HOME/.config/vesktop/themes/nox-void-vencord.theme.css" 2>/dev/null || true
            rm -f "$HOME/.config/Vencord/themes/nox-void-vencord.theme.css" 2>/dev/null || true
            rm -f "$HOME/.config/kitty/themes/nox-void.conf" 2>/dev/null || true
            rm -f "$HOME/.local/share/color-schemes/NoxVoid.colors" 2>/dev/null || true
            rm -rf "$HOME/.local/share/plasma/look-and-feel/NoxVoid" 2>/dev/null || true
            # Firefox: sacar archivos de chrome/ pero sin borrar el perfil
            for d in "$HOME/.librewolf/"*.default-*/ "$HOME/.mozilla/firefox/"*.default-*/ "$HOME/.mozilla/firefox/"*.default/; do
                [ -d "${d}chrome" ] && rm -f "${d}chrome/userChrome.css" "${d}chrome/includes/"*.css 2>/dev/null || true
            done
            ok "Removidos todos los temas"
            ;;
        *) err "Cancelado" ;;
    esac
}

# ── Menu principal ──────────────────────────────────────
show_menu() {
    echo "╭──────────────────────────────╮"
    echo "│     Nox Void Theme Installer  │"
    echo "╰──────────────────────────────╯"
    echo ""
    echo "  1) Install"
    echo "  2) Update"
    echo "  3) Uninstall"
    echo "  q) Quit"
    echo ""
    read_choice "Choice: " cmd
    case "$cmd" in
        1|install)   cmd_install ;;
        2|update)    cmd_update ;;
        3|uninstall) cmd_uninstall ;;
        q|Q|quit)    exit 0 ;;
        *)           warn "Opcion invalida"; show_menu ;;
    esac
}

# ── Dispatch ────────────────────────────────────────────
main() {
    case "${1:-}" in
        install|i)   shift; cmd_install "$@" ;;
        update|up|u) shift; cmd_update "$@" ;;
        uninstall|rm) cmd_uninstall ;;
        --help|-h)   echo "Uso: $0 [install|update|uninstall]" ;;
        *)           show_menu ;;
    esac
}

main "$@"
