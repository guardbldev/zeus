# Roblox Studio Terminal Plugin

A powerful VS Code / PowerShell–inspired terminal for Roblox Studio that enables
command-driven workflows, automation, analysis, and tooling for professional Roblox development.

---

## 🚀 Overview

This plugin introduces a fully interactive command-line interface into Roblox Studio.
Developers can run commands to generate code, refactor projects, audit security,
analyze performance, manage assets, and enforce team standards — all without leaving Studio.

The goal is to replace repetitive UI workflows with fast, reproducible, scriptable commands.

---

## ✨ Core Features

### Command System
- PowerShell-style command syntax
- Flags, arguments, quoted strings
- Command history & replay
- Context-aware execution (Selection, active script, environment)
- Tab autocomplete & fuzzy matching

---

### Plugin UI Features
- VS Code–style embedded terminal
- Streaming output & progress bars
- Color-coded logs (info / warning / error)
- Clickable stack traces → jump to scripts
- Persistent command history per project

---

## Features

### 1. Command Parser & Autocomplete
- Tokenized command parsing
- Flag validation
- Path & instance autocomplete
- Intelligent suggestions based on context

---

### 2. Command History & Profiles
- Persistent command history
- Saved command profiles
- Searchable history (`Ctrl+R` style)
- Replayable command batches

Commands:
```powershell
history.show
profile.save release
profile.run release
