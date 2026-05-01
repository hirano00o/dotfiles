let
  fileTools = [ "Read" "Edit" "Write" ];
  writeTools = [ "Edit" "Write" ];

  bashDeny = map (r: r // { tool = "Bash"; decision = "deny"; }) [
    { pattern = "\\bsed\\s+-i"; reason = "Use the Edit tool instead of sed -i"; }
    { pattern = "\\bsed\\s+--in-place"; reason = "Use the Edit tool instead of sed --in-place"; }
    { pattern = "\\bawk\\s+-i\\s+inplace"; reason = "Use the Edit tool instead of awk inplace"; }
    { pattern = "\\bperl\\s+-[ip]"; reason = "Use the Edit tool instead of perl -i/-p"; }

    { pattern = "(^|[|;&])\\s*/"; reason = "Absolute path command execution is not allowed"; }
    { pattern = "\\bsudo\\b"; reason = "sudo is not allowed"; }
    { pattern = "\\bsu\\b\\s"; reason = "su is not allowed"; }
    { pattern = "\\bchmod\\s+777\\b"; reason = "chmod 777 is not allowed"; }
    { pattern = "\\bchown\\b"; reason = "chown is not allowed without review"; }

    { pattern = "\\brm\\s+-[rR]f\\s+/"; reason = "Recursive deletion from root is not allowed"; }
    { pattern = "\\brm\\s+-[rR]f\\s+~"; reason = "Recursive deletion from home is not allowed"; }
    { pattern = "\\brm\\s+-[rR]f\\s+\\.\\."; reason = "Recursive deletion of parent directory is not allowed"; }
    { pattern = "\\bmkfs\\b"; reason = "Filesystem formatting is not allowed"; }
    { pattern = "\\bdd\\b\\s"; reason = "dd is not allowed"; }

    { pattern = "\\bcurl\\b.*\\|\\s*(sh|bash|zsh)"; reason = "Piping curl to shell is not allowed"; }
    { pattern = "\\bwget\\b.*\\|\\s*(sh|bash|zsh)"; reason = "Piping wget to shell is not allowed"; }

    { pattern = "\\bgit\\s+push\\s+--force\\b"; reason = "git force push is not allowed"; }
    { pattern = "\\bgit\\s+reset\\s+--hard\\b"; reason = "git reset --hard is not allowed"; }
    { pattern = "\\bgit\\s+clean\\s+-[fdx]"; reason = "git clean is not allowed"; }
    { pattern = "\\bgit\\s+checkout\\s+-B\\b"; reason = "git checkout -B (force branch) is not allowed"; }
    { pattern = "\\bgit\\s+checkout\\b"; reason = "git checkout is not allowed. Use 'git switch' for branches and 'git restore' for files"; }
    { pattern = "\\bgit\\s+branch\\s+-D\\b"; reason = "git branch -D (force delete) is not allowed. Use 'git branch -d' for safe deletion"; }
    { pattern = "\\bgit\\s+rebase\\b"; reason = "git rebase is not allowed (use merge)"; }
    { pattern = "\\bgit\\s+stash\\s+(drop|clear)\\b"; reason = "git stash drop/clear is not allowed"; }
    { pattern = "\\bgit\\s+tag\\s+-d\\b"; reason = "git tag deletion is not allowed"; }

    { pattern = "\\bgit\\s+add\\s+-A\\b"; reason = "git add -A is not allowed. Add files individually"; }
    { pattern = "\\bgit\\s+add\\s+--all\\b"; reason = "git add --all is not allowed. Add files individually"; }
    { pattern = "\\bgit\\s+add\\s+-u\\b"; reason = "git add -u is not allowed. Add files individually"; }
    { pattern = "\\bgit\\s+add\\s+--update\\b"; reason = "git add --update is not allowed. Add files individually"; }
    { pattern = "\\bgit\\s+add\\s+\\.\\s*$"; reason = "git add . is not allowed. Add files individually"; }
    { pattern = "\\bgit\\s+add\\s+\\*"; reason = "git add with glob is not allowed. Add files individually"; }

    { pattern = "\\bterraform\\s+destroy\\b"; reason = "terraform destroy is not allowed"; }
    { pattern = "\\bterraform\\s+apply\\b.*-auto-approve"; reason = "terraform apply -auto-approve is not allowed"; }
    { pattern = "\\bterraform\\s+state\\s+(rm|mv|push)\\b"; reason = "Direct terraform state manipulation is not allowed"; }
    { pattern = "\\bterraform\\s+force-unlock\\b"; reason = "terraform force-unlock is not allowed"; }
    { pattern = "\\bterraform\\s+import\\b"; reason = "terraform import requires manual review"; }

    { pattern = "\\bnix\\s+profile\\s+wipe-history"; reason = "nix profile wipe-history is not allowed"; }
    { pattern = "\\bnix-env\\s+-e\\b"; reason = "nix-env -e (uninstall) is not allowed"; }

    { pattern = "\\bdocker\\s+system\\s+prune\\b"; reason = "docker system prune is not allowed"; }
    { pattern = "\\bdocker\\s+volume\\s+rm\\b"; reason = "docker volume rm is not allowed"; }
    { pattern = "\\bdocker\\s+image\\s+prune\\b"; reason = "docker image prune is not allowed"; }

    { pattern = "\\baws\\s+.*\\s+delete-"; reason = "AWS delete operations are not allowed"; }
    { pattern = "\\baws\\s+s3\\s+rm\\b"; reason = "aws s3 rm is not allowed"; }
    { pattern = "\\baws\\s+s3\\s+rb\\b"; reason = "aws s3 rb (remove bucket) is not allowed"; }
    { pattern = "\\baws\\s+iam\\b"; reason = "AWS IAM operations are not allowed via CLI"; }
    { pattern = "\\baws\\s+sts\\s+assume-role\\b"; reason = "AWS STS assume-role is not allowed"; }

    { pattern = "\\bkubectl\\s+delete\\b"; reason = "kubectl delete is not allowed"; }
    { pattern = "\\bkubectl\\s+drain\\b"; reason = "kubectl drain is not allowed"; }
    { pattern = "\\bkubectl\\s+cordon\\b"; reason = "kubectl cordon is not allowed"; }

    { pattern = "\\bkill\\s+-9\\b"; reason = "kill -9 is not allowed"; }
    { pattern = "\\bkillall\\b"; reason = "killall is not allowed"; }
    { pattern = "\\bshutdown\\b"; reason = "shutdown is not allowed"; }
    { pattern = "\\breboot\\b"; reason = "reboot is not allowed"; }
    { pattern = "\\bsystemctl\\s+(stop|disable|mask)\\b"; reason = "Stopping/disabling services is not allowed"; }

    { pattern = "\\bprintenv\\b"; reason = "Viewing environment variables with printenv is not allowed"; }
    { pattern = "(^|[|;&])\\s*env\\s*($|[|;&\\s])"; reason = "Viewing environment variables with env is not allowed"; }
    { pattern = "\\bexport\\b"; reason = "Setting environment variables with export is not allowed"; }

    { pattern = "(?i)\\b(UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE)\\b"; reason = "Destructive SQL operation is not allowed"; }
  ];

  bashAsk = map (r: r // { tool = "Bash"; decision = "ask"; }) [
    { pattern = "(?i)\\bINSERT\\s+INTO\\b"; reason = "Attempting SQL INSERT operation"; }

    { pattern = "\\bgit\\s+push\\b"; reason = "Attempting git push"; }
    { pattern = "\\bgit\\s+config\\b"; reason = "Attempting to run git config"; }
    { pattern = "\\bgit\\s+merge\\b"; reason = "Attempting git merge"; }
    { pattern = "\\bgit\\s+commit\\s+--amend\\b"; reason = "Attempting to amend a commit"; }
    { pattern = "\\bterraform\\s+apply\\b"; reason = "Attempting terraform apply"; }
    { pattern = "\\bnix\\s+flake\\s+update\\b"; reason = "Attempting nix flake update"; }
    { pattern = "\\bdocker\\s+compose\\s+down\\b"; reason = "Attempting docker compose down"; }
    { pattern = "\\bnpm\\s+publish\\b"; reason = "Attempting npm publish"; }
    { pattern = "\\bcargo\\s+publish\\b"; reason = "Attempting cargo publish"; }

    { pattern = "\\bcurl\\b.*(-o|-O)"; reason = "Downloading a file with curl"; }
    { pattern = "\\bwget\\b"; reason = "Downloading a file with wget"; }
  ];

  fileDeny = [
    { tool = fileTools; pattern = "\\.env"; decision = "deny"; reason = ".env files are not allowed"; }
    { tool = fileTools; pattern = "\\.env\\..*"; decision = "deny"; reason = ".env.* files are not allowed"; }
    { tool = fileTools; pattern = "id_(rsa|ed25519|ecdsa)"; decision = "deny"; reason = "SSH key access is not allowed"; }
    { tool = fileTools; pattern = "\\.pem$"; decision = "deny"; reason = "PEM certificate file access is not allowed"; }
    { tool = fileTools; pattern = "\\.p12$"; decision = "deny"; reason = "PKCS12 file access is not allowed"; }
    { tool = fileTools; pattern = "\\.aws/credentials"; decision = "deny"; reason = "AWS credentials file is not allowed"; }
    { tool = fileTools; pattern = "\\.aws/config"; decision = "deny"; reason = "AWS config file access is not allowed"; }
    { tool = fileTools; pattern = "\\.kube/config"; decision = "deny"; reason = "kubeconfig access is not allowed"; }
    { tool = fileTools; pattern = "\\.ssh/"; decision = "deny"; reason = "SSH directory access is not allowed"; }
    { tool = fileTools; pattern = "\\.gnupg/"; decision = "deny"; reason = "GPG directory access is not allowed"; }
    { tool = fileTools; pattern = "\\.npmrc"; decision = "deny"; reason = ".npmrc may contain auth tokens"; }
    { tool = fileTools; pattern = "\\.netrc"; decision = "deny"; reason = ".netrc contains credentials"; }
    { tool = fileTools; pattern = "\\.git-credentials$"; decision = "deny"; reason = ".git-credentials contains credentials"; }
    { tool = fileTools; pattern = "\\.docker/config\\.json"; decision = "deny"; reason = "Docker config may contain auth tokens"; }
    { tool = fileTools; pattern = "secrets?\\.ya?ml"; decision = "deny"; reason = "Secrets YAML files are not allowed"; }
    { tool = fileTools; pattern = "(secret|token)"; decision = "deny"; reason = "Files containing secrets/tokens are not allowed"; }
    { tool = fileTools; pattern = "sops[_-]"; decision = "deny"; reason = "SOPS encrypted files are not allowed"; }

    { tool = writeTools; pattern = "^/etc/"; decision = "deny"; reason = "Editing system files is not allowed"; }
    { tool = writeTools; pattern = "^/var/"; decision = "deny"; reason = "Editing /var files is not allowed"; }
    { tool = writeTools; pattern = "^/usr/"; decision = "deny"; reason = "Editing /usr files is not allowed"; }

    { tool = writeTools; pattern = "terraform\\.tfstate"; decision = "deny"; reason = "Direct tfstate editing is not allowed"; }
    { tool = writeTools; pattern = "\\.terraform/"; decision = "deny"; reason = ".terraform directory editing is not allowed"; }
    { tool = writeTools; pattern = "\\.lock$"; decision = "deny"; reason = "Lock files should not be edited directly"; }
  ];

in
{
  rules = bashDeny ++ bashAsk ++ fileDeny;
}
