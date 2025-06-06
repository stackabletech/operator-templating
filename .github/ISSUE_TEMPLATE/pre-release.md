---
name: Pre-Release Updates
about: |
  This template can be used to track the update of various dependencies and
  tooling in this repository as well as all downstream product operators leading
  up to the next Stackable release
title: "chore: Pre-release updates for Stackable Release YY.M.X"
labels: ['epic']
assignees: ''
---

<!--
    DO NOT REMOVE THIS COMMENT. It is intended for people who might copy/paste from the previous release issue.
    This was created by an issue template: https://github.com/stackabletech/operator-templating/issues/new/choose.
-->

<!--
    Replace 'TRACKING_ISSUE' with the applicable release tracking issue number.
-->

Part of <https://github.com/stackabletech/issues/TRACKING_ISSUE>

## Update pre-commit Workflow

> [!NOTE]
> The pre-commit config and workflows need to be kept up-to-date to ensure
> usage of recent tooling versions. This requires some manual work in this
> repository.

- [ ] Update `python-version` in local and templated `pr_pre-commit.yml` workflow
- [ ] Update hook refs in local and templated `.pre-commit-config.yaml` file
- [ ] Update Hadolint version in the `config/versions.yaml` file

## Update Rust Toolchain

> [!NOTE]
> During a Stackable release we need to ensure that every product operator uses
> the latest Rust toolchain (used by us). To keep the toolchain in sync across
> all our operators, we update the version centrally in this repository.

### Tasks

- [ ] Run `niv update` and test via `make run-dev`
- [ ] Update Rust toolchain in the `config/versions.yaml` file.
- [ ] Update Rust toolchain in  UBI9 and stackable-base images
- [ ] Update cargo-cyclonedx and cargo-auditable in UBI9 and stackable-base images
- [ ] Generate downstream PRs using the ["Generate Downstream PRs"](https://github.com/stackabletech/operator-templating/actions/workflows/generate_prs.yml) action.
- [ ] [Search for PRs](https://github.com/search?q=org%3Astackabletech%20sort%3Aupdated-desc%20is%3Apr%20is%3Aopen%20Update%20templated%20files&type=pullrequests) and add them to the list below.
- [ ] Merge downstream PRs, see below for more details.

### Downstream PRs

> ![!NOTE]
> Replace the items in the task lists below with the applicable Pull Requests.

<!--
    The following list was generated by:

    yq '.repositories[].name' config/repositories.yaml \
    | sort \
    | xargs -I {} echo "- [ ] _PR for {}_"
-->

- [ ] _PR for ubi9-rust-builder image_
- [ ] _PR for stackable-base image_
- [ ] _PR for airflow-operator_
- [ ] _PR for commons-operator_
- [ ] _PR for druid-operator_
- [ ] _PR for hbase-operator_
- [ ] _PR for hdfs-operator_
- [ ] _PR for hive-operator_
- [ ] _PR for kafka-operator_
- [ ] _PR for listener-operator_
- [ ] _PR for nifi-operator_
- [ ] _PR for opa-operator_
- [ ] _PR for opensearch-operator_
- [ ] _PR for secret-operator_
- [ ] _PR for spark-k8s-operator_
- [ ] _PR for superset-operator_
- [ ] _PR for trino-operator_
- [ ] _PR for zookeeper-operator_
