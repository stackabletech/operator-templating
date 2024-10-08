---
name: Pre-Release Updates
about: |
  This template can be used to track the update of various dependencies and
  tooling in this repository as well as all downstream product operators leading
  up to the next Stackable release
title: "chore: Pre-release updates"
labels: ['epic']
assignees: ''
---

<!--
    DO NOT REMOVE THIS COMMENT. It is intended for people who might copy/paste from the previous release issue.
    This was created by an issue template: https://github.com/stackabletech/operator-templating/issues/new/choose.
-->

## Pre-Release Updates for Stackable Release XX.(X)X

<!--
    Replace 'TRACKING_ISSUE' with the applicable release tracking issue number.
-->

Part of <https://github.com/stackabletech/issues/TRACKING_ISSUE>

### Update pre-commit Workflow

> [!NOTE]
> The pre-commit config and workflows need to be kept up-to-date to ensure
> usage of recent tooling versions. This requires some manual work in this
> repository.

```[tasklist]
### Tasks
- [ ] Update `python-version` in local and templated `pr_pre-commit.yml` workflow
- [ ] Update hook refs in local and templated `.pre-commit-config.yaml` file
- [ ] Update Hadolint version in the `config/versions.yaml` file
```

### Update Rust Toolchain

> [!NOTE]
> During a Stackable release we need to ensure that every product operator uses
> the latest Rust toolchain (used by us). To keep the toolchain in sync across
> all our operators, we update the version centrally in this repository.

```[tasklist]
### Tasks in this Repository
- [ ] Update Rust toolchain in the `config/versions.yaml` file.
- [ ] Generate downstream PRs using the ["Generate Downstream PRs"](https://github.com/stackabletech/operator-templating/actions/workflows/generate_prs.yml) action.
- [ ] Merge downstream PRs, see below for more details.
```

Replace the items in the task lists below with the applicable Pull Requests

<!--
    The following list was generated by:

    yq '.repositories[].name' config/repositories.yaml \
    | sort \
    | xargs -I {} echo "- [ ] https://github.com/stackabletech/{}/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files"
-->

```[tasklist]
### Tasks in Downstream Operator Repositories
- [ ] https://github.com/stackabletech/airflow-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/commons-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/druid-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/edc-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/hbase-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/hdfs-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/hello-world-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/hive-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/kafka-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/listener-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/nifi-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/opa-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/secret-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/spark-k8s-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/superset-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/trino-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files
- [ ] https://github.com/stackabletech/zookeeper-operator/pulls?q=sort:updated-desc+is:pr+is:open+Update+templated+files

```
