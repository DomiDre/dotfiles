# Dotfiles

Config files public backup. Files are managed using dotter.


## Usage

If not already done, install dotter via AUR or build using cargo:
```bash
cargo install --locked dotter
```

Add a local.toml in .dotter folder specifying which configs should be deployed, e.g.
```toml
packages = ["fish", "i3"]
```

and call
```bash
dotter deploy
```
