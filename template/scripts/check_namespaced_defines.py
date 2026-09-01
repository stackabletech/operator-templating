"""
Fails when a Helm defined template, or a call to one, is not prefixed with the
name of the chart it lives in.

To run tests for this script:
    python3 -m unittest check_namespaced_defines.py
"""

import re
import unittest
from pathlib import Path

NAME_PATTERN = r'\b(?:define|include|template)\s+"([^"]+)"'
CHART_PATTERN = r"(?:^|/)deploy/helm/([^/]+)/templates/"


def chart_of(path):
    """The chart whose templates directory holds path, or None if it is outside one."""
    found = re.search(CHART_PATTERN, Path(path).as_posix())
    return found.group(1) if found else None


def unprefixed(text, chart):
    """The defined template names in text, and the calls to them, lacking the chart prefix."""
    names = re.findall(NAME_PATTERN, text)
    return sorted({name for name in names if not name.startswith(f"{chart}.")})


class TestCoreMethods(unittest.TestCase):
    def test_chart_of(self):
        self.assertEqual(
            chart_of("deploy/helm/trino-operator/templates/x.yaml"), "trino-operator"
        )
        # An absolute path has to give the same answer, or a manual run invents a chart name.
        self.assertEqual(
            chart_of("/tmp/wt/deploy/helm/secret-operator/templates/a/b.yaml"),
            "secret-operator",
        )
        self.assertIsNone(chart_of("deploy/helm/trino-operator/values.yaml"))
        self.assertIsNone(chart_of("README.md"))

    def test_prefixed_is_accepted(self):
        text = '{{- define "trino-operator.labels" -}}\n{{ include "trino-operator.chart" . }}\n'
        self.assertEqual(unprefixed(text, "trino-operator"), [])

    def test_unprefixed_define_is_reported(self):
        self.assertEqual(
            unprefixed('{{- define "helper.thing" -}}', "trino-operator"),
            ["helper.thing"],
        )

    def test_unprefixed_call_is_reported(self):
        # A renamed definition whose call sites did not move with it stops the chart rendering.
        text = (
            '{{ include "operator.fullname" . }}\n{{ template "operator.labels" . }}\n'
        )
        self.assertEqual(
            unprefixed(text, "trino-operator"), ["operator.fullname", "operator.labels"]
        )

    def test_keyword_must_stand_alone(self):
        # Without a word boundary any identifier ending in the keyword matches.
        self.assertEqual(
            unprefixed('{{ .Values.xinclude "bar.baz" }}', "foo-operator"), []
        )


if __name__ == "__main__":
    import sys

    if not sys.argv[1:]:
        print(f"usage: {sys.argv[0]} deploy/helm/<chart>/templates/*", file=sys.stderr)
        sys.exit(2)

    failed = False
    for path in sys.argv[1:]:
        chart = chart_of(path)
        if chart is None:
            print(
                f"{sys.argv[0]}: {path} is not inside deploy/helm/<chart>/templates/",
                file=sys.stderr,
            )
            sys.exit(2)
        names = unprefixed(Path(path).read_text(), chart)
        if names:
            failed = True
            print(
                f"{path}: defined templates and the calls to them must be prefixed with '{chart}.'"
            )
            for name in names:
                print(f"  {name}")

    sys.exit(1 if failed else 0)
