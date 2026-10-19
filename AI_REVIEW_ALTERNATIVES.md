# Reliable AI Change Review in Herdr and Neovim

## Executive recommendation

Replace turn detection with an explicit Git changeset. The strongest fit is
`tuicr`, opened on demand from Herdr:

- review uncommitted work with `tuicr -w`;
- review the whole feature branch with `tuicr -r origin/master..HEAD`;
- leave line, range, file, and review-level comments;
- close and resume later without losing the review;
- press `y` to copy an agent-ready Markdown review, then paste it into Claude,
  OpenCode, Codex, or any future agent.

This gives up Reviewr's one-key direct delivery in exchange for the property
that matters more: the review boundary and draft comments do not depend on a
pane having been alive when an agent changed state.

The best alternative when direct delivery back to the correct Herdr agent is
more important than persistence is `jhochenbaum/herdr-hunk-diff`. It reviews
explicit Git targets rather than guessed turns, opens Hunk inside Herdr, and
sends inline comments back to the associated agent. Its comments still require
a live Hunk session until they are sent.

## Why Reviewr's turn model is fragile

Reviewr's last-turn scope observes Herdr agent state and writes a private Git
baseline when it sees a new turn begin. The Reviewr process must therefore be
running at the right time. A missed, delayed, or incorrectly classified agent
state creates the wrong boundary. The pane also owns unsent comments in memory,
so closing it loses those comments.[1]

This is a fundamental coupling rather than a theme or keybinding problem:

```text
terminal output -> Herdr state detection -> Reviewr observes transition
                -> private baseline -> inferred last-turn diff
```

Claude, OpenCode, and other TUIs do not expose identical lifecycle signals.
Terminal-screen detection can also change as their interfaces evolve. A Git
reference such as `HEAD`, `origin/master`, the index, or a selected commit is a
much more stable review boundary.

## Candidate comparison

| Candidate | Boundary | Draft persistence | Inline comments | Agent handoff | Best role |
|---|---|---:|---:|---|---|
| `tuicr` | Working tree, range, PR, selected commits | Yes | Yes | Clipboard/stdout | Recommended human review surface |
| `herdr-hunk-diff` | Working tree, staged, branch, commit, stash | Only while Hunk session is live | Yes | Direct to associated Herdr agent | Best integrated round trip |
| `review.nvim` + CodeDiff | Working tree or chosen revisions | Yes, per branch | Yes | Clipboard or Sidekick | Best Neovim-native commenting experiment |
| Existing Diffview + Gitsigns | Any Git revisions/index | Git itself | No review drafts | Manual references/prompt | Best editing, staging, history, conflicts |
| Reviewr without turns | Working tree or branch | Comments remain in live pane only | Yes | Direct to agent | Smallest immediate change |
| Pre-tool approval hook | Each individual edit/write request | Not a review session | Accept/deny message | Native hook response | Strict approval gate, not broad review |

## 1. tuicr: recommended

`tuicr` is a standalone, single-binary code-review TUI with Vim-style
navigation. It supports uncommitted changes, arbitrary commit ranges, and
hosted reviews. It records file/hunk review state and comments in persisted
sessions, and those sessions can be listed and resumed after the TUI exits.[2]

The interaction model matches the useful part of Reviewr:

- `j`/`k`, `Ctrl-d`/`Ctrl-u`, `g`/`G` for navigation;
- `[`/`]` for hunks and `{`/`}` for files;
- `v`/`V` for a range and `c`/`C` for line/file comments;
- `r`/`R` to mark a file or hunk reviewed;
- `y` to export structured, file-and-line-anchored Markdown;
- `e` to open the focused source in Neovim;
- saved sessions and a session picker for later resumption.[2]

### Proposed daily flow

For changes not yet committed:

```sh
tuicr -w
```

For everything on the GitHub-flow feature branch:

```sh
tuicr -r origin/master..HEAD
```

After commenting, press `y`, use the Herdr agent picker, and paste the review.
This extra paste is intentional decoupling: the review remains usable with
Claude, OpenCode, Codex, or an ordinary PR without an agent-specific plugin.

### Strengths

- No turn detector and no requirement to run before edits happen.
- Draft review sessions survive closing the TUI.
- The most complete Vim vocabulary among the reviewed TUI options.
- Local diffs and remote PR reviews use the same interface.
- Can submit inline reviews to multiple forges, including GitHub; clipboard
  export works without submitting anything.[2]
- Catppuccin Mocha is built in, and the editor can be set to `nvim`.[2]

### Limitations

- No native one-key Herdr delivery to the agent.
- It reviews a Git changeset, not an automatically inferred conversational
  turn. An exact conversational boundary needs a commit, stash, or explicit
  revision created at that boundary.
- It is a separate TUI rather than a Neovim buffer.

## 2. herdr-hunk-diff: best direct Herdr integration

`herdr-hunk-diff` opens Hunk against explicit review targets and associates the
review with the Herdr agent/worktree from which it was launched. Its actions
cover uncommitted work, staged work, the branch relative to its base, the last
commit, and the latest stash. Human-authored inline comments can be sent back
to the associated agent as one prompt.[3]

Useful configuration for this environment would be:

```toml
[review]
auto_open = false
reuse_pane = true
default_target = "branch"
base = "origin/master"
watch = true
placement = "tab"
exclude_untracked = false

[roundtrip]
clear_after_send = false
```

This completely avoids turn-based baselines. `watch = true` keeps an open
review synchronized with the Git target, while manual opening means the plugin
does not need to remain alive before the agent starts working.[3]

### Strengths

- Direct Herdr association and comment delivery.
- Explicit, inspectable Git targets.
- Separate actions for staged, branch, commit, and stash review.
- Can reuse and live-refresh a review pane.
- Hunk supports split/stack layouts, syntax-aware presentation, mouse input,
  pager use, and inline agent annotations.[4]

### Limitations

- Draft comments belong to a live Hunk session; closing it prevents reliable
  later delivery.[3]
- The plugin requires Herdr 0.8+, Node 22.12+, and installs a pinned Hunk
  dependency.[3]
- The upstream repository currently has an open report about ambiguity in the
  automatically chosen changeset. Pinning `base = "origin/master"` and using
  explicit target actions reduces that risk.[5]
- Hunk's motion model is not as thoroughly Vim-like as tuicr's.

## 3. review.nvim plus CodeDiff: strongest Neovim-native commenting option

`review.nvim` layers annotations over CodeDiff. It supports typed line/range
comments, a comment list, editable drafts, structured Markdown export, and
per-branch persistence under Neovim's data directory. Closing the review can
copy the comments automatically, and sessions expire after seven days.[6]

This directly fixes the persistence problem and keeps the work in Neovim. It
is not the first recommendation here because the current configuration already
standardized on Diffview after concerns about CodeDiff's maturity. Installing
it would introduce a second diff engine and duplicate concepts already mapped
to Diffview.

Use this only if keeping the comment UI inside Neovim outweighs that duplication.

## 4. Diffview and Gitsigns: keep as the Git manipulation layer

The existing Diffview/Gitsigns combination remains the best tool in this setup
for inspecting arbitrary revisions, file history, rename-following history,
conflicts, and staging or unstaging hunks. Diffview can open
`origin/master...HEAD`, compare the index with the working tree, and trace a
selected range through history.[7]

It is not a complete Reviewr replacement because it lacks persistent inline
review comments and agent-ready export. It composes well with tuicr:

- Diffview/Gitsigns: edit, stage, unstage, revert, inspect history.
- tuicr: read the complete change and record feedback.
- Herdr: choose the agent and deliver the exported feedback.

## 5. Keep Reviewr, but stop using last-turn

The lowest-risk immediate change is:

```toml
default_scope = "branch"
toggle_placement = "tab"
auto_open = false
```

Reviewr can then be opened only when needed. It will compare the working tree
and branch against Git rather than depend on a captured turn. This preserves
its good direct-comment workflow, PR tab, and familiar controls. It does not
fix in-memory comment loss, nor Reviewr's other UI limitations.

## 6. Per-edit approval hooks: a different workflow

`herdr-diff-review.nvim` intercepts an agent's `Edit` or `Write` tool before the
change is applied, opens a fresh Neovim diff, and blocks until the edit is
accepted or denied. The edited proposed buffer can itself be modified before
acceptance.[8]

This provides the strongest accept/reject semantics but is not recommended as
the default workflow:

- every edit becomes an interruption;
- support is limited to agents with compatible pre-tool hooks (documented for
  Claude Code and Kiro, not OpenCode);
- sub-agent edits may be automatically approved;
- the project is very young;
- it reviews one tool call rather than a coherent feature changeset.[8]

It may be useful later as an opt-in guard for sensitive files.

## Explicit checkpoints when a real “turn” boundary matters

No viewer can reconstruct an exact past dirty-worktree boundary after later
edits overwrite it unless something recorded that state. Reliable choices are:

1. Ask the agent to make a small checkpoint commit after a coherent unit of
   work, then review that commit. Squash or fix up before the PR.
2. Stage the intended boundary and review the index separately from subsequent
   working-tree edits.
3. Create an explicit stash/patch checkpoint and review that object later.

Small checkpoint commits fit GitHub flow well: they remain local or on the
short-lived feature branch, give every review an immutable identifier, and can
be interactively rebased before merging. They are more trustworthy than a
terminal-state transition called a “turn.”

## Recommended rollout

1. Immediately stop relying on Reviewr's `last-turn` scope.
2. Trial `tuicr` without removing Reviewr, Diffview, or Gitsigns.
3. Bind one Herdr action to open the tuicr target selector in a temporary
   review pane; use `tuicr -w` and `tuicr -r origin/master..HEAD` directly while
   evaluating it.
4. If clipboard handoff feels too manual, trial `herdr-hunk-diff` with an
   explicit `origin/master` base and manual opening.
5. Keep Diffview/Gitsigns as the mutation and history layer whichever review
   UI wins.

## Sources

1. persiyanov. “[herdr-reviewr README](https://github.com/persiyanov/herdr-reviewr/blob/main/README.md).” GitHub.
2. agavra. “[tuicr README](https://github.com/agavra/tuicr).” GitHub.
3. jhochenbaum. “[herdr-hunk-diff README](https://github.com/jhochenbaum/herdr-hunk-diff/blob/main/README.md).” GitHub.
4. modem-dev. “[Hunk README](https://github.com/modem-dev/hunk).” GitHub.
5. jhochenbaum/herdr-hunk-diff. “[Wrong changes shown, issue #8](https://github.com/jhochenbaum/herdr-hunk-diff/issues/8).” GitHub, August 2026.
6. georgeguimaraes. “[review.nvim README](https://github.com/georgeguimaraes/review.nvim).” GitHub.
7. sindrets. “[Diffview.nvim README](https://github.com/sindrets/diffview.nvim).” GitHub.
8. rytkmt. “[herdr-diff-review.nvim README](https://github.com/rytkmt/herdr-diff-review.nvim).” GitHub.
