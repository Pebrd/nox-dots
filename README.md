# nox-dots

Dotfiles y temas para aplicaciones, basados en la paleta del [VOID Design System](https://github.com/pebrd/nox).

```
negro puro como base — cero border-radius — acento #A8B0BC
```

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

### KDE Plasma (`kde/`)

Look and Feel completo con color scheme propio.

**Instalación:**

```bash
# Instalar el color scheme
cp kde/NoxVoid/contents/colors/NoxVoid.colors ~/.local/share/color-schemes/

# Instalar el Look and Feel
cp -r kde/NoxVoid ~/.local/share/plasma/look-and-feel/

# Aplicar
plasma-apply-lookandfeel --apply NoxVoid
plasma-apply-colorscheme NoxVoid
```

---

### Discord / Vencord (`discord/`)

Tema CSS para [Vencord](https://github.com/Vendicated/Vencord).

**Requisito:** Discord → Apariencia → Default Themes → **Onyx**

**Instalación:**

```
Vencord → Settings → Themes → Open Themes Folder → copiar nox-void-vencord.css → activar
```

---

### Kitty (`kitty/`)

Tema de colores para la terminal [kitty](https://sw.kovidgoyal.net/kitty/).

**Instalación:**

```bash
# Opción A — como tema nombrado
mkdir -p ~/.config/kitty/themes
cp kitty/nox-void.conf ~/.config/kitty/themes/
# Agregar a kitty.conf:
# include themes/nox-void.conf

# Opción B — directo al final de kitty.conf
cat kitty/nox-void.conf >> ~/.config/kitty/kitty.conf
```

---

## Fuente de tokens

Los colores vienen de [`pebrd/nox`](https://github.com/pebrd/nox) en formato W3C DTCG. Si el acento cambia ahí, actualizarlo acá manualmente en cada tema.
