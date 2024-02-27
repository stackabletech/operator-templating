#!/usr/bin/env sh
#
# Run the integration test suite for this operator.
#
# If a "tests/release.yaml" file is present, it will install the operators listed
# in the release file first. The name of the test suite in that file must be "tests".
# Since each operator test suite has different dependencies, the "tests/release.yaml"
# file is not included in this repository.
#
# Optionally you can provide a specific test suite to run and even a specific
# test name.
#
# Example 1 - run all tests of the openshift suite.
#
# ./scripts/run_tests.sh openshift
#
# Example 2 - run a specific smoke test of the openshift suite.
#
# ./scripts/run_tests.sh \
#   openshift \
#   smoke_trino-439_hive-3.1.3_opa-0.61.0_hdfs-3.3.6_zookeeper-3.8.3_s3-use-tls-true_openshift-true
#

set +e

REPO_ROOT=$(dirname $(dirname $0))
TEST_ROOT="$REPO_ROOT/tests/_work"
RELEASE_FILE="$REPO_ROOT/tests/release.yaml"
BEKU_TEST_SUITE="$1"
KUTTL_TEST="$2"

is_installed() {
	local command="$1"
	local install_url="$2"

	which "$command" >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Command [$command] not found. To install it, please see $install_url"
		exit 1
	fi
}

install_operators() {
	if [ -f "$RELEASE_FILE" ]; then
		echo "Installing operators with stackablectl version: $(stackablectl --version)"
		stackablectl release install --release-file "$RELEASE_FILE" tests
	else
		echo "No tests/release.yaml found, skipping operator installation"
	fi
}

expand_test_suite() {
	# Expand the tests
	echo "Running beku version: $(beku --version)"
	if [ -z "$BEKU_TEST_SUITE" ]; then
		echo "No test suite specified, expanding all tests"
		beku
	else
		echo "Expanding test suite: $BEKU_TEST_SUITE"
		beku --suite "$BEKU_TEST_SUITE"
	fi
}

run_tests() {
	echo "Running kuttl version: $(kubectl kuttl --version)"

	cd $TEST_ROOT

	if [ -z "$BEKU_TEST_SUITE" ]; then
		echo "No test specified, running all tests"
		kubectl kuttl test
	else
		echo "Running test: $KUTTL_TEST"
		kubectl kuttl test --test "$KUTTL_TEST"
	fi

	cd -
}

main() {
	is_installed beku "https://github.com/stackabletech/beku.py"
	is_installed stackablectl "https://github.com/stackabletech/stackable-cockpit/blob/main/rust/stackablectl/README.md"
	is_installed kubectl "https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
	is_installed kubectl-kuttl "https://kuttl.dev/"

	expand_test_suite
	install_operators
	run_tests
}

main
