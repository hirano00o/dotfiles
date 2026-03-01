# dotfiles

## Nix

### Private

```sh
sudo nix run nix-darwin --extra-experimental-features 'flakes nix-command' -- switch --flake .#privateDarwin

gh auth login

cat <<EOF > ~/.config/nix/local.conf
access-tokens = github.com=$(gh auth token)
EOF

cat <<EOF > ~/.claude/.github.token
GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token)
EOF
```

From the second time onwards:
```sh
sudo darwin-rebuild switch --flake .#privateDarwin

# Build
darwin-rebuild build --flake .#privateDarwin
```

### Work

```sh
# 1. Create username configuration
cat > nix/users/work/flake.nix << EOF
{
  description = "Username configuration";
  outputs = { self }: {
    value = "$(whoami)";
  };
}
EOF

# 2. Tell git to ignore local changes
git update-index --skip-worktree nix/users/work/flake.nix

# 3. Run nix-darwin
sudo nix run nix-darwin --extra-experimental-features 'flakes nix-command' -- switch --flake .#workDarwin

# 4. Set the token
gh auth login

cat <<EOF > ~/.config/nix/local.conf
access-tokens = github.com=$(gh auth token)
EOF

cat <<EOF > ~/.claude/.github.token
GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token)
EOF
```

**Note**: If you encounter an error like `evaluation of cached failed attribute 'darwinConfigurations.workDarwin.system' unexpectedly succeeded`, run the following command instead:

```sh
sudo nix run nix-darwin --extra-experimental-features 'flakes nix-command' -- switch --flake .#workDarwin --option eval-cache false
```

This disables the evaluation cache temporarily. After the first successful run, you can use the normal command without `--option eval-cache false`.

From the second time onwards:
```sh
sudo darwin-rebuild switch --flake .#workDarwin

# Build
darwin-rebuild build --flake .#workDarwin
```
