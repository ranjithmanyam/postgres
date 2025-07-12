#!/bin/bash
set -euo pipefail
set -x

# --- Configuration ---
NEW_DB_USER="$1"
# Assign a password for the new user. Even for cert auth, having a password
# can be good for fallback or other connection types.
# IMPORTANT: Replace this with a strong, randomly generated password,
#            or retrieve it from a secrets manager like Vault.
#            For this example, we'll hardcode it, but DO NOT do this in production.
NEW_DB_USER_PASSWORD="ivAj7SOv1qy5jPflzzySUS3lDxaexZn9tNDJ6Pf8"
# The superuser you can use to connect and create new users (e.g., from your init-user.sql)
ADMIN_DB_USER="superadmin"
ADMIN_DB_PASSWORD="j3WANt3Ua9vh2fERG7FxFDE9jHH0PA0TupFSlgBM"

# --- SQL Command to Create User ---
# We use DO $$ BEGIN ... END $$; to make it idempotent (safe to run multiple times)
# If the role doesn't exist, it creates it. Otherwise, it just alters the password.
# You can remove the PASSWORD part if you strictly only want cert authentication.
SQL_COMMAND="""
DO \$\$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_roles WHERE rolname = '$NEW_DB_USER'
  ) THEN
    CREATE ROLE \"$NEW_DB_USER\" WITH LOGIN PASSWORD '$NEW_DB_USER_PASSWORD';
#    -- GRANT CONNECT ON DATABASE your_database TO \"$NEW_DB_USER\"; -- Grant specific permissions here
#    -- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"$NEW_DB_USER\";
#    -- ALTER DEFAULT PRIVILEGES FOR ROLE \"$NEW_DB_USER\" IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \"$NEW_DB_USER\";
  ELSE
    ALTER ROLE \"$NEW_DB_USER\" WITH PASSWORD '$NEW_DB_USER_PASSWORD';
  END IF;
END \$\$;
"""

echo "[+] Attempting to create/update PostgreSQL user: $NEW_DB_USER"

# Execute the SQL command inside the container
# We pass the password via PGPASSWORD environment variable for security
docker-compose exec $PG_CONTAINER_NAME bash -c "export PGPASSWORD='$ADMIN_DB_PASSWORD' && psql -U $ADMIN_DB_USER -d postgres -c \"$SQL_COMMAND\""

echo "[✔] User creation script completed. Please check the output above for success/errors."
echo "Remember to grant specific permissions to $NEW_DB_USER if needed beyond just LOGIN."