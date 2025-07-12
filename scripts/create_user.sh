#!/bin/bash
set -euo pipefail
set +x

NEW_TF_DB_USER_PASSWORD="${1:-}"

if [ -z "$NEW_TF_DB_USER_PASSWORD" ]; then
  echo "Usage: $0 <password>"
  exit 1
fi
PG_HOST="postgres.home.local" # Your external hostname for PostgreSQL
PG_PORT="5432"
PG_DATABASE="postgres"       # Connect to the default 'postgres' database to create users
NEW_TF_DB_USER="tf-postgres-user"
# Assign a password for the new user. Even for cert auth, having a password
# can be good for fallback or other connection types.
# IMPORTANT: Replace this with a strong, randomly generated password,
#            or retrieve it from a secrets manager like Vault.
#            For this example, we'll hardcode it, but DO NOT do this in production.

# The superuser you can use to connect and create new users (e.g., from your init-user.sql)
ADMIN_DB_USER="superadmin"

# --- SQL Command to Create User with Privileges ---
# We use DO $$ BEGIN ... END $$; to make it idempotent (safe to run multiple times)
# If the role doesn't exist, it creates it. Otherwise, it just alters the password.
# You can remove the PASSWORD part if you strictly only want cert authentication.
# This SQL is idempotent: it creates the user if they don't exist,
# and updates their attributes/password if they do.
SQL_COMMAND="""
DO \$\$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_roles WHERE rolname = '$NEW_TF_DB_USER'
  ) THEN
    CREATE ROLE \"$NEW_TF_DB_USER\" WITH LOGIN PASSWORD '$NEW_TF_DB_USER_PASSWORD' CREATEDB CREATEROLE;
  ELSE
    ALTER ROLE \"$NEW_TF_DB_USER\" WITH LOGIN PASSWORD '$NEW_TF_DB_USER_PASSWORD' CREATEDB CREATEROLE;
  END IF;
END \$\$;
"""

echo "[+] Attempting to create/update PostgreSQL user: $NEW_TF_DB_USER"

# Execute the SQL command inside the container
# We pass the password via PGPASSWORD environment variable for security
psql "host=$PG_HOST port=$PG_PORT dbname=$PG_DATABASE user=$ADMIN_DB_USER \
  sslmode=verify-full \
  sslcert=/Users/ranjithmanyam/dev/pki/certs/superadmin-client/superadmin.crt \
  sslkey=/Users/ranjithmanyam/dev/pki/certs/superadmin-client/superadmin.key.pem \
  sslrootcert=/Users/ranjithmanyam/dev/pki/intermediate-ca/certs/ca-chain.cert.pem" \
  -c "$SQL_COMMAND"

echo "[✔] User creation script completed. Please check the output above for success/errors."
echo "Remember to grant specific permissions to $NEW_TF_DB_USER if needed beyond just LOGIN."

# Also need the below perms to be able to create extensions
#GRANT CREATE ON DATABASE \"$TARGET_DATABASE\" TO \"$TARGET_USER\";


#psql "host=postgres.home.local port=5432 dbname=postgres user=tf-postgres-user sslmode=verify-full sslcert=/Users/ranjithmanyam/dev/pki/certs/tf-postgres-user-client/tf-postgres-user.crt sslkey=/Users/ranjithmanyam/dev/pki/certs/tf-postgres-user-client/tf-postgres-user.key.pem sslrootcert=/Users/ranjithmanyam/dev/pki/intermediate-ca/certs/ca-chain.cert.pem"