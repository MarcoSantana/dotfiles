# ♊ Gemini CLI - Dashboard de Configuración

> **Contexto del Sistema:** Pop!_OS (COSMIC Desktop)
> **Gestor de Dotfiles:** GNU Stow
> **Flujo de Trabajo:** Basado en terminal (Neovim, Tmux, Ghostty/Kitty)

---

## 🛠️ Comandos de Mantenimiento (Dotfiles)

Cuando necesites ayuda para modificar tus configs, usa estos prompts rápidos:

- **Revisar conflictos:** "Gemini, analiza por qué `stow nvim` me da error de conflicto en Pop!_OS."
- **Nuevos Symlinks:** "Genera la estructura de carpetas para agregar [NOMBRE_APP] a mi carpeta de dotfiles existente."

---

## 📋 Inventario de Herramientas

| Herramienta | Ruta de Configuración | Notas de Personalización |
| :--- | :--- | :--- |
| **Neovim** | `~/.config/nvim` | Lua based, enfocado en productividad. |
| **Tmux** | `~/.tmux.conf` | Prefijo: `Ctrl+b`, soporte para mouse. |
| **Ghostty** | `~/.config/ghostty` | Terminal nativa COSMIC/Rust. |
| **Emacs** | `~/.doom.d` | Perfil de Doom Emacs. |

---

## 🏷️ Estándar de Versionado

A partir de ahora, cada archivo de configuración debe incluir un comentario con su versión en el formato:
`yyyy-[week_number]-number`

- **Ejemplo:** `# Version: 2026-11-01`
- **Ubicación:** Al inicio del archivo (o donde sea pertinente según el formato).
- **Frecuencia:** Se incrementa el `number` con cada cambio realizado durante la misma semana.

---

## 📜 Prompts de Ingeniería (System Prompts)

Copia y pega esto al iniciar una sesión de Gemini CLI para que sepa quién eres y qué buscas:

> "Actúa como un experto en administración de sistemas Linux y entusiasta de la filosofía Orthodox. Mi entorno es Pop!_OS con COSMIC. Ayúdame a optimizar mis archivos de configuración (.dotfiles) priorizando la simplicidad, el rendimiento y el uso de GNU Stow. No sugieras recursos de iglesias protestantes; mantén el enfoque técnico o alineado con mi fe ortodoxa si el contexto lo requiere."

---

## 📓 Notas de Configuración & Pendientes

* [ ] Configurar el protocolo Gemini (gemtext) en Neovim para lectura de textos patrísticos.
* [ ] Sincronizar los temas de color entre Kitty y Ghostty.
* [ ] Crear un script post-stow para recargar las configs automáticamente.

---

## 🔗 Referencias Rápidas
- Documentación GNU Stow: `man stow`
- Repo de mis Dotfiles: `~/dotfiles`
