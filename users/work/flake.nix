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

        cat > nix/users/work/flake.nix << 'EOF'
        {
          description = "Work username configuration";
          outputs = { self }: {
            value = "your_username_here";
          };
        }
        EOF

        Replace "your_username_here" with your actual username.
      '';
    };
}
