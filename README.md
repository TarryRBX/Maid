# Maid

A minimal lifecycle manager that cleans up connections, instances, tasks, and
callbacks when they are no longer needed. Create a `Maid`, hand it things that
need cleanup, then call `clear()` (or `Destroy()`) to release everything at
once.

## Installation

Add Maid as a Git submodule in your project's `lib` directory:

```bash
git submodule add https://github.com/TarryRBX/Maid lib/Maid
```

When cloning a project that already includes Maid, fetch the submodule with:

```bash
git clone --recurse-submodules <project-url>
# or, for an existing clone:
git submodule update --init
```

### Wiring into `default.project.json`

Rojo maps folders in `lib` to instances in the data model. Add Maid under
`ReplicatedStorage`:

```json
{
  "name": ...,
  "tree": {
    "ReplicatedStorage": {
      "Maid": { "$path": "lib/Maid" },
      ...
    },
    ...
  }
}
```

Maid is then requireable as `ReplicatedStorage.Maid`.

## Usage

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Maid)
local maid = Maid.new()
```

Register one or more items to be cleaned up later. `add()` deduplicates — the
same item can be added multiple times but is only tracked (and cleaned up) once:

```lua
maid:add(RunService.Heartbeat:Connect(onHeartbeat))
maid:add(part, function() print("part destroyed") end)
maid:add(task.spawn(worker))
```

Clean everything up (also cancels pending threads):

```lua
maid:clear()
```

`clear()` releases every item added so far and empties the maid. To clean up a
single item early, remove it with `pop()` — it is cleaned up immediately and
dropped from the maid:

```lua
maid:pop(connection)
```

## API

- `Maid.new()` — returns an empty maid.
- `Maid.isMaid(value)` — returns `true` if `value` is a `Maid`.
- `maid:add(...)` — registers one or more items; returns them as-is. Already
  tracked items are ignored.
- `maid:pop(item)` — cleans up `item` immediately and removes it from the maid.
- `maid:has(item)` — returns `true` if `item` is tracked.
- `maid:clear()` — releases all tracked items and empties the maid.
- `maid:Destroy()` — alias for `clear()`.

## What gets cleaned up

| Item                          | Action                              |
| ----------------------------- | ----------------------------------- |
| `thread`                      | `task.cancel(item)`                 |
| `function`                    | called with `pcall`                 |
| `RBXScriptConnection`         | `item:Disconnect()`                 |
| `Instance`                    | `item:Destroy()` (Tweens cancelled) |
| `Maid`                        | `item:Destroy()`                    |
| table with a `Destroy` method | `item:Destroy()`                    |
