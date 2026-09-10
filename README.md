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
The word lists are **not** templated: each repository carries its own `typos.toml`, hand-maintained.

That split is forced by the tool. typos has no layered configuration yet ([crate-ci/typos#193](https://github.com/crate-ci/typos/issues/193)).
Keeping the word lists local also means adding a word is a single PR in a single repository, rather than a PR here plus a sync to every managed repository.

### The core config

As convention, new repositories should start from this block and add only what they actually need.

```toml
[files]
# Bare `typos` skips hidden directories, but prek passes explicit paths and so does
# check them. Turn it off so a local run and the hook agree; without it, .github/
# and .readme/ are invisible locally but not to CI.
ignore-hidden = false

extend-exclude = [
    # Required once ignore-hidden is off, or typos walks .git/objects.
    ".git/",
    # Generated by `make regenerate-nix` (crate2nix).
    "Cargo.nix",
    "crate-hashes.json",
    # Generated by `make crds`. See "check each string once" below.
    "extra/crds.yaml",
    "deploy/helm/*/crds/crds.yaml",
    # Diagram sources; the payload is base64 and produces only noise.
    "*.drawio",
    "*.drawio.svg",
]

[default]
# typos has no native suppression directive (crate-ci/typos#316), so these regexes
# provide one. They cover `#`, `//`, `<!-- -->`, `;`, `/* */` and Jinja `{# #}`
# comments. Both failure modes are safe: an unterminated `:off` suppresses nothing
# rather than swallowing the rest of the file, and `disable-line` only matches when
# the marker ends the line, so trailing text defeats it instead of widening it.
extend-ignore-re = [
    "(?Rm)^.*(#|//|<!--|;|/\\*)\\s*spellchecker:disable-line\\s*(-->|#\\}|\\*/)?\\s*$",
    "(#|//|<!--|;|/\\*)\\s*spellchecker:ignore-next-line\\s*(-->|#\\}|\\*/)?\\s*\\n.*",
    "(?s)(#|//|<!--|;|/\\*|\")\\s*spellchecker:off\\s*(-->|#\\}|\\*/|\")?.*?(#|//|<!--|;|/\\*|\")\\s*spellchecker:on\\s*(-->|#\\}|\\*/|\")?",
]

[default.extend-words]
# Azure Kubernetes Service. Appears in the README footer and as the runner platform
# in tests/interu.yaml. A single lowercase entry covers every casing.
aks = "aks"
```

`aks` is the only word that is genuinely universal.
Everything else measured across the operator repositories turned out to be repo-local: `aas` in opa-operator, `shs` in spark-k8s-operator, base64 fixtures in secret-operator. <!-- spellchecker:disable-line -->
Short tokens that appear in several repositories (`ot`, `fo`) do so for unrelated reasons and belong in the repository that has them, not here. <!-- spellchecker:disable-line -->

### Check each string once

`extra/crds.yaml` is excluded on purpose.
Its content is generated: partly Kubernetes' own schema documentation, which is not ours to correct, and partly doc comments owned by `operator-rs` or by the operator's own `crd` module — both of which are already checked at their source.
The same applies to files rendered from `template/`: a typo in `template/.readme/partials/borrowed/footer.md.j2.j2` is caught here, once, instead of in all sixteen repositories.

> [!NOTE]
> Excluding rendered content more thoroughly — everything a repository receives from `operator-templating` or `operator-rs` — is a known refinement that has not been done yet.
> The generated CRDs are the case that mattered in practice.

### Conventions

- The hook runs report-only. `args: ["--force-exclude"]`.
- Every entry in a `typos.toml` gets a one-line comment saying what the word is.
- Prefer an in-place marker over a config entry when the word is correct at one site and would still be a typo elsewhere: `spellchecker:disable-line` at the end of the line, `spellchecker:ignore-next-line` on the line above, or `spellchecker:off` / `:on` around a block.
- Licence and other verbatim third-party files are excluded, never corrected.

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
