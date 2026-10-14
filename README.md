# dotfiles

## Nix

### Common procedures

Prerequisites: [Nix](https://nixos.org/download/) and [Homebrew](https://brew.sh/) (this also installs the Xcode Command Line Tools, which provide `git`). The owner of `/opt/homebrew` is set as `brewUser` below.

```sh
# 1. Place the sops age key (copy from the previous machine)
mkdir -p ~/.config/sops/age
cp /path/to/keys.txt ~/.config/sops/age/keys.txt

# 2. Move aside files nix-darwin refuses to overwrite (only if they exist)
for f in /etc/nix/nix.conf /etc/zshrc /etc/bashrc; do
  [ -e "$f" ] && sudo mv "$f" "$f.before-nix-darwin"
done
```

### Private

```sh
# 1. Run nix-darwin
sudo nix run nix-darwin \
  --extra-experimental-features 'flakes nix-command' \
  --extra-substituters https://cache.numtide.com \
  --extra-trusted-public-keys niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g= \
  -- switch --flake .#privateDarwin

# 4. Set the token
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
cat > users/work/flake.nix << EOF
{
  description = "Work username configuration";
  outputs = { self }: {
    value = "$(whoami)";
    brewUser = "$(stat -f %Su /opt/homebrew)";
  };
}
EOF

# 2. Place the CA bundle if you need
sudo mkdir -p /etc/ssl/certs
security find-certificate -a -p \
  /System/Library/Keychains/SystemRootCertificates.keychain \
  /Library/Keychains/System.keychain \
  | sudo tee /etc/ssl/certs/ca-certificates.crt > /dev/null

# 3. Run nix-darwin
sudo env NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
  nix run nix-darwin \
  --extra-experimental-features 'flakes nix-command' \
  --option ssl-cert-file /etc/ssl/certs/ca-certificates.crt \
  --extra-substituters https://cache.numtide.com \
  --extra-trusted-public-keys niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g= \
  -- switch --flake .#workDarwin

# 4. Set the token
gh auth login

cat <<EOF > ~/.config/nix/local.conf
access-tokens = github.com=$(gh auth token)
EOF

cat <<EOF > ~/.claude/.github.token
GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token)
EOF
```

> [!Note]
> If you encounter an error like `evaluation of cached failed attribute 'darwinConfigurations.workDarwin.system' unexpectedly succeeded`, run with `--option eval-cache false` option.
> This disables the evaluation cache temporarily. After the first successful run, you can use the normal command without `--option eval-cache false`.

From the second time onwards:
```sh
sudo darwin-rebuild switch --flake .#workDarwin

# Build
darwin-rebuild build --flake .#workDarwin
```
