{
  description = "Work username configuration";
  outputs =
    { self }:
    {
      value = builtins.throw ''
        ============================================
        ERROR: Username not configured for workDarwin
        ============================================

        Please create your username configuration:

        cat > users/work/flake.nix << 'EOF'
        {
          description = "Work username configuration";
          outputs = { self }: {
            value = "your_username_here";
            brewUser = "your_brew_username_here";
          };
        }
        EOF

        Replace "your_username_here" with your actual username,
        and "your_brew_username_here" with the owner of /opt/homebrew.
      '';
      brewUser = builtins.throw ''
        ============================================
        ERROR: Brew username not configured for workDarwin
        ============================================

        Please set brewUser in users/work/flake.nix to the owner of /opt/homebrew.
      '';
    };
}
