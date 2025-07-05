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
  destination = "/output/pgadmin/.env"
  perms       = 0600
  command     = "chown 5050:5050 /output/pgadmin/.env_pgadmin"
}

template {
  source      = "/vault-agent/templates/pgadmin_cert.ctmpl"
  destination = "/output/certs/pgadmin/pgadmin.crt"
  perms       = 0644
  command     = "chown 5050:5050 /output/certs/pgadmin/pgadmin.crt"
}

template {
  source      = "/vault-agent/templates/pgadmin_key.ctmpl"
  destination = "/output/certs/pgadmin/pgadmin.key"
  perms       = 0600
  command     = "chown 5050:5050 /output/certs/pgadmin/pgadmin.key"
}

template {
  source      = "/vault-agent/templates/postgres.ctmpl"
  destination = "/output/postgres/.env"
  perms       = 0600
  command     = "chown 999:999 /output/postgres/.env_postgres"
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