# nox-dots

Dotfiles y temas para aplicaciones, basados en los tokens del [NOX Design System](https://github.com/pebrd/nox).

```
negro puro como base — cero border-radius — acento #A8B0BC
```

---

## Instalacion rapida

```bash
curl -fsSL https://raw.githubusercontent.com/pebrd/nox-dots/main/install.sh | bash
```

Te abre un menu para elegir que tema instalar: Discord, Firefox/LibreWolf, KDE, Kitty, o todos.

---

## Paleta

| Token | Valor | Uso |
|---|---|---|
| `color.bg.base` | `#000000` | Fondo principal |
| `color.bg.surface` | `#0A0A0A` | Superficies |
| `color.bg.elevated` | `#161616` | Elementos elevados |
| `color.bg.overlay` | `#1A1A1A` | Overlays, hover |
| `color.accent` | `#A8B0BC` | Acento configurable |
| `color.text.primary` | `#C8CDD4` | Texto principal |
| `color.text.muted` | `#60656C` | Texto secundario |

---

## Temas

### Discord / Vencord (`discord/`)

Tema CSS para [Vencord](https://github.com/Vendicated/Vencord).

**Requisito:** Discord → Apariencia → Default Themes → **Onyx**

**Instalacion manual:**
```
Vencord → Settings → Themes → Open Themes Folder → copiar nox-void-vencord.css → activar
```

---

### Firefox / LibreWolf (`firefox/`)

Tema [Cascade](https://github.com/andreasgrafen/cascade) con colores NOX.

**Instalacion manual:**
```bash
# Copiar la carpeta chrome/ al perfil de Firefox/LibreWolf
cp -r firefox/chrome ~/.librewolf/<tu-perfil>/
cp -r firefox/chrome ~/.mozilla/firefox/<tu-perfil>/
# Reiniciar el navegador
```

---

### KDE Plasma (`kde/`)

Look and Feel completo con color scheme propio.

**Instalacion manual:**
```bash
# Color scheme
cp kde/NoxVoid/contents/colors/NoxVoid.colors ~/.local/share/color-schemes/

# Look and Feel completo
cp -r kde/NoxVoid ~/.local/share/plasma/look-and-feel/

# Aplicar
plasma-apply-lookandfeel --apply NoxVoid
plasma-apply-colorscheme NoxVoid
```

---

### Kitty (`kitty/`)

Tema de colores para la terminal [kitty](https://sw.kovidgoyal.net/kitty/).

**Instalacion manual:**
```bash
mkdir -p ~/.config/kitty/themes
cp kitty/nox-void.conf ~/.config/kitty/themes/
# Agregar a kitty.conf:
echo "include themes/nox-void.conf" >> ~/.config/kitty/kitty.conf
```

---

## Fuente de tokens

Los colores y temas se generan automaticamente desde los tokens de [`pebrd/nox`](https://github.com/pebrd/nox). Cuando los tokens se actualizan, los temas se regeneran solos via GitHub Actions.
