# Collection of git hooks for OpenTofu to be used with [pre-commit framework](http://pre-commit.com/)

[![Github tag](https://img.shields.io/github/tag/tofuutils/pre-commit-opentofu.svg)](https://github.com/tofuutils/pre-commit-opentofu/releases) ![maintenance status](https://img.shields.io/maintenance/yes/2024.svg) [![Help Contribute to Open Source](https://www.codetriage.com/tofuutils/pre-commit-opentofu/badges/users.svg)](https://www.codetriage.com/tofuutils/pre-commit-opentofu)

Want to contribute? Check [open issues](https://github.com/tofuutils/pre-commit-opentofu/issues?q=label%3A%22good+first+issue%22+is%3Aopen+sort%3Aupdated-desc) and [contributing notes](/.github/CONTRIBUTING.md).

## Sponsors
If you are using `pre-commit-opentofu` already or want to support its development and [many other open-source projects](https://github.com/tofuutils), please become a [GitHub Sponsor](https://github.com/sponsors/tofuutils)!


## Table of content

* [Table of content](#table-of-content)
* [How to install](#how-to-install)
  * [1. Install dependencies](#1-install-dependencies)
  * [2. Install the pre-commit hook globally](#2-install-the-pre-commit-hook-globally)
  * [3. Add configs and hooks](#3-add-configs-and-hooks)
  * [4. Run](#4-run)
* [Available Hooks](#available-hooks)
* [Hooks usage notes and examples](#hooks-usage-notes-and-examples)
  * [Known limitations](#known-limitations)
  * [All hooks: Usage of environment variables in `--args`](#all-hooks-usage-of-environment-variables-in---args)
  * [All hooks: Set env vars inside hook at runtime](#all-hooks-set-env-vars-inside-hook-at-runtime)
  * [All hooks: Disable color output](#all-hooks-disable-color-output)
  * [checkov (deprecated) and tofu\_checkov](#checkov-deprecated-and-tofu_checkov)
  * [infracost\_breakdown](#infracost_breakdown)
  * [tofu\_docs](#tofu_docs)
  * [tofu\_docs\_replace (deprecated)](#tofu_docs_replace-deprecated)
  * [tofu\_fmt](#tofu_fmt)
  * [tofu\_providers\_lock](#tofu_providers_lock)
  * [tofu\_tflint](#tofu_tflint)
  * [tofu\_tfsec (deprecated)](#tofu_tfsec-deprecated)
  * [tofu\_trivy](#tofu_trivy)
  * [tofu\_validate](#tofu_validate)
  * [tofu\_wrapper\_module\_for\_each](#tofu_wrapper_module_for_each)
  * [terrascan](#terrascan)
  * [tfupdate](#tfupdate)
* [Docker Usage](#docker-usage)
  * [File Permissions](#file-permissions)
  * [Download OpenTofu modules from private GitHub repositories](#download-tofu-modules-from-private-github-repositories)
* [Authors](#authors)
* [License](#license)

## How to install

### 1. Install dependencies

<!-- markdownlint-disable no-inline-html -->

* [`pre-commit`](https://pre-commit.com/#install),
  <sub><sup>[`opentofu`](https://opentofu.org/docs/intro/install/),
  <sub><sup>[`git`](https://git-scm.com/downloads),
  <sub><sup>POSIX compatible shell,
  <sub><sup>Internet connection (on first run),
  <sub><sup>x86_64 or arm64 compatible operation system,
  <sub><sup>Some hardware where this OS will run,
  <sub><sup>Electricity for hardware and internet connection,
  <sub><sup>Some basic physical laws,
  <sub><sup>Hope that it all will work.
  </sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub></sup></sub><br><br>
* [`checkov`](https://github.com/bridgecrewio/checkov) required for `tofu_checkov` hook.
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) required for `tofu_docs` hook.
* [`terragrunt`](https://terragrunt.gruntwork.io/docs/getting-started/install/) required for `terragrunt_validate` hook.
* [`terrascan`](https://github.com/tenable/terrascan) required for `terrascan` hook.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `tofu_tflint` hook.
* [`TFSec`](https://github.com/liamg/tfsec) required for `tofu_tfsec` hook.
* [`Trivy`](https://github.com/aquasecurity/trivy) required for `tofu_trivy` hook.
* [`infracost`](https://github.com/infracost/infracost) required for `infracost_breakdown` hook.
* [`jq`](https://github.com/stedolan/jq) required for `tofu_validate` with `--retry-once-with-cleanup` flag, and for `infracost_breakdown` hook.
* [`tfupdate`](https://github.com/minamijoyo/tfupdate) required for `tfupdate` hook.
* [`hcledit`](https://github.com/minamijoyo/hcledit) required for `tofu_wrapper_module_for_each` hook.

<details><summary><b>Docker</b></summary><br>

**Pull docker image with all hooks**:

```bash
TAG=latest
docker pull tofuutils/pre-commit-opentofu:$TAG
```

All available tags [here](https://github.com/tofuutils/pre-commit-opentofu/pkgs/container/pre-commit-opentofu/versions).

**Build from scratch**:

> **Note**: To build image you need to have [`docker buildx`](https://docs.docker.com/build/install-buildx/) enabled as default builder.  
> Otherwise - provide `TARGETOS` and `TARGETARCH` as additional `--build-arg`'s to `docker build`.

When hooks-related `--build-arg`s are not specified, only the latest version of `pre-commit` and `opentofu` will be installed.

```bash
git clone git@github.com:tofuutils/pre-commit-opentofu.git
cd pre-commit-opentofu
# Install the latest versions of all the tools
docker build -t pre-commit-opentofu --build-arg INSTALL_ALL=true .
```

To install a specific version of individual tools, define it using `--build-arg` arguments or set it to `latest`:

```bash
docker build -t pre-commit-opentofu \
    --build-arg PRE_COMMIT_VERSION=latest \
    --build-arg TOFU_VERSION=latest \
    --build-arg CHECKOV_VERSION=2.0.405 \
    --build-arg INFRACOST_VERSION=latest \
    --build-arg TERRAFORM_DOCS_VERSION=0.15.0 \
    --build-arg TERRAGRUNT_VERSION=latest \
    --build-arg TERRASCAN_VERSION=1.10.0 \
    --build-arg TFLINT_VERSION=0.31.0 \
    --build-arg TFSEC_VERSION=latest \
    --build-arg TRIVY_VERSION=latest \
    --build-arg TFUPDATE_VERSION=latest \
    --build-arg HCLEDIT_VERSION=latest \
    .
```

Set `-e PRE_COMMIT_COLOR=never` to disable the color output in `pre-commit`.

</details>


<details><summary><b>MacOS</b></summary><br>

```bash
brew install pre-commit terraform-docs tflint tfsec trivy checkov terrascan infracost tfupdate minamijoyo/hcledit/hcledit jq
```

</details>

<details><summary><b>Ubuntu 18.04</b></summary><br>

```bash
sudo apt update
sudo apt install -y unzip software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install -y python3.7 python3-pip
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
python3.7 -m pip install -U checkov
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -o -E -i -m 1 "https://.+?/trivy_.+?_Linux-64bit.tar.gz")" > trivy.tar.gz && tar -xzf trivy.tar.gz trivy && rm trivy.tar.gz && sudo mv trivy /usr/bin
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
sudo apt install -y jq && \
curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost register
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && sudo mv tfupdate /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > hcledit.tar.gz && tar -xzf hcledit.tar.gz hcledit && rm hcledit.tar.gz && sudo mv hcledit /usr/bin/
```

</details>


<details><summary><b>Ubuntu 20.04</b></summary><br>

```bash
sudo apt update
sudo apt install -y unzip software-properties-common python3 python3-pip
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
pip3 install --no-cache-dir checkov
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -o -E -i -m 1 "https://.+?/trivy_.+?_Linux-64bit.tar.gz")" > trivy.tar.gz && tar -xzf trivy.tar.gz trivy && rm trivy.tar.gz && sudo mv trivy /usr/bin
sudo apt install -y jq && \
curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost register
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && sudo mv tfupdate /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > hcledit.tar.gz && tar -xzf hcledit.tar.gz hcledit && rm hcledit.tar.gz && sudo mv hcledit /usr/bin/
```

</details>

<details><summary><b>Ubuntu 22.04</b></summary><br>

```bash
sudo apt update
sudo apt install -y unzip software-properties-common python3 python3-pip
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
pip3 install --no-cache-dir checkov
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -o -E -i -m 1 "https://.+?/trivy_.+?_Linux-64bit.tar.gz")" > trivy.tar.gz && tar -xzf trivy.tar.gz trivy && rm trivy.tar.gz && sudo mv trivy /usr/bin
sudo apt install -y jq && \
curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost register
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && sudo mv tfupdate /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > hcledit.tar.gz && tar -xzf hcledit.tar.gz hcledit && rm hcledit.tar.gz && sudo mv hcledit /usr/bin/
```

</details>


<details><summary><b>Windows 10/11</b></summary>

We highly recommend using [WSL/WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) with Ubuntu and following the Ubuntu installation guide. Or use Docker.

> **Note**: We won't be able to help with issues that can't be reproduced in Linux/Mac.
> So, try to find a working solution and send PR before open an issue.

Otherwise, you can follow [this gist](https://gist.github.com/etiennejeanneaurevolve/1ed387dc73c5d4cb53ab313049587d09):

1. Install [`git`](https://git-scm.com/downloads) and [`gitbash`](https://gitforwindows.org/)
2. Install [Python 3](https://www.python.org/downloads/)
3. Install all prerequisites needed (see above)

Ensure your PATH environment variable looks for `bash.exe` in `C:\Program Files\Git\bin` (the one present in `C:\Windows\System32\bash.exe` does not work with `pre-commit.exe`)

For `checkov`, you may need to also set your `PYTHONPATH` environment variable with the path to your Python modules.  
E.g. `C:\Users\USERNAME\AppData\Local\Programs\Python\Python39\Lib\site-packages`

</details>

<!-- markdownlint-enable no-inline-html -->

### 2. Install the pre-commit hook globally

> **Note**: not needed if you use the Docker image

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

### 3. Add configs and hooks

Step into the repository you want to have the pre-commit hooks installed and run:

```bash
git init
cat <<EOF > .pre-commit-config.yaml
repos:
- repo: https://github.com/tofuutils/pre-commit-opentofu
  rev: <VERSION> # Get the latest from: https://github.com/tofuutils/pre-commit-opentofu/releases
  hooks:
    - id: tofu_fmt
    - id: tofu_docs
EOF
```

### 4. Run

Execute this command to run `pre-commit` on all files in the repository (not only changed files):

```bash
pre-commit run -a
```

Or, using Docker ([available tags](https://github.com/tofuutils/pre-commit-opentofu/pkgs/container/pre-commit-opentofu/versions)):

> **Note**: This command uses your user id and group id for the docker container to use to access the local files.  If the files are owned by another user, update the `USERID` environment variable.  See [File Permissions section](#file-permissions) for more information.

```bash
TAG=latest
docker run -e "USERID=$(id -u):$(id -g)" -v $(pwd):/lint -w /lint tofuutils/pre-commit-opentofu:$TAG run -a
```

Execute this command to list the versions of the tools in Docker:

```bash
TAG=latest
docker run --rm --entrypoint cat tofuutils/pre-commit-opentofu:$TAG /usr/bin/tools_versions_info
```

## Available Hooks

There are several [pre-commit](https://pre-commit.com/) hooks to keep OpenTofu configurations (both `*.tf` and `*.tfvars`) and Terragrunt configurations (`*.hcl`) in a good shape:

<!-- markdownlint-disable no-inline-html -->
| Hook name                                              | Description                                                                                                                                                                                                                                  | Dependencies<br><sup>[Install instructions here](#1-install-dependencies)</sup>      |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `checkov` and `tofu_checkov`                      | [checkov](https://github.com/bridgecrewio/checkov) static analysis of OpenTofu templates to spot potential security issues. [Hook notes](#checkov-deprecated-and-tofu_checkov)                                                         | `checkov`<br>Ubuntu deps: `python3`, `python3-pip`                                   |
| `infracost_breakdown`                                  | Check how much your infra costs with [infracost](https://github.com/infracost/infracost). [Hook notes](#infracost_breakdown)                                                                                                                 | `infracost`, `jq`, [Infracost API key](https://www.infracost.io/docs/#2-get-api-key) |
| `tofu_docs`                                       | Inserts input and output documentation into `README.md`. Recommended. [Hook notes](#terraform_docs)                                                                                                                                          | `terraform-docs`                                                                     |
| `tofu_docs_replace`                               | Runs `terraform-docs` and pipes the output directly to README.md. **DEPRECATED**. [Hook notes](#terraform_docs_replace-deprecated)                              | `python3`, `terraform-docs`                                                          |
| `tofu_docs_without_`<br>`aggregate_type_defaults` | Inserts input and output documentation into `README.md` without aggregate type defaults. Hook notes same as for [tofu_docs](#terraform_docs)                                                                                            | `tofu-docs`                                                                     |
| `tofu_fmt`                                        | Reformat all OpenTofu configuration files to a canonical format. [Hook notes](#terraform_fmt)                                                                                                                                               | -                                                                                    |
| `tofu_providers_lock`                             | Updates provider signatures in [dependency lock files](https://www.terraform.io/docs/cli/commands/providers/lock.html). [Hook notes](#terraform_providers_lock)                                                                              | -                                                                                    |
| `tofu_tflint`                                     | Validates all OpenTofu configuration files with [TFLint](https://github.com/terraform-linters/tflint). [Available TFLint rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules#rules). [Hook notes](#terraform_tflint). | `tflint`                                                                             |
| `tofu_tfsec`                                      | [TFSec](https://github.com/aquasecurity/tfsec) static analysis of terraform templates to spot potential security issues. **DEPRECATED**, use `tofu_trivy`. [Hook notes](#terraform_tfsec-deprecated)                                   | `tfsec`                                                                              |
| `tofu_trivy`                                      | [Trivy](https://github.com/aquasecurity/trivy) static analysis of terraform templates to spot potential security issues. [Hook notes](#terraform_trivy)                                                                                      | `trivy`                                                                              |
| `tofu_validate`                                   | Validates all Terraform configuration files. [Hook notes](#tofu_validate)                                                                                                                                                               | `jq`, only for `--retry-once-with-cleanup` flag                                      |
| `terragrunt_fmt`                                       | Reformat all [Terragrunt](https://github.com/gruntwork-io/terragrunt) configuration files (`*.hcl`) to a canonical format.                                                                                                                   | `terragrunt`                                                                         |
| `terragrunt_validate`                                  | Validates all [Terragrunt](https://github.com/gruntwork-io/terragrunt) configuration files (`*.hcl`)                                                                                                                                         | `terragrunt`                                                                         |
| `tofu_wrapper_module_for_each`                    | Generates OpenTofu wrappers with `for_each` in module. [Hook notes](#terraform_wrapper_module_for_each)                                                                                                                                     | `hcledit`                                                                            |
| `terrascan`                                            | [terrascan](https://github.com/tenable/terrascan) Detect compliance and security violations. [Hook notes](#terrascan)                                                                                                                        | `terrascan`                                                                          |
| `tfupdate`                                             | [tfupdate](https://github.com/minamijoyo/tfupdate) Update version constraints of OpenTofu core, providers, and modules. [Hook notes](#tfupdate)                                                                                             | `tfupdate`                                                                           |
<!-- markdownlint-enable no-inline-html -->

Check the [source file](https://github.com/tofuutils/pre-commit-opentofu/blob/master/.pre-commit-hooks.yaml) to know arguments used for each hook.

## Hooks usage notes and examples

### Known limitations

OpenTofu operates on a per-dir basis, while `pre-commit` framework only supports files and files that exist. This means if you only remove the TF-related file without any other changes in the same dir, checks will be skipped. Example and details [here](https://github.com/pre-commit/pre-commit/issues/3048).

### All hooks: Usage of environment variables in `--args`

> All, except deprecated hooks: `checkov`, `tofu_docs_replace`

You can use environment variables for the `--args` section.

> **Warning**: You _must_ use the `${ENV_VAR}` definition, `$ENV_VAR` will not expand.

Config example:

```yaml
- id: tofu_tflint
  args:
  - --args=--config=${CONFIG_NAME}.${CONFIG_EXT}
  - --args=--module
```

If for config above set up `export CONFIG_NAME=.tflint; export CONFIG_EXT=hcl` before `pre-commit run`, args will be expanded to `--config=.tflint.hcl --module`.

### All hooks: Set env vars inside hook at runtime

> All, except deprecated hooks: `checkov`, `tofu_docs_replace`

You can specify environment variables that will be passed to the hook at runtime.

Config example:

```yaml
- id: tofu_validate
  args:
    - --env-vars=AWS_DEFAULT_REGION="us-west-2"
    - --env-vars=AWS_ACCESS_KEY_ID="anaccesskey"
    - --env-vars=AWS_SECRET_ACCESS_KEY="asecretkey"
```

### All hooks: Disable color output

> All, except deprecated hooks: `checkov`, `tofu_docs_replace`

To disable color output for all hooks, set `PRE_COMMIT_COLOR=never` var. Eg:

```bash
PRE_COMMIT_COLOR=never pre-commit run
```

### checkov (deprecated) and tofu_checkov

> `checkov` hook is deprecated, please use `tofu_checkov`.

Note that `tofu_checkov` runs recursively during `-d .` usage. That means, for example, if you change `.tf` file in repo root, all existing `.tf` files in the repo will be checked.

1. You can specify custom arguments. E.g.:

    ```yaml
    - id: tofu_checkov
      args:
        - --args=--quiet
        - --args=--skip-check CKV2_AWS_8
    ```

    Check all available arguments [here](https://www.checkov.io/2.Basics/CLI%20Command%20Reference.html).

For deprecated hook you need to specify each argument separately:

```yaml
- id: checkov
  args: [
    "-d", ".",
    "--skip-check", "CKV2_AWS_8",
  ]
```

2. When you have multiple directories and want to run `tofu_checkov` in all of them and share a single config file - use the `__GIT_WORKING_DIR__` placeholder. It will be replaced by `tofu_checkov` hooks with the Git working directory (repo root) at run time. For example:

    ```yaml
    - id: tofu_checkov
      args:
        - --args=--config-file __GIT_WORKING_DIR__/.checkov.yml
    ```

### infracost_breakdown

`infracost_breakdown` executes `infracost breakdown` command and compare the estimated costs with those specified in the hook-config. `infracost breakdown` parses OpenTofu HCL code, and calls Infracost Cloud Pricing API (remote version or [self-hosted version](https://www.infracost.io/docs/cloud_pricing_api/self_hosted)).

Unlike most other hooks, this hook triggers once if there are any changed files in the repository.

1. `infracost_breakdown` supports all `infracost breakdown` arguments (run `infracost breakdown --help` to see them). The following example only shows costs:

    ```yaml
    - id: infracost_breakdown
      args:
        - --args=--path=./env/dev
      verbose: true # Always show costs
    ```
    <!-- markdownlint-disable-next-line no-inline-html -->
    <details><summary>Output</summary>

    ```bash
    Running in "env/dev"

    Summary: {
    "unsupportedResourceCounts": {
        "aws_sns_topic_subscription": 1
      }
    }

    Total Monthly Cost:        86.83 USD
    Total Monthly Cost (diff): 86.83 USD
    ```
    <!-- markdownlint-disable-next-line no-inline-html -->
    </details>

2. Note that spaces are not allowed in `--args`, so you need to split it, like this:

    ```yaml
    - id: infracost_breakdown
      args:
        - --args=--path=./env/dev
        - --args=--terraform-var-file="terraform.tfvars"
        - --args=--terraform-var-file="../terraform.tfvars"
    ```

3. (Optionally) Define `cost constraints` the hook should evaluate successfully in order to pass:

    ```yaml
    - id: infracost_breakdown
      args:
        - --args=--path=./env/dev
        - --hook-config='.totalHourlyCost|tonumber > 0.1'
        - --hook-config='.totalHourlyCost|tonumber > 1'
        - --hook-config='.projects[].diff.totalMonthlyCost|tonumber != 10000'
        - --hook-config='.currency == "USD"'
    ```
    <!-- markdownlint-disable-next-line no-inline-html -->
    <details><summary>Output</summary>

    ```bash
    Running in "env/dev"
    Passed: .totalHourlyCost|tonumber > 0.1         0.11894520547945205 >  0.1
    Failed: .totalHourlyCost|tonumber > 1           0.11894520547945205 >  1
    Passed: .projects[].diff.totalMonthlyCost|tonumber !=10000              86.83 != 10000
    Passed: .currency == "USD"              "USD" == "USD"

    Summary: {
    "unsupportedResourceCounts": {
        "aws_sns_topic_subscription": 1
      }
    }

    Total Monthly Cost:        86.83 USD
    Total Monthly Cost (diff): 86.83 USD
    ```
    <!-- markdownlint-disable-next-line no-inline-html -->
    </details>

    * Only one path per one hook (`- id: infracost_breakdown`) is allowed.
    * Set `verbose: true` to see cost even when the checks are passed.
    * Hook uses `jq` to process the cost estimation report returned by `infracost breakdown` command
    * Expressions defined as `--hook-config` argument should be in a jq-compatible format (e.g. `.totalHourlyCost`, `.totalMonthlyCost`)
    To study json output produced by `infracost`, run the command `infracost breakdown -p PATH_TO_TF_DIR --format json`, and explore it on [jqplay.org](https://jqplay.org/).
    * Supported comparison operators: `<`, `<=`, `==`, `!=`, `>=`, `>`.
    * Most useful paths and checks:
        * `.totalHourlyCost` (same as `.projects[].breakdown.totalHourlyCost`) - show total hourly infra cost
        * `.totalMonthlyCost` (same as `.projects[].breakdown.totalMonthlyCost`) - show total monthly infra cost
        * `.projects[].diff.totalHourlyCost` - show the difference in hourly cost for the existing infra and tf plan
        * `.projects[].diff.totalMonthlyCost` - show the difference in monthly cost for the existing infra and tf plan
        * `.diffTotalHourlyCost` (for Infracost version 0.9.12 or newer) or `[.projects[].diff.totalMonthlyCost | select (.!=null) | tonumber] | add` (for Infracost older than 0.9.12)

4. **Docker usage**. In `docker build` or `docker run` command:
    * You need to provide [Infracost API key](https://www.infracost.io/docs/integrations/environment_variables/#infracost_api_key) via `-e INFRACOST_API_KEY=<your token>`. By default, it is saved in `~/.config/infracost/credentials.yml`
    * Set `-e INFRACOST_SKIP_UPDATE_CHECK=true` to [skip the Infracost update check](https://www.infracost.io/docs/integrations/environment_variables/#infracost_skip_update_check) if you use this hook as part of your CI/CD pipeline.

### tofu_docs

1. `tofu_docs` and `tofu_docs_without_aggregate_type_defaults` will insert/update documentation generated by [terraform-docs](https://github.com/terraform-docs/terraform-docs) framed by markers:

    ```txt
    <!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->

    <!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
    ```

    if they are present in `README.md`.

2. It is possible to pass additional arguments to shell scripts when using `tofu_docs` and `tofu_docs_without_aggregate_type_defaults`.

3. It is possible to automatically:
    * create a documentation file
    * extend existing documentation file by appending markers to the end of the file (see item 1 above)
    * use different filename for the documentation (default is `README.md`)
    * use the same insertion markers as `terraform-docs` by default. It will be default in `v2.0`.  
      To migrate to `terraform-docs` insertion markers, run in repo root:

      ```bash
      grep -rl 'BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK' . | xargs sed -i 's/BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK/BEGIN_TF_DOCS/g'
      grep -rl 'END OF PRE-COMMIT-OPENTOFU DOCS HOOK' . | xargs sed -i 's/END OF PRE-COMMIT-OPENTOFU DOCS HOOK/END_TF_DOCS/g'
      ```

    ```yaml
    - id: tofu_docs
      args:
        - --hook-config=--path-to-file=README.md        # Valid UNIX path. I.e. ../TFDOC.md or docs/README.md etc.
        - --hook-config=--add-to-existing-file=true     # Boolean. true or false
        - --hook-config=--create-file-if-not-exist=true # Boolean. true or false
        - --hook-config=--use-standard-markers=true     # Boolean. Defaults in v1.x to false. Set to true for compatibility with terraform-docs
    ```

4. You can provide [any configuration available in `tofu-docs`](https://terraform-docs.io/user-guide/configuration/) as an argument to `tofu_doc` hook, for example:

    ```yaml
    - id: tofu_docs
      args:
        - --args=--config=.terraform-docs.yml
    ```

    > **Warning**: Avoid use `recursive.enabled: true` in config file, that can cause unexpected behavior.

5. If you need some exotic settings, it can be done too. I.e. this one generates HCL files:

    ```yaml
    - id: tofu_docs
      args:
        - tfvars hcl --output-file terraform.tfvars.model .
    ```

### tofu_docs_replace (deprecated)

**DEPRECATED**. Will be merged in [`tofu_docs`](#tofu_docs).

`tofu_docs_replace` replaces the entire `README.md` rather than doing string replacement between markers. Put your additional documentation at the top of your `main.tf` for it to be pulled in.

To replicate functionality in `tofu_docs` hook:

1. Create `.terraform-docs.yml` in the repo root with the following content:

    ```yaml
    formatter: "markdown"

    output:
    file: "README.md"
    mode: replace
    template: |-
        {{/** End of file fixer */}}
    ```

2. Replace `tofu_docs_replace` hook config in `.pre-commit-config.yaml` with:

    ```yaml
    - id: tofu_docs
    args:
        - --args=--config=.terraform-docs.yml
    ```

### tofu_fmt

1. `tofu_fmt` supports custom arguments so you can pass [supported flags](https://www.terraform.io/docs/cli/commands/fmt.html#usage). Eg:

    ```yaml
     - id: tofu_fmt
       args:
         - --args=-no-color
         - --args=-diff
         - --args=-write=false
    ```

### tofu_providers_lock

> **Note**: The hook requires OpenTofu 1.6.0 or later.

> **Note**: The hook can invoke `tofu providers lock` that can be really slow and requires fetching metadata from remote OpenTofu registries - not all of that metadata is currently being cached by OpenTofu.

> <details><summary><b>Note</b>: Read this if you used this hook before v1.80.0 | Planned breaking changes in v2.0</summary>
> We introduced '--mode' flag for this hook. If you'd like to continue using this hook as before, please:
>
> * Specify `--hook-config=--mode=always-regenerate-lockfile` in `args:`
> * Before `tofu_providers_lock`, add `tofu_validate` hook with `--hook-config=--retry-once-with-cleanup=true`
> * Move `--tf-init-args=` to `tofu_validate` hook
>
> In the end, you should get config like this:
>
> ```yaml
> - id: tofu_validate
>   args:
>     - --hook-config=--retry-once-with-cleanup=true
>     # - --tf-init-args=-upgrade
>
> - id: tofu_providers_lock
>   args:
>   - --hook-config=--mode=always-regenerate-lockfile
> ```
>
> Why? When v2.x will be introduced - the default mode will be changed, probably, to `only-check-is-current-lockfile-cross-platform`.
>
> You can check available modes for hook below.
> </details>


1. The hook can work in a few different modes: `only-check-is-current-lockfile-cross-platform` with and without [tofu_validate hook](#tofu_validate) and `always-regenerate-lockfile` - only with tofu_validate hook.

    * `only-check-is-current-lockfile-cross-platform` without tofu_validate - only checks that lockfile has all required SHAs for all providers already added to lockfile.

        ```yaml
        - id: tofu_providers_lock
          args:
          - --hook-config=--mode=only-check-is-current-lockfile-cross-platform
        ```

    * `only-check-is-current-lockfile-cross-platform` with [tofu_validate hook](#tofu_validate) - make up-to-date lockfile by adding/removing providers and only then check that lockfile has all required SHAs.

        > **Note**: Next `tofu_validate` flag requires additional dependency to be installed: `jq`. Also, it could run another slow and time consuming command - `tofu init`

        ```yaml
        - id: tofu_validate
          args:
            - --hook-config=--retry-once-with-cleanup=true

        - id: tofu_providers_lock
          args:
          - --hook-config=--mode=only-check-is-current-lockfile-cross-platform
        ```

    * `always-regenerate-lockfile` only with [tofu_validate hook](#tofu_validate) - regenerate lockfile from scratch. Can be useful for upgrading providers in lockfile to latest versions

        ```yaml
        - id: tofu_validate
          args:
            - --hook-config=--retry-once-with-cleanup=true
            - --tf-init-args=-upgrade

        - id: tofu_providers_lock
          args:
          - --hook-config=--mode=always-regenerate-lockfile
        ```


3. `tofu_providers_lock` supports custom arguments:

    ```yaml
     - id: tofu_providers_lock
       args:
          - --args=-platform=windows_amd64
          - --args=-platform=darwin_amd64
    ```

4. It may happen that OpenTofu working directory (`.terraform`) already exists but not in the best condition (eg, not initialized modules, wrong version of OpenTofu, etc.). To solve this problem, you can find and delete all `.terraform` directories in your repository:

    ```bash
    echo "
    function rm_tofu {
        find . \( -iname ".terraform*" ! -iname ".terraform-docs*" \) -print0 | xargs -0 rm -r
    }
    " >>~/.bashrc

    # Reload shell and use `rm_tofu` command in the repo root
    ```

    `tofu_providers_lock` hook will try to reinitialize directories before running the `tofu providers lock` command.

5. `tofu_providers_lock` support passing custom arguments to its `tofu init`:

    > **Warning** - DEPRECATION NOTICE: This is available only in `no-mode` mode, which will be removed in v2.0. Please provide this keys to [`tofu_validate`](#tofu_validate) hook, which, to take effect, should be called before `tofu_providers_lock`

    ```yaml
    - id: tofu_providers_lock
      args:
        - --tf-init-args=-upgrade
    ```


### tofu_tflint

1. `tofu_tflint` supports custom arguments so you can enable module inspection, enable / disable rules, etc.

    Example:

    ```yaml
    - id: tofu_tflint
      args:
        - --args=--module
        - --args=--enable-rule=terraform_documented_variables
    ```

2. When you have multiple directories and want to run `tflint` in all of them and share a single config file, it is impractical to hard-code the path to the `.tflint.hcl` file. The solution is to use the `__GIT_WORKING_DIR__` placeholder which will be replaced by `tofu_tflint` hooks with the Git working directory (repo root) at run time. For example:

    ```yaml
    - id: tofu_tflint
      args:
        - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
    ```

3. By default, pre-commit-opentofu performs directory switching into the OpenTofu modules for you. If you want to delgate the directory changing to the binary - this will allow tflint to determine the full paths for error/warning messages, rather than just module relative paths. *Note: this requires `tflint>=0.44.0`.* For example:

    ```yaml
    - id: tofu_tflint
          args:
            - --hook-config=--delegate-chdir
    ```


### tofu_tfsec (deprecated)

**DEPRECATED**. [tfsec was replaced by trivy](https://github.com/aquasecurity/tfsec/discussions/1994), so please use [`tofu_trivy`](#tofu_trivy).

1. `tofu_tfsec` will consume modified files that pre-commit
    passes to it, so you can perform whitelisting of directories
    or files to run against via [files](https://pre-commit.com/#config-files)
    pre-commit flag

    Example:

    ```yaml
    - id: tofu_tfsec
      files: ^prd-infra/
    ```

    The above will tell pre-commit to pass down files from the `prd-infra/` folder
    only such that the underlying `tfsec` tool can run against changed files in this
    directory, ignoring any other folders at the root level

2. To ignore specific warnings, follow the convention from the
[documentation](https://github.com/aquasecurity/tfsec#ignoring-warnings).

    Example:

    ```hcl
    resource "aws_security_group_rule" "my-rule" {
        type = "ingress"
        cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS006
    }
    ```

3. `tofu_tfsec` supports custom arguments, so you can pass supported `--no-color` or `--format` (output), `-e` (exclude checks) flags:

    ```yaml
     - id: tofu_tfsec
       args:
         - >
           --args=--format json
           --no-color
           -e aws-s3-enable-bucket-logging,aws-s3-specify-public-access-block
    ```

4. When you have multiple directories and want to run `tfsec` in all of them and share a single config file - use the `__GIT_WORKING_DIR__` placeholder. It will be replaced by `tofu_tfsec` hooks with Git working directory (repo root) at run time. For example:

    ```yaml
    - id: tofu_tfsec
      args:
        - --args=--config-file=__GIT_WORKING_DIR__/.tfsec.json
    ```

    Otherwise, will be used files that located in sub-folders:

    ```yaml
    - id: tofu_tfsec
      args:
        - --args=--config-file=.tfsec.json
    ```

### tofu_trivy

1. `tofu_trivy` will consume modified files that pre-commit
    passes to it, so you can perform whitelisting of directories
    or files to run against via [files](https://pre-commit.com/#config-files)
    pre-commit flag

    Example:

    ```yaml
    - id: tofu_trivy
      files: ^prd-infra/
    ```

    The above will tell pre-commit to pass down files from the `prd-infra/` folder
    only such that the underlying `trivy` tool can run against changed files in this
    directory, ignoring any other folders at the root level

2. To ignore specific warnings, follow the convention from the
[documentation](https://aquasecurity.github.io/trivy/latest/docs/configuration/filtering/).

    Example:

    ```hcl
    #trivy:ignore:AVD-AWS-0107
    #trivy:ignore:AVD-AWS-0124
    resource "aws_security_group_rule" "my-rule" {
        type = "ingress"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ```

3. `tofu_trivy` supports custom arguments, so you can pass supported `--format` (output), `--skip-dirs` (exclude directories) and other flags:

    ```yaml
     - id: tofu_trivy
       args:
         - >
           --args=--format json
           --skip-dirs="**/.terragrunt-cache"
    ```

### tofu_validate

1. `tofu_validate` supports custom arguments so you can pass supported `-no-color` or `-json` flags:

    ```yaml
     - id: tofu_validate
       args:
         - --args=-json
         - --args=-no-color
    ```

2. `tofu_validate` also supports passing custom arguments to its `tofu init`:

    ```yaml
    - id: tofu_validate
      args:
        - --tf-init-args=-upgrade
        - --tf-init-args=-lockfile=readonly
    ```

3. It may happen that OpenTofu working directory (`.terraform`) already exists but not in the best condition (eg, not initialized modules, wrong version of OpenTofu, etc.). To solve this problem, you can delete broken `.terraform` directories in your repository:

    **Option 1**

    ```yaml
    - id: tofu_validate
      args:
        - --hook-config=--retry-once-with-cleanup=true     # Boolean. true or false
    ```

    > **Note**: The flag requires additional dependency to be installed: `jq`.

    > **Note**: Reinit can be very slow and require downloading data from remote OpenTofu registries, and not all of that downloaded data or meta-data is currently being cached by OpenTofu.

    When `--retry-once-with-cleanup=true`, in each failed directory the cached modules and providers from the `.terraform` directory will be deleted, before retrying once more. To avoid unnecessary deletion of this directory, the cleanup and retry will only happen if OpenTofu produces any of the following error messages:

    * "Missing or corrupted provider plugins"
    * "Module source has changed"
    * "Module version requirements have changed"
    * "Module not installed"
    * "Could not load plugin"

    **Warning**: When using `--retry-once-with-cleanup=true`, problematic `.terraform/modules/` and `.terraform/providers/` directories will be recursively deleted without prompting for consent. Other files and directories will not be affected, such as the `.terraform/environment` file.

    **Option 2**

    An alternative solution is to find and delete all `.terraform` directories in your repository:

    ```bash
    echo "
    function rm_tofu {
        find . \( -iname ".terraform*" ! -iname ".terraform-docs*" \) -print0 | xargs -0 rm -r
    }
    " >>~/.bashrc

    # Reload shell and use `rm_tofu` command in the repo root
    ```

   `tofu_validate` hook will try to reinitialize them before running the `tofu validate` command.

    **Warning**: If you use OpenTofu workspaces, DO NOT use this option ([details](https://github.com/tofuutils/pre-commit-opentofu/issues/203#issuecomment-918791847)). Consider the first option, or wait for [`force-init`](https://github.com/tofuutils/pre-commit-opentofu/issues/224) option implementation.

4. `tofu_validate` in a repo with OpenTofu module, written using OpenTofu 1.6.0+ and which uses provider `configuration_aliases` ([Provider Aliases Within Modules](https://www.terraform.io/language/modules/develop/providers#provider-aliases-within-modules)), errors out.

   When running the hook against OpenTofu code where you have provider `configuration_aliases` defined in a `required_providers` configuration block, OpenTofu will throw an error like:

   > Error: Provider configuration not present
   > To work with `<resource>` its original provider configuration at provider `["registry.terraform.io/hashicorp/aws"].<provider_alias>` is required, but it has been removed. This occurs when a provider configuration is removed while
   > objects created by that provider still exist in the state. Re-add the provider configuration to destroy `<resource>`, after which you can remove the provider configuration again.

   This is a [known issue](https://github.com/hashicorp/terraform/issues/28490) with OpenTofu and how providers are initialized in OpenTofu 1.6.0 and later. To work around this you can add an `exclude` parameter to the configuration of `tofu_validate` hook like this:

   ```yaml
   - id: tofu_validate
     exclude: '^[^/]+$'
   ```

   This will exclude the root directory from being processed by this hook. Then add a subdirectory like "examples" or "tests" and put an example implementation in place that defines the providers with the proper aliases, and this will give you validation of your module through the example. If instead you are using this with multiple modules in one repository you'll want to set the path prefix in the regular expression, such as `exclude: modules/offendingmodule/[^/]+$`.

   Alternately, you can use [terraform-config-inspect](https://github.com/hashicorp/terraform-config-inspect) and use a variant of [this script](https://github.com/bendrucker/terraform-configuration-aliases-action/blob/main/providers.sh) to generate a providers file at runtime:

   ```bash
   terraform-config-inspect --json . | jq -r '
     [.required_providers[].aliases]
     | flatten
     | del(.[] | select(. == null))
     | reduce .[] as $entry (
       {};
       .provider[$entry.name] //= [] | .provider[$entry.name] += [{"alias": $entry.alias}]
     )
   ' | tee aliased-providers.tf.json
   ```

   Save it as `.generate-providers.sh` in the root of your repository and add a `pre-commit` hook to run it before all other hooks, like so:

   ```yaml
   - repos:
     - repo: local
       hooks:
         - id: generate-tofu-providers
            name: generate-tofu-providers
            require_serial: true
            entry: .generate-providers.sh
            language: script
            files: \.tf(vars)?$
            pass_filenames: false

     - repo: https://github.com/pre-commit/pre-commit-hooks
   [...]
   ```

   > Note: The latter method will leave an "aliased-providers.tf.json" file in your repo. You will either want to automate a way to clean this up or add it to your `.gitignore` or both.

### tofu_wrapper_module_for_each

`tofu_wrapper_module_for_each` generates module wrappers for OpenTofu modules (useful for Terragrunt where `for_each` is not supported). When using this hook without arguments it will create wrappers for the root module and all modules available in "modules" directory.

You may want to customize some of the options:

1. `--module-dir=...` - Specify a single directory to process. Values: "." (means just root module), "modules/iam-user" (a single module), or empty (means include all submodules found in "modules/*").
2. `--module-repo-org=...` - Module repository organization (e.g. "terraform-aws-modules").
3. `--module-repo-shortname=...` - Short name of the repository (e.g. "s3-bucket").
4. `--module-repo-provider=...` - Name of the repository provider (e.g. "aws" or "google").

Sample configuration:

```yaml
- id: tofu_wrapper_module_for_each
  args:
    - --args=--module-dir=.   # Process only root module
    - --args=--dry-run        # No files will be created/updated
    - --args=--verbose        # Verbose output
```

**If you use hook inside Docker:**  
The `tofu_wrapper_module_for_each` hook attempts to determine the module's short name to be inserted into the generated `README.md` files for the `source` URLs. Since the container uses a bind mount at a static location, it can cause this short name to be incorrect.  
If the generated name is incorrect, set them by providing the `module-repo-shortname` option to the hook:

```yaml
- id: tofu_wrapper_module_for_each
  args:
    - '--args=--module-repo-shortname=ec2-instance'
```

### terrascan

1. `terrascan` supports custom arguments so you can pass supported flags like `--non-recursive` and `--policy-type` to disable recursive inspection and set the policy type respectively:

    ```yaml
    - id: terrascan
      args:
        - --args=--non-recursive # avoids scan errors on subdirectories without OpenTofu config files
        - --args=--policy-type=azure
    ```

    See the `terrascan run -h` command line help for available options.

2. Use the `--args=--verbose` parameter to see the rule ID in the scanning output. Useful to skip validations.
3. Use `--skip-rules="ruleID1,ruleID2"` parameter to skip one or more rules globally while scanning (e.g.: `--args=--skip-rules="ruleID1,ruleID2"`).
4. Use the syntax `#ts:skip=RuleID optional_comment` inside a resource to skip the rule for that resource.

### tfupdate

1. Out of the box `tfupdate` will pin the OpenTofu version:

    ```yaml
    - id: tfupdate
      name: Autoupdate OpenTofu versions
    ```

2. If you'd like to pin providers, etc., use custom arguments, i.e `provider=PROVIDER_NAME`:

    ```yaml
    - id: tfupdate
      name: Autoupdate AWS provider versions
      args:
        - --args=provider aws # Will be pined to latest version

    - id: tfupdate
      name: Autoupdate Helm provider versions
      args:
        - --args=provider helm
        - --args=--version 2.5.0 # Will be pined to specified version
    ```

Check [`tfupdate` usage instructions](https://github.com/minamijoyo/tfupdate#usage) for other available options and usage examples.  
No need to pass `--recursive .` as it is added automatically.

## Docker Usage

### File Permissions

A mismatch between the Docker container's user and the local repository file ownership can cause permission issues in the repository where `pre-commit` is run.  The container runs as the `root` user by default, and uses a `tools/entrypoint.sh` script to assume a user ID and group ID if specified by the environment variable `USERID`.

The [recommended command](#4-run) to run the Docker container is:

```bash
TAG=latest
docker run -e "USERID=$(id -u):$(id -g)" -v $(pwd):/lint -w /lint tofuutils/pre-commit-opentofu:$TAG run -a
```

which uses your current session's user ID and group ID to set the variable in the run command.  Without this setting, you may find files and directories owned by `root` in your local repository.

If the local repository is using a different user or group for permissions, you can modify the `USERID` to the user ID and group ID needed.  **Do not use the username or groupname in the environment variable, as it has no meaning in the container.**  You can get the current directory's owner user ID and group ID from the 3rd (user) and 4th (group) columns in `ls` output:

```bash
$ ls -aldn .
drwxr-xr-x 9 1000 1000 4096 Sep  1 16:23 .
```

### Download OpenTofu modules from private GitHub repositories

If you use a private Git repository as your OpenTofu module source, you are required to authenticate to GitHub using a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

When running pre-commit on Docker, both locally or on CI, you need to configure the [~/.netrc](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html) file, which contains login and initialization information used by the auto-login process.

This can be achieved by firstly creating the `~/.netrc` file including your `GITHUB_PAT` and `GITHUB_SERVER_HOSTNAME`

```bash
# set GH values (replace with your own values)
GITHUB_PAT=ghp_bl481aBlabl481aBla
GITHUB_SERVER_HOSTNAME=github.com

# create .netrc file
echo -e "machine $GITHUB_SERVER_HOSTNAME\n\tlogin $GITHUB_PAT" >> ~/.netrc
```

The `~/.netrc` file will look similar to the following:

```
machine github.com
  login ghp_bl481aBlabl481aBla
```

> **Note**: The value of `GITHUB_SERVER_HOSTNAME` can also refer to a GitHub Enterprise server (i.e. `github.my-enterprise.com`).

Finally, you can execute `docker run` with an additional volume mount so that the `~/.netrc` is accessible within the container

```bash
# run pre-commit-opentofu with docker
# adding volume for .netrc file
# .netrc needs to be in /root/ dir
docker run --rm -e "USERID=$(id -u):$(id -g)" -v ~/.netrc:/root/.netrc -v $(pwd):/lint -w /lint tofuutils/pre-commit-opentofu:latest run -a
```

## Authors

This repository is managed by [Alexander Sharov](https://github.com/kvendingoldo), [Nikolay Mishin](https://github.com/Nmishin), and [Anastasiia Kozlova](https://github.com/anastasiiakozlova245) with help from these awesome contributors:

<!-- markdownlint-disable no-inline-html -->
<a href="https://github.com/tofuutils/pre-commit-opentofu/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=tofuutils/pre-commit-opentofu" />
</a>


<a href="https://star-history.com/#tofuutils/pre-commit-opentofu&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=tofuutils/pre-commit-opentofu&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=tofuutils/pre-commit-opentofu&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=tofuutils/pre-commit-opentofu&type=Date" />
  </picture>
</a>

<!-- markdownlint-enable no-inline-html -->

## License

MIT licensed. See [LICENSE](LICENSE) for full details.
