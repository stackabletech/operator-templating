{{/*
Create a list of telemetry related env vars.
*/}}
{{- define "telemetry.envVars" -}}
{{- with .Values.telemetry }}
{{- if not .consoleLogs.enabled }}
- name: NO_CONSOLE_OUTPUT
  value: "true"
{{- end }}
{{- if .consoleLogs.level }}
- name: CONSOLE_LOG
  value: {{ .consoleLogs.level }}
{{ end }}
{{- if .rollingFileLogs.enabled }}
- name: ROLLING_LOGS_DIR
  value: /stackable/logs/{{ include "operator.appname" $ }}
{{- end }}
{{- if .rollingFileLogs.level }}
- name: FILE_LOG
  value: info
{{- end }}
{{- if .rollingFileLogs.period }}
- name: ROLLING_LOGS_PERIOD
  value: {{ .rollingFileLogs.period }}
{{- end }}
{{- if .otlpLogs.enabled }}
- name: OTLP_LOGS
  value: "true"
{{- end }}
{{- if .otlpLogs.level }}
- name: OTLP_LOG
  value: {{ .otlpLogs.level }}
{{- end }}
{{- if .otlpLogs.endpoint }}
- name: OTEL_EXPORTER_OTLP_LOGS_ENDPOINT
  value: {{ .otlpLogs.endpoint }}
{{- end }}
{{- if .otlpTraces.enabled }}
- name: OTLP_TRACES
  value: "true"
{{- end }}
{{- if .otlpTraces.level }}
- name: OTLP_TRACE
  value: {{ .otlpTraces.level }}
{{- end }}
{{- if .otlpTraces.endpoint }}
- name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
  value: {{ .otlpTraces.endpoint }}
{{- end }}
{{- end }}
{{- end }}
