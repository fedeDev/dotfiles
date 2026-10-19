# Neovim Performance Troubleshooting

This runbook exists because a 14-second startup regression was initially
diagnosed by inference instead of by using Neovim's built-in profiler. The
delay was simple to localize once `--startuptime` was used:

```text
030.508  000.058  000.058: require('plenary.compat')
14040.345  14009.951  14009.894: require('plenary.scandir')
```

The stalled operation was `require('plenary.scandir')`, not the statusline,
search highlighting, Tree-sitter, or general file parsing.

## First response to a startup regression

Reproduce the user's exact launch, including their working directory and file:

```sh
cd ~/pwin
nvim --startuptime startup.log pwin.c
```

Do this before changing the configuration. In `startup.log`, look for a large
jump in the first column or an unusually large elapsed/self time. Read several
lines before and after it; the expensive line often names the exact script or
Lua module.

The columns are cumulative clock time, elapsed time including children, and
self time. A large self time points directly at the operation itself. A large
elapsed time with small self time points at something it called.

Always distinguish these complaints:

- Process startup: launching `nvim`.
- Initial file load: startup plus the first buffer and its events.
- Later file opening: `:edit`, a picker, or a file manager inside an existing
  process.
- Input latency: typing, moving, completion, highlighting, or redraws.

They exercise different code paths. A fast empty headless startup does not
disprove a slow real file launch.

## Profiling an operation after startup

For a delay that happens inside an existing Neovim process:

```vim
:profile start /tmp/nvim-profile.log
:profile func *
:profile file *
" Reproduce the slow action once.
:profile stop
```

Then inspect the `FUNCTIONS SORTED ON TOTAL TIME`, `FUNCTIONS SORTED ON SELF
TIME`, and sourced-script sections. For plugin-load timing, `:Lazy profile` is
also useful, but Neovim's profiler remains the source of truth for work a
plugin performs after it loads.

## Isolation rules

Only begin disabling components after the trace identifies a subsystem.

1. Capture a baseline using the real file and working directory.
2. Change one variable.
3. Start a fresh Neovim process.
4. Capture another trace, not merely a wall-clock impression.
5. Restore required behavior and verify it explicitly.

Beware of warm-cache comparisons. Opening the same buffer twice in one process
can cache file contents, parsers, modules, filesystem metadata, and macOS
Directory Services results. The second result is not a valid control for the
first.

Synthetic giant files are useful for stress testing after localization, but
they must not be treated as proof of what slowed a normal project file.

## Verify the active configuration

Home Manager may leave the edited source and active Nix generation different.
Check what Neovim is actually using:

```vim
:lua print(vim.fn.stdpath("config"))
:scriptnames
:Lazy
```

From the shell, compare the active file with the repository version:

```sh
readlink ~/.config/nvim
cmp ~/.config/nvim/init.lua ./home/.config/nvim/init.lua
```

After a fix, test both performance and functionality. In this incident that
meant verifying that `pwin.c` opened quickly, CMake Tools loaded, and the CMake
target virtual text still appeared.

## Incident-specific root cause

`cmake-tools.nvim` requires `plenary.scandir`. At module load, the installed
Plenary version uses FFI to probe hard-coded UID and GID 1000. On this macOS
machine, resolving a nonexistent account through Directory Services blocked
for roughly 10–14 seconds. The delay could disappear temporarily after the
negative lookup was cached, making repeated tests misleading.

The local workaround loads `plenary.scandir` without its optional FFI
user/group-name branch. CMake Tools uses `scan_dir()` and does not need the
owner/group formatting used by Plenary's `ls` helper.

Upstream report: <https://github.com/nvim-lua/plenary.nvim/issues/671>

## What went wrong in the diagnosis

- Recent-change anchoring: the investigation focused on the statusline and
  highlight changes because they were recent.
- Measurement without attribution: wall-clock benchmarks showed that something
  was slow but did not identify the call responsible.
- Confounded comparison: the same giant file was reopened in one process, so
  the fast second open was incorrectly associated with a disabled component.
- Unrepresentative input: a 187,599-line header outside the real CMake project
  introduced behavior that did not establish the cause of the user's report.
- Premature mutation: CMake Tools was made command-only before its automatic
  target display was recognized as required behavior.
- Overstated certainty: a useful optimization was reported as the proven root
  cause without evidence from the user's actual trace.

## Decision rule

For a Neovim performance report, do not propose or implement a performance fix
until a profiler or trace attributes the delay to a specific operation, unless
the change is explicitly labeled as a reversible experiment. Report what the
measurement proves, what it merely suggests, and any behavior the experiment
temporarily removes.
