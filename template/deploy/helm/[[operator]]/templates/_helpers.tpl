{{/*
Expand the name of the chart.
*/}}
{{- define "operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-operator" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "operator.appname" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "operator.labels" -}}
helm.sh/chart: {{ include "operator.chart" . }}
{{ include "operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "operator.appname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Labels for Kubernetes objects created by helm test
*/}}
{{- define "operator.testLabels" -}}
helm.sh/test: {{ include "operator.chart" . }}
{{- end }}

{{/*
Include default resources or load resources from values if defined there.
This is done with an if block instead of the default function because we need to pass anything
retrieved from Values.resources to 'toYaml', but cannot do the same for the defaults we load.
But if we do:
  default (.Files.Get "resources/default_resources.yaml") (toYaml .Values.resources)
then (toYaml .Values.resources) never is undefined, so the default value is effectively bypassed every time.
*/}}
{{- define "operator.resources" -}}
{{- if .Values.resources }}
{{- .Values.resources | toYaml }}
{{- else }}
{{- .Files.Get "resources/default_resources.yaml" }}
{{- end }}
{{- end }}

{{/*
Similar to operator.resources, but meant to be used for setting resources on daemonsets.
As some operators have both, we wanted to be able to define different values.
See comment on `operator.resources` for more details.
*/}}
{{- define "daemonset.resources" -}}
{{- if .Values.daemonsetResources }}
{{- .Values.resources | toYaml }}
{{- else }}
{{- .Files.Get "resources/default_daemonset_resources.yaml" }}
{{- end }}
{{- end }}