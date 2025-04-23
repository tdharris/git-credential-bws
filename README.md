# Git Credential Helper for Bitwarden Secrets Manager CLI

A [Git credential helper](https://git-scm.com/docs/gitcredentials) that retrieves credentials from [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/) using the `bws` CLI.

This helper allows you to store your Git credentials (like personal access tokens or username/password) securely in Bitwarden Secrets Manager and have Git automatically fetch them when needed.

## How it Works

1. Git invokes the helper script when credentials are required.
2. The script receives the `get` command from Git.
3. It uses `bws secret get <secret_id>` to fetch the secret data from Bitwarden Secrets Manager.
4. It uses `jq` to parse the fetched JSON and extract the nested JSON string using the provided username (optional) and password key arguments as the JSON key paths.
6. It outputs the credentials to Git in the required format (`username=...` and  `password=...`).

## Prerequisites

Before using this credential helper, ensure you have the following installed and configured:

1. `bws` : [Bitwarden Secrets Manager CLI](https://bitwarden.com/help/secrets-manager-cli/).
    * Ensure `bws` is configured to access your secrets. You likely need to set the `BWS_ACCESS_TOKEN` environment variable.
2. `jq` : A command-line JSON processor.

## Installation

Executing the following command will download the script and make it executable:

```console
curl -s https://raw.githubusercontent.com/tdharris/git-credential-bws/main/installer.sh | bash -s
```

### Manual Installation

1. Download the `git-credential-bws` script and place it in a directory in your `PATH` (e.g., `/usr/local/bin`).
2. Make the script executable:

    ```console
    chmod +x /path/to/git-credential-bws
    ```

## Configuration

To use the helper, you need to configure Git to use it as a credential helper. You can do this globally or for specific domains or even repositories. The configuration is done in your Git configuration file (`~/.gitconfig`).

1.  **Prepare your Bitwarden Secret:**
    * Create a secret in Bitwarden Secrets Manager.
    * The **value** of this secret **must be a JSON string** containing key-value pairs for your credentials.
    * Example Secret Value:
        ```jsonc
        {
          "GIT_USER": "my-github-username", // Optional
          "GITHUB_OAUTH_TOKEN": "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        }
        ```
        ```jsonc
        {
          "GIT_USER": "my-github-username", // Optional
          "GITLAB_TOKEN": "glpat-yyyyyyyyyyyyyyyyyyyyyyyyyyyy"
        }
        ```
    * Note the **Secret ID** (e.g., `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).

2.  **Configure Git:**
    * Use `git config` to tell Git to use `git-credential-bws`. You must provide the Secret ID (`-s`) and the key within the secret's JSON value that holds the password/token (`-p`). Optionally, provide the key for the username (`-u`).
    * The command format is: 
        ```shell
        !git-credential-bws -s <secret_id> -p <password_key> [-u <username_key>]
        ```
        * The `!` tells Git to treat the command as a shell command.
        * Ensure `git-credential-bws` is executable and in your `PATH`, or use the full path to the script.

    * Examples (using the secret above):

        * **Configure for GitHub (using PAT only):**
            ```bash
            # Uses the secret ID and the 'GITHUB_OAUTH_TOKEN' key from the JSON
            git config --global credential.https://github.com.helper \
              '!git-credential-bws -s YOUR_SECRET_ID -p GITHUB_OAUTH_TOKEN'
            ```

        * **Configure for GitLab (using PAT only):**
            ```bash
            # Uses the secret ID and the 'GITLAB_TOKEN' key from the JSON
            git config --global credential.https://gitlab.com.helper \
              '!git-credential-bws -s YOUR_SECRET_ID -p GITLAB_TOKEN'
            ```

        * **Configure for a service requiring username and password:**
            ```bash
            # Uses the secret ID, 'GIT_USER' key for username, 'GITHUB_OAUTH_TOKEN' key for password
            git config --global credential.https://mygitserver.com.helper \
              '!git-credential-bws -s YOUR_SECRET_ID -u GIT_USER -p GITHUB_OAUTH_TOKEN'
            ```

        * **Global fallback (less common, use per-host if possible):**
            ```bash
            # Uses the secret ID and 'GITHUB_OAUTH_TOKEN' key globally (use with caution)
            git config --global credential.helper \
             '!git-credential-bws -s YOUR_SECRET_ID -p GITHUB_OAUTH_TOKEN'
            ```

    * Replace `YOUR_SECRET_ID` with your actual Bitwarden Secret ID.
