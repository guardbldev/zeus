# Zeus - A Roblox Terminal Plugin

---
An extensible command-line framework for Roblox Studio that provides automation, static analysis, security auditing, performance profiling, and project validation through a powershell-like terminal user interface. From code generation and refactoring to security audits and build checks, this plugin brings development workflows into Roblox Studio.
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

###  Command Parser & Autocomplete (in dev)
- Tokenized command parsing
- Flag validation
- Path & instance autocomplete
- Intelligent suggestions based on context

### Command History & Profiles
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

### Context-Aware Commands

Commands automatically adapt to:

* Selected instances
* Active script
* Edit vs Play mode

Example:

```powershell
refactor.rename --snake
```

---

###. Live Output Streams

* Real-time logs
* Progress indicators
* Exportable output logs
* Error severity levels

---

### Bulk Refactor Engine

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

### Service & Instance Generator

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

### Script Dependency Graph

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

### Dead Code & Asset Detection

* Detect unused scripts, modules, assets
* Safe delete queue
* Restore support

Commands:

```powershell
cleanup.scan
cleanup.remove --unused
```

---

### Project Structure Validator

Enforces folder & naming rules.

Commands:

```powershell
validate.structure
validate.rules
```

Configurable via project config file.

---

### Static Code Analysis

Detects common Luau issues:

* Infinite loops
* Yield misuse
* Global state abuse

Commands:

```powershell
analyze.code
```

---

### Security Audit Tools

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

### Performance Profiler

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

### Type & Interface Validator

* Validates Luau types
* Ensures return consistency
* Detects mismatched interfaces

Commands:

```powershell
type.check
```

---

### Asset Sync & Version Pinning

* Lock assets to versions
* Detect version drift
* Rollback support

Commands:

```powershell
asset.pin 12345678
asset.check
```

---

### Animation & Sound Inspector

* Detect oversized assets
* Identify unused animations/sounds
* Optimize memory usage

Commands:

```powershell
media.scan
```

---

### Tag & Attribute Manager

Bulk manage CollectionService tags and Attributes.

Commands:

```powershell
tag.add Enemy
attr.set Health=100
attr.schema.validate
```

---

### Team-Safe Script Locking

* Prevent conflicting edits
* Studio-only locking
* No account data stored

Commands:

```powershell
lock.acquire
lock.release
```

---

### Environment Switching

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

### CI-Style Build Checks

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

### Extensible Plugin API

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

