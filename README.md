# Templates for Common Files in Operator Repositories

Stackable develops and maintains a growing number of operators for open source software.

The high level structure of the repository is consistent across all repositories, which in the past has led to repetitive maintenance tasks in many repositories even for small changes.

This repository is intended to help with these changes by keeping common files as templates and offering tooling to roll these out to all repositories that are under management by this tool.

## Structure of this repository

### GitHub Actions

The definition files for GitHub actions that in turn execute the playbooks doing the actual work are kept in `.github`

### Playbook

`playbook` contains the ansible playbook which is executed to perform the needed changes.

### Templates

Everything under the top level folder `template`  is replicated to the target repositories.
The folder and file structure under `template` is considered as source structure which will be synchronized across all repositories in the following manner:

- Regular files and folders are simply copied
- Files with an extension of `.j2` will be processed as jinja2 templates and copied to the target repositories with the `.j2` extension removed. The default jinja2 variable delimiter has been replaced with `{[ }]` since a lot of the template files contain `{{  }}` and caused issues.
- File and directory names which contain `\[[product]]` will have this substituted for the value of the `product_string` variable. For example: "stackable-\[[product]]-operator.service" would become `stackable-kafka-operator.service`.

To remove files or directories that already exist in the target repositories these need to be configured in `repositories.yaml` under the `retired_files` key.

Anything that is listed here will be deleted from the target repositories.

> [!NOTE]
> Deletion is the last step that is performed, so if there is an overlap between files existing in the template folder and this setting, the files would not be rolled out, since they'd get deleted before creating the pull request.

### Configuration

All user-facing configuration is kept in `repositories.yaml`.

The actions in this repository are set up so that the playbooks are automatically executed whenever a commit is made to the `main` branch of this repository.

So in principle it is as simple as pushing any commit to `main` which will trigger a sync of everything under `template` to all target repositories.

Target repositories are configured in `repositories.yaml` in the following form:

```yaml
- name: kafka-operator
  url: stackabletech/kafka-operator.git
  product_string: kafka
  pretty_string: Kafka
```

| Field | Description |
| ----- | ----------- |
| `name` | This is only used internally to name working directories and the like. |
| `url` | The github repository for this operator. Need to be in the form of `<org>/<repo>.git`. |
| `product_string` | A lower case string to use in config files, file names and the like. Should not contain whitespaces. This can sometimes be a shortened version of the full name, for example for Open Policy Agent this would be "opa" |
| `pretty_string` | The actual name of the product, including whitespaces and proper capitalization. This is intended to be used in doc or man files or similar things. |
| `config.has_product` | Indicates that the operator manages a product. This is particularly useful to differentiate between core and product operators. *Default*: true |
| `config.run_as` | Whether to run the operator as a default Deployment, or something custom. |

These are the only variables currently being used on the playbooks, but can be extended easily as more are needed.

> [!NOTE]
> If a new variable is introduced, it needs to be added to all repository objects!

Additional settings can be found in `playbook/group_vars/all`, but these are not intended to be freely changed and should be treated with care.

## Spell checking

Every managed repository runs [typos](https://github.com/crate-ci/typos) as a prek hook.
The hook is templated in `template/.pre-commit-config.yaml.j2`.
The word lists are **not** templated: each repository has its own `typos.toml`, because typos has no layered configuration yet ([crate-ci/typos#193](https://github.com/crate-ci/typos/issues/193)).
Keeping the word lists local also means adding a word is a PR per repository instead of a templating run.
Files rendered from `template/` are checked in this repository once.

### The core config

As a convention, new repositories should start from this block and add only what they actually need.

```toml
# Configuration for typos (https://github.com/crate-ci/typos), run via the prek
# hook in .pre-commit-config.yaml.

[files]
# Bare `typos` skips hidden dirs by default, but prek passes explicit paths and
# so does check them. Turn it off so both agree.
ignore-hidden = false

extend-exclude = [
    # Ignore `.git`, which the above `ignore-hidden = false` would otherwise pull in.
    ".git/",
]

[default]
# typos has no native suppression directive
# (https://github.com/crate-ci/typos/issues/316), so these regexes provide one.
# A marker must sit in a comment: after `#`, `//` or `;` (free text may follow),
# or inside a closed `<!-- -->`, `/* */` or `{# #}` (free text may precede the
# closer). An unterminated `typos:ignore-block-start` suppresses nothing.
#
# Use one of the following when the word is correct at one place but would still be a typo elsewhere:
#
#   # typos:ignore-line        at the end of the line it applies to
#   # typos:ignore-next-line   on its own line, above the offending line
#   # typos:ignore-block-start / typos:ignore-block-end   around a block
extend-ignore-re = [
    '(?Rm)^.*?(?:(?:^|[^{])(?:#|//|;)[ \t]*typos:ignore-line\b.*|(?:<!--[ \t]*typos:ignore-line\b.*?-->|/\*[ \t]*typos:ignore-line\b.*?\*/|\{#[ \t]*typos:ignore-line\b.*?#\})[ \t]*)$',
    '(?Rm)^[ \t]*(?:(?:#|//|;)[ \t]*typos:ignore-next-line\b.*|(?:<!--[ \t]*typos:ignore-next-line\b.*?-->|/\*[ \t]*typos:ignore-next-line\b.*?\*/|\{#[ \t]*typos:ignore-next-line\b.*?#\})[ \t]*)\r?\n.*$',
    '(?ms)(?:(?:^|[^{])(?:#|//|;)[ \t]*typos:ignore-block-start\b|<!--[ \t]*typos:ignore-block-start\b[^\n]*?-->|/\*[ \t]*typos:ignore-block-start\b[^\n]*?\*/|\{#[ \t]*typos:ignore-block-start\b[^\n]*?#\}).*?(?:(?:^|[^{])(?:#|//|;)[ \t]*typos:ignore-block-end\b|<!--[ \t]*typos:ignore-block-end\b[^\n]*?-->|/\*[ \t]*typos:ignore-block-end\b[^\n]*?\*/|\{#[ \t]*typos:ignore-block-end\b[^\n]*?#\})',
]

# Before adding an entry in here, consider an in-place marker instead.
# Every entry below gets a one-line comment saying what the word is.
[default.extend-words]
# Azure Kubernetes Service
aks = "aks"
```

### Conventions

- Every entry in a `typos.toml` gets a one-line comment saying what the word is.
- Prefer an in-place marker over a config entry when the word is correct at one site and would still be a typo elsewhere

## Making changes to the template

If you want to make a change that should be rolled out to all operators, make the change in the `template` directory.
Consult the section above to learn more about the structure of the template.

### Test changes locally

1. Run the `test.sh` script. To limit the run to a single operator, add `--extra-vars "shard_repositories#['nifi-operator']"` (or your choice of operator).
   It will automatically delete and recreate a `work` directory.
2. The changes can be examined with `git status`.
   When the pull request is later merged into the `main` branch then pull requests with these changes will be created automatically.
3. Depending on the change, it makes sense to run the integration tests for all changed operators.
   If the tests are not run in this stage and if there is even just one integration test failing in the subsequential generated pull requests then the operator-templating must be adapted which creates again pull requests for all operators.
   Changes in the GitHub workflow actions cannot be tested until finally merged.

## Deploying changes

Changes are rolled out via GitHub actions.

### Authentication

Since this tool needs to authenticate itself in order to push commits it needs credentials of a user.
This is currently solved via a personal access token that needs to be provided as a repository (or org) secret with the name `GH_ACCESS_TOKEN`.

The personal access token needs to have the following permissions for this to work:

- repo
- org:read
- workflow

## Limitations

There is currently no synchronization with existing PRs on the target repositories whatsoever. A new pull request will be created for every commit made to this repository.

To update a PR that was created via this tool, it will have to be closed and necessary changes pushed here, which will result in a new PR.

> [!WARNING]
> The Helm Chart files that are rolled out by the templates in their current form do not include a ClusterRole object which may be needed for this to work with RBAC.
