#!/bin/bash
# PostToolUse hook for Edit/Write/MultiEdit tools.
# Reads JSON from stdin, detects the edited file's language and project config,
# then runs the appropriate formatter/linter automatically.

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

ext="${file_path##*.}"

project_root=$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null)
if [ -z "$project_root" ]; then
  project_root=$(dirname "$file_path")
fi

run() {
  "$@" 2>&1
  local status=$?
  if [ $status -ne 0 ]; then
    echo "formatter failed: $*" >&2
    exit 2
  fi
}

find_config() {
  local root="$1"
  shift
  for name in "$@"; do
    if [ -f "$root/$name" ]; then
      echo "$root/$name"
      return 0
    fi
  done
  return 1
}

case "$ext" in
  go)
    if ! find_config "$project_root" go.mod > /dev/null; then
      exit 0
    fi
    if find_config "$project_root" .golangci.yml .golangci.yaml .golangci.toml .golangci.json > /dev/null; then
      echo "Running golangci-lint on $file_path"
      run golangci-lint run --fix "$file_path"
    elif command -v goimports > /dev/null 2>&1; then
      echo "Running goimports on $file_path"
      run goimports -w "$file_path"
    else
      echo "Running gofmt on $file_path"
      run gofmt -w "$file_path"
    fi
    ;;

  ts|tsx|js|jsx)
    if find_config "$project_root" biome.json biome.jsonc > /dev/null; then
      echo "Running biome on $file_path"
      run npx @biomejs/biome format --write "$file_path"
      run npx @biomejs/biome check --fix "$file_path"
    elif find_config "$project_root" .prettierrc .prettierrc.js .prettierrc.cjs .prettierrc.mjs .prettierrc.json .prettierrc.json5 .prettierrc.yaml .prettierrc.yml .prettierrc.toml prettier.config.js prettier.config.cjs prettier.config.mjs prettier.config.ts > /dev/null; then
      echo "Running prettier on $file_path"
      run npx prettier --write "$file_path"
    elif find_config "$project_root" eslint.config.js eslint.config.cjs eslint.config.mjs eslint.config.ts .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.yaml .eslintrc.yml .eslintrc.json > /dev/null; then
      echo "Running eslint on $file_path"
      run npx eslint --fix "$file_path"
    elif [ -f "$project_root/package.json" ] && jq -e '.scripts.format' "$project_root/package.json" > /dev/null 2>&1; then
      echo "Running npm run format in $project_root"
      run npm --prefix "$project_root" run format
    fi
    ;;

  py)
    has_ruff=false
    has_black=false
    has_isort=false

    if find_config "$project_root" ruff.toml .ruff.toml > /dev/null; then
      has_ruff=true
    elif [ -f "$project_root/pyproject.toml" ] && grep -q '\[tool\.ruff\]' "$project_root/pyproject.toml"; then
      has_ruff=true
    fi

    if [ -f "$project_root/pyproject.toml" ] && grep -q '\[tool\.black\]' "$project_root/pyproject.toml"; then
      has_black=true
    fi

    if [ -f "$project_root/pyproject.toml" ] && grep -q '\[tool\.isort\]' "$project_root/pyproject.toml"; then
      has_isort=true
    elif find_config "$project_root" .isort.cfg > /dev/null; then
      has_isort=true
    fi

    if $has_ruff; then
      echo "Running ruff on $file_path"
      run ruff format "$file_path"
      run ruff check --fix "$file_path"
    else
      if $has_black; then
        echo "Running black on $file_path"
        run black "$file_path"
      fi
      if $has_isort; then
        echo "Running isort on $file_path"
        run isort "$file_path"
      fi
    fi
    ;;

  nix)
    if command -v nixfmt > /dev/null 2>&1; then
      echo "Running nixfmt on $file_path"
      run nixfmt "$file_path"
    elif command -v alejandra > /dev/null 2>&1; then
      echo "Running alejandra on $file_path"
      run alejandra "$file_path"
    fi
    ;;
esac

exit 0
