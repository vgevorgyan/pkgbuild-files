# PKGBUILD Files

A collection of Arch Linux PKGBUILD files with automated build, clean, and repository management scripts.

## Disclaimer

Some parts of the scripts in this repository were generated with AI assistance. While efforts have been made to ensure functionality and security, please review and test any scripts before using them.

## Planned improvements

- Add non-interactive flag to `build.sh` (e.g., `-y/--yes`) for CI use
- Support parallel builds in `build.sh` with a safe default job limit
- Add a config file (e.g., `.pkgtools.conf`) for repo name and paths
- Include `.sig` handling and `repo-add -s` (optional signing)
- Add `repo-remove` helper to prune old package versions
- Improve error codes and messages across all scripts
- Document common troubleshooting steps and requirements (e.g., base-devel)

## Project Structure

```
pkgbuild-files/
├── build.sh              # Build packages script
├── clean.sh              # Clean build artifacts script
├── update-repo.sh        # Repository management script
├── LICENSE               # MIT License
├── README.md             # This file
└── sddm-eucalyptus-drop/ # Example package
    └── PKGBUILD          # Package build file
```

## Scripts

### build.sh

Build Arch packages in specified subfolders or all subfolders containing PKGBUILD files.

**Usage:**

```bash
# Build specific packages
./build.sh sddm-eucalyptus-drop other-package

# Build all packages (with confirmation prompt)
./build.sh
```

**Features:**

- Runs `makepkg -sD` in each package directory
- Skips directories without PKGBUILD files
- Prompts for confirmation when building all packages
- Supports absolute and relative paths

### clean.sh

Remove all files and directories inside package subfolders except the PKGBUILD file.

**Usage:**

```bash
# Clean specific packages
./clean.sh sddm-eucalyptus-drop other-package

# Clean all packages
./clean.sh
```

**Features:**

- Preserves PKGBUILD files
- Skips the `repo/` directory
- Removes build artifacts, source files, and package files
- Supports absolute and relative paths

### update-repo.sh

Copy built packages to repository directory and update the repository database.

**Usage:**

```bash
# Update repo with specific packages
./update-repo.sh sddm-eucalyptus-drop other-package

# Update repo with all packages
./update-repo.sh
```

**Features:**

- Copies `*.pkg.tar.zst` files to `repo/` directory
- Updates `repo/myrepo.db.tar.zst` database
- Creates `repo/` directory if it doesn't exist
- Skips packages without built files

## Repository Management

The `update-repo.sh` script manages a local Arch repository:

- **Repository location:** `repo/`
- **Database file:** `repo/myrepo.db.tar.zst`
- **Package files:** `repo/*.pkg.tar.zst`

To use the repository, add it to your `pacman.conf`:

```ini
[myrepo]
SigLevel = Optional TrustAll
Server = file:///path/to/your/pkgbuild-files/repo
```

## Example Workflow

1. **Build packages:**

   ```bash
   ./build.sh
   ```

2. **Update repository:**

   ```bash
   ./update-repo.sh
   ```

3. **Clean build artifacts:**
   ```bash
   ./clean.sh
   ```

## Adding New Packages

1. Create a new directory for your package
2. Add a `PKGBUILD` file
3. Use the scripts to build and manage the package

Example:

```bash
mkdir my-package
# Add PKGBUILD file
./build.sh my-package
./update-repo.sh my-package
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

