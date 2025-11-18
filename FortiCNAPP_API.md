# Lacework Provider Configuration

The Lacework provider can be configured with the proper credentials via the following supported methods:

## 1. Static Credentials

You can directly specify credentials in your Terraform configuration. For sensitive values like API keys, it's recommended to use secrets management:

```hcl
provider "lacework" {
  account    = "{{ secrets.LW_ACCOUNT }}"
  api_key    = "{{ secrets.LW_API_KEY }}"
  api_secret = "{{ secrets.LW_SECRET }}"
}
```

Alternatively, you can use short-lived credentials with an API token:

```hcl
provider "lacework" {
  account   = "my-account"
  api_token = "my-api-token"
}
```

## 2. Environment Variables

Configure the provider using environment variables. Set the following variables in your shell:

```bash
export LW_ACCOUNT="my-account"
export LW_API_KEY="my-api-key"
export LW_API_SECRET="my-api-secret"
```

Then reference them in your Terraform configuration without specifying credentials directly.

**Note:** You can generate an API access token using the Lacework CLI command:

```bash
lacework access-token
```

## 3. Configuration File

Use the Lacework configuration file located at `$HOME/.lacework.toml`. Run the following command to configure:

```bash
lacework configure
```

Then reference a specific profile in your Terraform provider block:

```hcl
provider "lacework" {
  profile = "custom-profile"
}
```
