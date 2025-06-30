#!/bin/bash
set -euo pipefail

VAULT_ADDR="https://vault.devdotweb.com"
ROLE_NAME="consul"
ROLE_PATH="auth/approle/role/$ROLE_NAME"
SECRETS_DIR="./secrets"
PRIV_TOKEN_FILE="./vault-bootstrap.token"

mkdir -p "$SECRETS_DIR"

if [[ ! -f "$PRIV_TOKEN_FILE" ]]; then
  echo "Missing $PRIV_TOKEN_FILE with a Vault token that can generate secret_id"
  exit 1
fi

VAULT_TOKEN=$(cat "$PRIV_TOKEN_FILE")

# Retrieve role_id only once (assume it's static)
vault read -field=role_id -address="$VAULT_ADDR" -token="$VAULT_TOKEN" "$ROLE_PATH/role-id" > "$SECRETS_DIR/role_id"

# Generate new secret_id
vault write -field=secret_id -address="$VAULT_ADDR" -token="$VAULT_TOKEN" "$ROLE_PATH/secret-id" > "$SECRETS_DIR/secret_id"

echo "✅ Generated new secret_id for AppRole '$ROLE_NAME'"