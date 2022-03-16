resource "keycloak_realm" "realm" {
  realm             = var.namespace
  enabled           = true
  display_name      = ""
  display_name_html = ""

  login_theme   = "saj6"
  account_theme = "keycloak"
  admin_theme   = "keycloak"
  email_theme   = "keycloak"


  access_code_lifespan     = "1h"
  ssl_required             = "external"
  remember_me              = true
  duplicate_emails_allowed = true
  reset_password_allowed   = true
  password_policy          = "passwordHistory(1)"
  attributes = {
    pkceCodeChallengeMethod = "S256"
  }

  smtp_server {
    host                  = var.smtp_host
    from                  = var.smtp_mail
    starttls              = true
    from_display_name     = "JusticiaDigital"
    reply_to_display_name = "No-Reply"
    port                  = var.smtp_port

    auth {
      username = var.smtp_user
      password = var.smtp_password
    }
  }

  internationalization {
    supported_locales = [
      "es",
      "es-CO",
      "pt-BR"
    ]
    default_locale = "pt-BR"
  }

  security_defenses {
    headers {
      x_frame_options                     = "SAMEORIGIN"
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                = false
      max_login_failures               = 30
      wait_increment_seconds           = 60
      quick_login_check_milli_seconds  = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds         = 900
      failure_reset_time_seconds       = 43200
    }
  }

  web_authn_policy {
    relying_party_entity_name = "keycloak"
    relying_party_id          = ""
    signature_algorithms      = ["ES256"]
  }

}

##Authentication Flow

#Flow alias
resource "keycloak_authentication_flow" "flow" {
  realm_id = keycloak_realm.realm.id
  alias    = "Browser SAJ6"
}


# sub-flow - first execution: Cookie
resource "keycloak_authentication_subflow" "subflow_one" {
  alias             = "Cookie"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow.alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
}


# sub-flow - second execution: Identity
resource "keycloak_authentication_subflow" "subflow_two" {
  alias             = "Identity"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow.alias
  authenticator     = "identity-provider-redirector"
  requirement       = "ALTERNATIVE"
  depends_on = [
    keycloak_authentication_subflow.subflow_one
  ]
}


# sub-flow - third execution: Browser SAJ6 Forms
resource "keycloak_authentication_subflow" "subflow_three" {
  alias             = "Browser SAJ6 Forms"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow.alias
  authenticator     = "auth-username-password-form"
  requirement       = "ALTERNATIVE"
  depends_on = [
    keycloak_authentication_subflow.subflow_two
  ]
}


# fourth execution: Username Password Form
resource "keycloak_authentication_execution" "execution_four" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.subflow_three.alias
  authenticator     = "auth-username-password-form"
  requirement       = "REQUIRED"
  depends_on = [
    keycloak_authentication_subflow.subflow_three
  ]
}


# sub-flow - fifth execution: Browser SAJ6 Forms Auth-opt-form-conditional
resource "keycloak_authentication_subflow" "subflow_fifth" {
  alias             = "Browser SAJ6 Forms Auth-opt-form-conditional"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.subflow_three.alias
  authenticator     = "auth-username-password-form"
  requirement       = "CONDITIONAL"
  depends_on = [
    keycloak_authentication_execution.execution_four
  ]
}

# Sub-flow - sixth execution: Condition - user configured
resource "keycloak_authentication_subflow" "subflow_sixth" {
  alias             = "Condition - user configured"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.subflow_fifth.alias
  authenticator     = "auth-username-password-form"
  requirement       = "REQUIRED"
  depends_on = [
    keycloak_authentication_subflow.subflow_fifth
  ]
}


# Sub-flow - seventh execution: OTP Form
resource "keycloak_authentication_subflow" "subflow_seventh" {
  alias             = "OTP Form"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.subflow_fifth.alias
  authenticator     = "auth-otp-form"
  requirement       = "REQUIRED"
  depends_on = [
    keycloak_authentication_subflow.subflow_sixth
  ]
}


## Authentication flow: reset credentials


#Flow alias - SAJ6 - Reset Credentials
resource "keycloak_authentication_flow" "flow_one" {
  realm_id = keycloak_realm.realm.id
  alias    = "SAJ6 - Reset Credentials"
}


# first execution - Choose User
resource "keycloak_authentication_execution" "new_one" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow_one.alias
  authenticator     = "reset-credentials-choose-user"
  requirement       = "REQUIRED"
}
# second execution - Reset Email
resource "keycloak_authentication_execution" "new_two" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow_one.alias
  authenticator     = "reset-credential-email"
  requirement       = "REQUIRED"
  depends_on = [
    keycloak_authentication_execution.new_one
  ]
}
# third execution - Reset Password
resource "keycloak_authentication_execution" "new_three" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow_one.alias
  authenticator     = "reset-password"
  #alias             = ""
  requirement = "REQUIRED"
  depends_on = [
    keycloak_authentication_execution.new_two
  ]
}
#fourth execution - reset-otp-conditional
resource "keycloak_authentication_subflow" "four" {
  alias             = "SAJNI"
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow_one.alias
  authenticator     = "auth-otp-form"
  requirement       = "CONDITIONAL"
  depends_on = [
    keycloak_authentication_execution.new_three
  ]
}

# fifth execution - conditional-user-configured
resource "keycloak_authentication_execution" "new_five" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.four.alias
  authenticator     = "conditional-user-configured"
  requirement       = "REQUIRED"
  depends_on = [
    keycloak_authentication_subflow.four
  ]
}
# sixth execution - reset-otp
resource "keycloak_authentication_execution" "new_six" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_subflow.four.alias
  authenticator     = "reset-otp"
  requirement       = "REQUIRED"
  depends_on = [
    keycloak_authentication_execution.new_five
  ]
}


## Bindings

resource "keycloak_openid_client" "client" {
  client_id                    = "saj"
  realm_id                     = keycloak_realm.realm.id
  access_type                  = "PUBLIC"
  standard_flow_enabled        = true
  implicit_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "*"
  ]
  web_origins = [
    "*"
  ]
  authentication_flow_binding_overrides {
    browser_id = keycloak_authentication_flow.flow.id
  }
}

## User federations

resource "keycloak_custom_user_federation" "custom_user_federation" {
  name        = "saj"
  realm_id    = keycloak_realm.realm.id
  provider_id = "saj"
  enabled     = true
  config = {
    priority               = "0"
    flavor                 = var.keycloak_custom_federation_flavor
    jdbcURI                = var.keycloak_custom_federation_jdbcuri
    user                   = var.keycloak_custom_federation_user
    password               = var.keycloak_custom_federation_password
    poolSize               = "2"
    cache_policy           = "NO_CACHE"
    newVersionUsers        = ""
    newVersionCookieDomain = ".dev.cliente.com.br"
  }
}

#USER KEYCLOAK

resource "keycloak_user" "user_password" {
  realm_id = var.namespace
  username = var.namespace
  enabled  = true


  initial_password {
    value     = var.password
    temporary = false
  }
  depends_on = [
    keycloak_realm.realm
  ]
}



#####

# realm roles

resource "keycloak_role" "create_role" {
  realm_id = keycloak_realm.realm.id
  name     = "create"

}

resource "keycloak_role" "read_role" {
  realm_id = keycloak_realm.realm.id
  name     = "read"

}

resource "keycloak_role" "update_role" {
  realm_id = keycloak_realm.realm.id
  name     = "update"

}

resource "keycloak_role" "delete_role" {
  realm_id = keycloak_realm.realm.id
  name     = "delete"

}


resource "keycloak_role" "client_role" {
  realm_id    = keycloak_realm.realm.id
  client_id   = keycloak_openid_client.client.id
  name        = "my-client-role"
  description = "My Client Role"


}



resource "keycloak_role" "admin_role" {
  realm_id = keycloak_realm.realm.id
  name     = "admin"
  composite_roles = [
    keycloak_role.create_role.id,
    keycloak_role.read_role.id,
    keycloak_role.update_role.id,
    keycloak_role.delete_role.id,
    keycloak_role.client_role.id,
  ]
}



/*resource "keycloak_default_roles" "defalut_roles" {
  realm_id      = keycloak_realm.realm.id
  default_roles = ["realm-management"]
}*/
