vault {
  address = "https://vault:8200"
  tls_ca_file = "/etc/ssl/certs/ca-certificates.crt"
}

auto_auth {
  method "token_file" {
    config = {
      token_file_path = "/secrets/.vault-token"
    }
  }

  sink "file" {
    config = {
      path = "/vault-token"
    }
  }
}

template {
  source      = "/vault-agent/templates/pgadmin.ctmpl"
  destination = "/output/secrets/.env_pgadmin"
  perms       = 0600
  command     = "chown 5050:5050 /output/secrets/.env_pgadmin"
}

template {
  source      = "/vault-agent/templates/pgadmin_cert.ctmpl"
  destination = "/output/certs/pgadmin/server.cert"
  perms       = 0644
  command     = "chown 5050:5050 /output/certs/pgadmin/server.cert"
}

template {
  source      = "/vault-agent/templates/pgadmin_key.ctmpl"
  destination = "/output/certs/pgadmin/server.key"
  perms       = 0600
  command     = "chown 5050:5050 /output/certs/pgadmin/server.key"
}

template {
  source      = "/vault-agent/templates/postgres.ctmpl"
  destination = "/output/secrets/.env_postgres"
  perms       = 0600
  command     = "chown 999:999 /output/secrets/.env_postgres"
}

template {
  source      = "/vault-agent/templates/postgres_cert.ctmpl"
  destination = "/output/certs/postgres/postgres.crt"
  perms       = 0644
  command     = "chown 999:999 /output/certs/postgres/postgres.crt"
}

template {
  source      = "/vault-agent/templates/postgres_key.ctmpl"
  destination = "/output/certs/postgres/postgres.key"
  perms       = 0600
  command     = "chown 999:999 /output/certs/postgres/postgres.key"
}