#!/usr/bin/env bash
#
# nox-dots — Nox Design System theme installer
# https://github.com/pebrd/nox-dots
#
# Uso: curl -fsSL https://raw.githubusercontent.com/pebrd/nox-dots/main/install.sh | bash
#
set -euo pipefail

# Redirigir stdin a la terminal para poder leer input aunque el script
# se ejecute via pipe (curl ... | bash).
if [ -e /dev/tty ]; then
    exec </dev/tty
fi

REPO="https://raw.githubusercontent.com/pebrd/nox-dots/main"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

confirm() {
    local msg="$1" resp
    read -rp "${msg} (s/N): " resp
    [[ "$resp" =~ ^[sSyY] ]]
}

fetch() {
    local path="$1" out="$2"
    curl -fsSL "$REPO/$path" -o "$out"
}

# ── instaladores ──────────────────────────────────────────

install_discord() {
    echo ""
    echo "[*] Instalando Discord / Vencord..."

    local theme_dir
    if [ -d "$HOME/.config/vesktop/themes" ]; then
        theme_dir="$HOME/.config/vesktop/themes"
    elif [ -d "$HOME/.config/Vencord/themes" ]; then
        theme_dir="$HOME/.config/Vencord/themes"
    else
        echo "[!] No se encontro ~/.config/vesktop/themes ni ~/.config/Vencord/themes"
        mkdir -p "$HOME/.config/vesktop/themes"
        theme_dir="$HOME/.config/vesktop/themes"
    fi

    fetch "discord/nox-void-vencord.css" "$TMPDIR/nox-void-vencord.css"
    cp "$TMPDIR/nox-void-vencord.css" "$theme_dir/nox-void-vencord.theme.css"
    echo "[+] Tema Discord instalado en $theme_dir/nox-void-vencord.theme.css"
    echo "[*] Activarlo en Vencord: Settings > Themes > Enable 'nox-void-vencord'"
    echo "[*] Requisito: Discord > Apariencia > Tema base > Onyx"
}

install_firefox() {
    echo ""
    echo "[*] Instalando Firefox / LibreWolf..."

    local profile_dir="" browser=""

    for d in "$HOME/.librewolf/"*.default-*/; do
        if [ -d "$d" ]; then profile_dir="$d"; browser="librewolf"; break; fi
    done

    if [ -z "$profile_dir" ]; then
        for d in "$HOME/.mozilla/firefox/"*.default-*/ "$HOME/.mozilla/firefox/"*.default/; do
            if [ -d "$d" ]; then profile_dir="$d"; browser="firefox"; break; fi
        done
    fi

    if [ -z "$profile_dir" ]; then
        echo "[-] No se encontro perfil de Firefox ni LibreWolf"
        echo "[-] Copia firefox/chrome/ manualmente a tu perfil"
        return
    fi

    echo "[+] Perfil: ${browser} -> $(basename "$profile_dir")"

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

    mkdir -p "$profile_dir/chrome"
    cp -r "$TMPDIR/chrome/"* "$profile_dir/chrome/"
    echo "[+] Tema Firefox instalado en $profile_dir/chrome/"
    echo "[*] Reinicia ${browser} para aplicar"
}

install_kde() {
    echo ""
    echo "[*] Instalando KDE Plasma..."

    fetch "kde/NoxVoid/contents/colors/NoxVoid.colors" "$TMPDIR/NoxVoid.colors"
    mkdir -p "$HOME/.local/share/color-schemes"
    cp "$TMPDIR/NoxVoid.colors" "$HOME/.local/share/color-schemes/NoxVoid.colors"
    echo "[+] Color scheme instalado"

    if confirm "Instalar Look and Feel completo de KDE"; then
        mkdir -p "$TMPDIR/NoxVoid"
        for f in \
            metadata.json \
            contents/colors/NoxVoid.colors \
            contents/layouts/org.kde.plasma.desktop-layout.js; do
            mkdir -p "$TMPDIR/NoxVoid/$(dirname "$f")"
            fetch "kde/NoxVoid/$f" "$TMPDIR/NoxVoid/$f"
        done
        mkdir -p "$TMPDIR/NoxVoid/contents/defaults"
        mkdir -p "$HOME/.local/share/plasma/look-and-feel"
        cp -r "$TMPDIR/NoxVoid" "$HOME/.local/share/plasma/look-and-feel/NoxVoid"
        echo "[+] Look and Feel instalado"
        echo "[*] Aplicar: System Settings > Appearance > Look and Feel > NoxVoid"
    fi
}

install_kitty() {
    echo ""
    echo "[*] Instalando Kitty..."

    fetch "kitty/nox-void.conf" "$TMPDIR/nox-void.conf"
    mkdir -p "$HOME/.config/kitty/themes"
    cp "$TMPDIR/nox-void.conf" "$HOME/.config/kitty/themes/nox-void.conf"

    if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
        if ! grep -q "nox-void" "$HOME/.config/kitty/kitty.conf" 2>/dev/null; then
            if confirm "Agregar include de nox-void a kitty.conf"; then
                echo "" >> "$HOME/.config/kitty/kitty.conf"
                echo "# Nox Void theme" >> "$HOME/.config/kitty/kitty.conf"
                echo "include themes/nox-void.conf" >> "$HOME/.config/kitty/kitty.conf"
                echo "[+] Include agregado a kitty.conf"
            fi
        else
            echo "[+] Ya esta configurado en kitty.conf"
        fi
    else
        echo "[!] No existe kitty.conf. Tema copiado a ~/.config/kitty/themes/"
        echo "[*] Agrega manualmente: 'include themes/nox-void.conf' a kitty.conf"
    fi

    echo "[+] Tema Kitty instalado"
}

# ── menu ──────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         Nox Void - Theme Installer       ║"
echo "║   github.com/pebrd/nox-dots              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

echo "Elegi uno o mas temas (ej: 1 3 4 o 1,3,4):"
echo "  1. Discord (Vencord)"
echo "  2. Firefox / LibreWolf (Cascade)"
echo "  3. KDE Plasma"
echo "  4. Kitty (terminal)"
echo "  5. Todos"
echo "  0. Salir"
echo ""

read -rp "Opcion: " opt_raw

# normalizar: comas -> espacios, trim
opt=$(echo "$opt_raw" | tr ',' ' ' | xargs)

if [ -z "$opt" ]; then
    echo "[!] No seleccionaste nada"
    exit 1
fi

run_all=false

for token in $opt; do
    if [ "$token" = "0" ]; then
        echo "[*] Chau!"
        exit 0
    elif [ "$token" = "5" ]; then
        run_all=true
        break
    fi
done

if $run_all; then
    install_discord
    install_firefox
    install_kde
    install_kitty
else
    for token in $opt; do
        case "$token" in
            1) install_discord ;;
            2) install_firefox ;;
            3) install_kde ;;
            4) install_kitty ;;
            *) echo "[-] Opcion invalida: $token" ;;
        esac
    done
fi

echo ""
echo "[+] Hecho!"
