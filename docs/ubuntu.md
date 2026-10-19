# Ubuntu workstation onboarding and dotfiles

The target is **Ubuntu 22.04 LTS (Jammy)**, as specified by the onboarding material supplied for this migration. The previous 24.04 minimum was an implementation assumption and has been removed. Newer releases need separate approval from the workstation owners and compatibility validation before changing this baseline.

This public document records the boundary between personal dotfiles and employer provisioning. The internal onboarding documents remain authoritative for company accounts, hardware, certificates, networking, drivers, SDKs and private projects. Their full contents, internal URLs, certificates and installation scripts are not copied into this repository. No internal provisioning script was fetched or executed during this update.

## Ordered preparation

Complete the steps from the internal guides in their specified order, one at a time. Where the guides disagree, resolve the detail with your onboarding contact before proceeding.

1. Prepare the Mac and required access/hardware. Install encrypted Ubuntu 22.04 with sufficient root-disk space. Choose the Linux account name required by your organization's Linux/LDAP setup; do not assume it matches a different login identity.
2. Install approved corporate CA certificates in the browsers. Separately confirm that the OS trust store and command-line tools trust the required services. A successful browser login does not establish curl/Git/Python TLS trust. Use the approved certificate and package-index configuration; never disable verification to get bootstrap working.
3. Configure VPN when needed. Apply network/DNS fixes only for a diagnosed problem using the current approved instructions; personal bootstrap never changes resolver configuration or disables IPv6.
4. Install the approved GPU driver and reboot before validating GPU workloads. Display/encryption-screen fixes belong to the driver/OS procedure; dotfiles do not change GRUB or kernel settings.
5. Establish enterprise Git access and work identity according to onboarding, then obtain the organization-managed installation scripts through the approved process. Existing keys, host trust and global Git identity must be preserved by this dotfiles repository.
6. Finish YubiKey, SSH-agent, account-access and authentication-CLI setup. Employer helpers may live in `~/bin`; Linux Zsh preserves this path and the inherited agent environment. Interactive PIN entry and key enrollment remain manual. Follow the approved per-login/per-key-insertion workflow when needed.
7. Run the organization dependency installer yourself, then complete container authentication and internal CLI setup in the guide's order. Private Python applications belong in separate environments using the approved package index. Personal formatter/LaTeX dependencies use `~/.local/share/dotfiles-python` and do not own the ML/PyTorch environment.
8. Complete the private project's build/bootstrap instructions, mount setup, backup service and approved AI tooling. No private project is cloned, inspected or built by these dotfiles scripts. Keep any project-specific SDK/PATH/library settings scoped to that project's documented environment.
9. Add the personal dotfiles overlay using the sequence below. Record discrepancies instead of repeatedly rerunning unrelated provisioning steps.

## Personal overlay

First inspect the proposed package list without sudo, network requests or installation. This preview works on macOS too:

```sh
cd ~/dotfiles
./scripts/bootstrap-ubuntu --plan
```

On the prepared Ubuntu 22.04 workstation, review `packages/ubuntu.txt`, then explicitly install:

```sh
./scripts/bootstrap-ubuntu
./scripts/bootstrap
# Answer workMachine=true for an employer workstation.
chezmoi diff
chezmoi apply                 # fresh/unmanaged home only; Nix hosts use docs/cutover.md
ya pkg install
./scripts/install-herdr-plugins   # only if those integrations are wanted
./scripts/setup-git-front
./scripts/doctor
uv run tests/validate.py
```

The apt list is a native dependency baseline, not a replacement for employer provisioning. It uses Jammy main/universe packages, prints the list before sudo, checks package availability after updating indexes, and does not upgrade already-installed explicitly requested packages (`--no-upgrade`). Dependency installation can still change dependencies. No apt source, third-party toolchain repository, certificate, driver, Docker installation or OS release is configured automatically.

Bootstrap reuses existing `chezmoi`, `mise` and `uv` commands and their approved configuration when available. Missing personal bootstrappers are obtained from their public upstream installers; if your workstation requires an approved mirror or corporate CA configuration, arrange that before invoking bootstrap. Do not substitute public indexes for internal Python applications.

On Linux the new interactive shell adds `~/.local/bin`, `~/bin`, then mise shims before the inherited PATH. Inspect `command -v auth-cli`, `command -v ykadd`, `command -v cmake`, `command -v clangd`, and `command -v python3` after applying. Reconcile unexpected duplicates with the package owners. The repo does not replace an employer SSH agent, generate/enroll keys, or set a global `LD_LIBRARY_PATH`.

## Compatibility checks

- **GPFS:** lightweight prompt/ls behavior supports resolved home mount paths, `/ci-gpfs`, `/qs-gpfs` and `/gpfs`, including symlinks. Mounting and unmounting remain the employer tools' responsibility; dotfiles never modify fstab or run mount scripts.
- **Python 3.10:** operational Python scripts support the Jammy interpreter. The validation script declares an isolated `tomli` test dependency for Python before 3.11; `uv run tests/validate.py` installs it into uv's environment rather than system Python. No ML packages are installed globally.
- **Tk/Matplotlib:** if an application uses distro Python and needs Tk, Jammy's matching package is `python3-tk`. Other interpreters/venvs need a matching supported Tk build. Configure Matplotlib's GUI backend in the relevant application/environment; a global backend setting can break headless jobs. This optional dependency is outside the core dotfiles package list.
- **Native tools:** Jammy's default CMake and LLVM are older than this Mac's versions. Preserve the approved project toolchain installed during onboarding and confirm the private project's requirements through its own instructions. The default apt Node runtime is also old and is intentionally omitted here; use the employer/project runtime for tools that require Node.
- **Linux binaries:** mise version pins alone do not prove compatibility with Jammy's libraries. Verify every CLI on the actual machine before removing its old provider. Container checks, if available, do not prove GPU, desktop, hardware-key, VPN or network-filesystem acceptance.
- **Desktop:** install Ghostty/FiraCode Nerd Font according to the workstation's desktop procedure. The apt Fira Code fallback lacks Nerd glyphs. X11/Wayland clipboard tools are included; confirm the active desktop backend. Check `lazygit --print-config-dir` before applying the Linux config to an existing installation.

## Corrections to keep out of automation

The supplied guide contains a `chmod 666` Docker-socket workaround. Do not put this in bootstrap. Use the organization's supported Docker access model; Docker documents group-based and rootless alternatives, and notes that Docker-group membership grants root-level privileges. See [Docker post-installation guidance](https://docs.docker.com/engine/install/linux-postinstall/).

Do not clear `~/.ssh/known_hosts` as part of YubiKey setup. Preserve known host keys and handle a specific changed host entry only after verifying its new fingerprint through a trusted source. Replacing a host-trust database does not enroll a hardware key.

Do not automatically apply the guide's broad IPv6/DNS/GRUB changes, globally install internal Python packages, replace existing SSH keys or export project-specific library paths into every shell. These are manual, situation-specific onboarding tasks.

Public package references: [Jammy package index](https://packages.ubuntu.com/jammy/), [clangd default](https://packages.ubuntu.com/jammy/clangd), [CMake](https://packages.ubuntu.com/jammy/cmake), [Python Tk bindings](https://packages.ubuntu.com/jammy/python3-tk). Internal procedure details were reviewed from the supplied text, not independently revalidated against live internal sites.
