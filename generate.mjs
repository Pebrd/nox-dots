#!/usr/bin/env node
/**
 * generate.mjs — lee dist/css/void-tokens.css de nox
 * y regenera todos los temas en nox-dots.
 *
 * Uso: node generate.mjs <path-to-void-tokens.css>
 */

import { readFileSync, writeFileSync, mkdirSync } from 'fs'
import { dirname } from 'path'

const cssPath = process.argv[2]
if (!cssPath) {
  console.error('Usage: node generate.mjs <path-to-void-tokens.css>')
  process.exit(1)
}

// ── Parsear variables CSS ──────────────────────────────────────────────────
const css = readFileSync(cssPath, 'utf8')
const vars = {}
for (const match of css.matchAll(/--nox-([\w-]+):\s*([^;]+);/g)) {
  vars[match[1]] = match[2].trim()
}

const c = {
  bgBase:      vars['color-bg-base'],
  bgSurface:   vars['color-bg-surface'],
  bgSurface2:  vars['color-bg-surface2'],
  bgDivider:   vars['color-bg-divider'],
  bgBorder:    vars['color-bg-border'],
  textPrimary: vars['color-text-primary'],
  textSecond:  vars['color-text-secondary'],
  textDisabled:vars['color-text-disabled'],
  accent:      vars['color-accent-default'],
  danger:      vars['color-semantic-danger'],
}

// helpers
const hex2rgb = h => {
  const x = h.replace('#','')
  const r = parseInt(x.slice(0,2),16)
  const g = parseInt(x.slice(2,4),16)
  const b = parseInt(x.slice(4,6),16)
  return `${r},${g},${b}`
}
const accentRgb = hex2rgb(c.accent)

function write(path, content) {
  mkdirSync(dirname(path), { recursive: true })
  writeFileSync(path, content, 'utf8')
  console.log(`✓ ${path}`)
}

// ── KDE color scheme ───────────────────────────────────────────────────────
const borderRgb   = hex2rgb(c.bgBorder)
const surfaceRgb  = hex2rgb(c.bgSurface)
const surface2Rgb = hex2rgb(c.bgSurface2)
const baseRgb     = hex2rgb(c.bgBase)
const textRgb     = hex2rgb(c.textPrimary)
const mutedRgb    = hex2rgb(c.textDisabled)
const inactRgb    = hex2rgb(c.textSecond)

write('kde/NoxVoid/contents/colors/NoxVoid.colors', `\
[ColorEffects:Disabled]
Color=${borderRgb}
ColorAmount=0
ColorEffect=0
ContrastAmount=0.55
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=false
Color=${inactRgb}
ColorAmount=0.02
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=${borderRgb}
BackgroundNormal=${baseRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${accentRgb}
ForegroundInactive=${mutedRgb}
ForegroundLink=${accentRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${textRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[Colors:Complementary]
BackgroundAlternate=${surfaceRgb}
BackgroundNormal=${baseRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${accentRgb}
ForegroundInactive=${mutedRgb}
ForegroundLink=${accentRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${textRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[Colors:Header]
BackgroundAlternate=${surfaceRgb}
BackgroundNormal=${baseRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${accentRgb}
ForegroundInactive=${mutedRgb}
ForegroundLink=${accentRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${textRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[Colors:Selection]
BackgroundAlternate=${accentRgb}
BackgroundNormal=${accentRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${baseRgb}
ForegroundInactive=${surfaceRgb}
ForegroundLink=${baseRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${baseRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[Colors:Tooltip]
BackgroundAlternate=${surface2Rgb}
BackgroundNormal=${surfaceRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${accentRgb}
ForegroundInactive=${mutedRgb}
ForegroundLink=${accentRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${textRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[Colors:View]
BackgroundAlternate=${surfaceRgb}
BackgroundNormal=${baseRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${accentRgb}
ForegroundInactive=${mutedRgb}
ForegroundLink=${accentRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${textRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[Colors:Window]
BackgroundAlternate=${baseRgb}
BackgroundNormal=${baseRgb}
DecorationFocus=${accentRgb}
DecorationHover=${accentRgb}
ForegroundActive=${accentRgb}
ForegroundInactive=${mutedRgb}
ForegroundLink=${accentRgb}
ForegroundNegative=${hex2rgb(c.danger)}
ForegroundNeutral=${inactRgb}
ForegroundNormal=${textRgb}
ForegroundPositive=${inactRgb}
ForegroundVisited=${inactRgb}

[General]
ColorScheme=NoxVoid
Name=Nox Void
shadeSortColumn=true

[KDE]
contrast=4
`)

// ── Kitty ──────────────────────────────────────────────────────────────────
write('kitty/nox-void.conf', `\
# Nox Void — kitty theme
# Auto-generated from github.com/pebrd/nox — do not edit directly
# Accent: ${c.accent}

background            ${c.bgBase}
foreground            ${c.textPrimary}
selection_background  ${c.accent}
selection_foreground  ${c.bgBase}

cursor                ${c.accent}
cursor_text_color     ${c.bgBase}

url_color             ${c.accent}

active_border_color   ${c.accent}
inactive_border_color ${c.bgBorder}
bell_border_color     ${c.accent}

active_tab_background   ${c.bgBase}
active_tab_foreground   ${c.textPrimary}
inactive_tab_background ${c.bgBase}
inactive_tab_foreground ${c.textDisabled}
tab_bar_background      ${c.bgBase}

color0  ${c.bgBase}
color8  ${c.bgBorder}
color1  ${c.danger}
color9  ${c.danger}
color2  #6A9870
color10 #6A9870
color3  #A09460
color11 #A09460
color4  #5A6878
color12 #6E8090
color5  #7A7290
color13 #8A82A8
color6  #607880
color14 #708890
color7  ${c.accent}
color15 ${c.textPrimary}
`)

// ── Vencord ────────────────────────────────────────────────────────────────
write('discord/nox-void-vencord.css', `\
/**
 * @name Nox Void
 * @description VOID Design System theme for Discord. Pure black, brutalist.
 * @author pebrd
 *
 * Auto-generated from github.com/pebrd/nox — do not edit directly
 * REQUISITO: Discord → Apariencia → Default Themes → Onyx
 */

.theme-midnight {
    --background-base-lowest:  ${c.bgBase} !important;
    --background-base-lower:   ${c.bgBase} !important;
    --background-base-low:     ${c.bgSurface} !important;
    --background-base-medium:  ${c.bgSurface2} !important;
    --background-base-high:    ${c.bgBorder} !important;
    --background-base-higher:  ${c.bgBorder} !important;
    --background-base-highest: ${c.bgBorder} !important;

    --background-surface-low:     ${c.bgSurface} !important;
    --background-surface-high:    ${c.bgSurface2} !important;
    --background-surface-higher:  ${c.bgBorder} !important;
    --background-surface-highest: ${c.bgBorder} !important;

    --background-mod-muted:    rgba(255,255,255,0.04) !important;
    --background-mod-subtle:   rgba(255,255,255,0.06) !important;
    --background-mod-normal:   rgba(255,255,255,0.08) !important;
    --background-mod-strong:   rgba(255,255,255,0.12) !important;

    --message-background-hover: rgba(255,255,255,0.02) !important;

    --border-faint:     rgba(${accentRgb},0.06) !important;
    --border-subtle:    rgba(${accentRgb},0.10) !important;
    --border-muted:     rgba(${accentRgb},0.14) !important;
    --border-normal:    rgba(${accentRgb},0.20) !important;
    --border-strong:    rgba(${accentRgb},0.30) !important;
    --app-frame-border: rgba(${accentRgb},0.10) !important;

    --text-normal:        ${c.textPrimary} !important;
    --text-muted:         ${c.textDisabled} !important;
    --text-link:          ${c.accent} !important;
    --header-primary:     ${c.textPrimary} !important;
    --header-secondary:   ${c.textSecond} !important;
    --interactive-normal: ${c.textDisabled} !important;
    --interactive-hover:  ${c.textPrimary} !important;
    --interactive-active: ${c.textPrimary} !important;
    --interactive-muted:  ${c.textSecond} !important;

    --channels-default:              ${c.textDisabled} !important;
    --channel-icon:                  ${c.textSecond} !important;
    --channel-text-area-placeholder: ${c.textSecond} !important;

    --input-background:       ${c.bgSurface} !important;
    --input-border:           rgba(${accentRgb},0.14) !important;
    --input-placeholder-text: ${c.textSecond} !important;

    --brand-500:            ${c.accent} !important;
    --brand-experiment:     ${c.accent} !important;
    --brand-experiment-500: ${c.accent} !important;
    --brand-experiment-560: ${c.accent} !important;
    --focus-primary:        ${c.accent} !important;

    --mention-foreground: ${c.accent} !important;
    --mention-background: rgba(${accentRgb},0.07) !important;

    --scrollbar-auto-thumb:                 ${c.bgBorder} !important;
    --scrollbar-auto-track:                 ${c.bgBase} !important;
    --scrollbar-auto-scrollbar-color-thumb: ${c.bgBorder} !important;
    --scrollbar-thin-thumb:                 ${c.bgBorder} !important;

    --legacy-elevation-low:    none !important;
    --legacy-elevation-medium: none !important;
    --legacy-elevation-high:   none !important;
    --legacy-elevation-border: none !important;

    --status-danger:   ${c.danger} !important;
    --status-positive: #6A9870 !important;

    --radius-xs:    0px !important;
    --radius-sm:    0px !important;
    --radius-md:    0px !important;
    --radius-lg:    0px !important;
    --radius-xl:    0px !important;
    --radius-xxl:   0px !important;
    --radius-round: 0px !important;

    --opacity-4:  rgba(${accentRgb},0.04);
    --opacity-8:  rgba(${accentRgb},0.08);
    --opacity-12: rgba(${accentRgb},0.12);
    --opacity-16: rgba(${accentRgb},0.16);
    --opacity-20: rgba(${accentRgb},0.20);
    --opacity-24: rgba(${accentRgb},0.24);
}

.theme-midnight *:not([class*="avatar"]):not([class*="status"]):not([class*="dot"]):not([class*="badge"]):not(circle):not(ellipse) {
    border-radius: 0 !important;
}
.theme-midnight [class*="avatar"],
.theme-midnight [class*="Avatar"] {
    border-radius: 50% !important;
}
.theme-midnight code { border-radius: 0 !important; }
.theme-midnight button:not([class*="avatar"]) { border-radius: 0 !important; }
`)

console.log('\nDone.')
