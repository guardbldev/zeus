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
````

---

### 3. Context-Aware Commands

Commands automatically adapt to:

* Selected instances
* Active script
* Edit vs Play mode

Example:

```powershell
refactor.rename --snake
```

---

### 4. Live Output Streams

* Real-time logs
* Progress indicators
* Exportable output logs
* Error severity levels

---

### 5. Bulk Refactor Engine

Safely refactor large projects.

Features:

* Regex renaming
* Preview & dry-run mode
* Full undo support

Commands:

```powershell
refactor.rename --regex="^Enemy_" --replace="NPC_"
refactor.preview
```

---

### 6. Service & Instance Generator

Generate standardized code & folders.

Commands:

```powershell
gen.script --type=Module --name=Inventory
gen.service PlayerDataService
```

Supports:

* Templates
* Company/team presets
* Versioned scaffolds

---

### 7. Script Dependency Graph

* Analyzes all `require()` relationships
* Detects circular dependencies
* Visual graph output
* JSON export

Commands:

```powershell
deps.graph
deps.export
```

---

### 8. Dead Code & Asset Detection

* Detect unused scripts, modules, assets
* Safe delete queue
* Restore support

Commands:

```powershell
cleanup.scan
cleanup.remove --unused
```

---

### 9. Project Structure Validator

Enforces folder & naming rules.

Commands:

```powershell
validate.structure
validate.rules
```

Configurable via project config file.

---

### 10. Static Code Analysis

Detects common Luau issues:

* Infinite loops
* Yield misuse
* Global state abuse

Commands:

```powershell
analyze.code
```

---

### 11. Security Audit Tools

Finds exploitable patterns:

* Unvalidated RemoteEvents
* Client-trusted server logic
* Unsafe HttpService usage

Commands:

```powershell
audit.remotes
audit.security
```

---

### 12. Performance Profiler

Profiles runtime behavior:

* Script execution time
* Memory usage
* Event connection leaks

Commands:

```powershell
profile.start
profile.report
```

---

### 13. Type & Interface Validator

* Validates Luau types
* Ensures return consistency
* Detects mismatched interfaces

Commands:

```powershell
type.check
```

---

### 14. Asset Sync & Version Pinning

* Lock assets to versions
* Detect version drift
* Rollback support

Commands:

```powershell
asset.pin 12345678
asset.check
```

---

### 15. Animation & Sound Inspector

* Detect oversized assets
* Identify unused animations/sounds
* Optimize memory usage

Commands:

```powershell
media.scan
```

---

### 16. Tag & Attribute Manager

Bulk manage CollectionService tags and Attributes.

Commands:

```powershell
tag.add Enemy
attr.set Health=100
attr.schema.validate
```

---

### 17. Team-Safe Script Locking

* Prevent conflicting edits
* Studio-only locking
* No account data stored

Commands:

```powershell
lock.acquire
lock.release
```

---

### 18. Environment Switching

Switch between environments instantly.

Commands:

```powershell
env.set dev
env.set prod
```

Controls:

* Feature flags
* API endpoints
* Debug settings

---

### 19. CI-Style Build Checks

Pre-publish validation suite.

Checks:

* No debug prints
* No disabled scripts
* No insecure remotes

Commands:

```powershell
build.check
```

---

### 20. Extensible Plugin API

Third-party command support.

Example:

```lua
registerCommand({
  name = "hello",
  description = "Prints Hello",
  run = function(ctx)
    print("Hello Studio")
  end
})
```

---

