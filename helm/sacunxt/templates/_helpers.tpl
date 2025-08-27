{{/*
Expand the name of the chart.
*/}}
{{- define "sacunxt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sacunxt.fullname" -}}
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
{{- define "sacunxt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sacunxt.labels" -}}
helm.sh/chart: {{ include "sacunxt.chart" . }}
{{ include "sacunxt.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sacunxt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sacunxt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sacunxt.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sacunxt.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common environment variables for all services
*/}}
{{- define "sacunxt.commonEnv" -}}
- name: REDIS_HOST
  value: {{ include "sacunxt.redis.host" . }}
- name: REDIS_PORT
  value: {{ include "sacunxt.redis.port" . | quote }}
- name: DB_HOST
  value: {{ include "sacunxt.postgresql.host" . }}
- name: DB_PORT
  value: {{ include "sacunxt.postgresql.port" . | quote }}
- name: DB_USER
  value: {{ .Values.postgresql.auth.username }}
- name: DB_PASSWORD
  value: {{ .Values.postgresql.auth.password }}
- name: CONSUMER_CLUSTER
  value: {{ include "sacunxt.kafka.brokers" . }}
- name: PRODUCER_CLUSTER
  value: {{ include "sacunxt.kafka.brokers" . }}
{{- with .Values.extraEnvVars }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "sacunxt.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- if .Values.postgresql.fullnameOverride }}
{{- .Values.postgresql.fullnameOverride }}
{{- else }}
{{- printf "%s-postgresql" (include "sacunxt.fullname" .) }}
{{- end }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "sacunxt.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.service.ports.postgresql }}
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "sacunxt.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- if .Values.redis.fullnameOverride }}
{{- printf "%s-master" .Values.redis.fullnameOverride }}
{{- else }}
{{- printf "%s-redis-master" (include "sacunxt.fullname" .) }}
{{- end }}
{{- else }}
{{- .Values.externalRedis.host }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "sacunxt.redis.port" -}}
{{- if .Values.redis.enabled }}
{{- .Values.redis.service.ports.redis }}
{{- else }}
{{- .Values.externalRedis.port }}
{{- end }}
{{- end }}

{{/*
Kafka brokers
*/}}
{{- define "sacunxt.kafka.brokers" -}}
{{- if .Values.kafka.enabled }}
{{- if .Values.kafka.fullnameOverride }}
{{- printf "%s:9092" .Values.kafka.fullnameOverride }}
{{- else }}
{{- printf "%s-kafka:9092" (include "sacunxt.fullname" .) }}
{{- end }}
{{- else }}
{{- .Values.externalKafka.brokers }}
{{- end }}
{{- end }}

{{/*
Create image pull secrets
*/}}
{{- define "sacunxt.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if .Values.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create image registry URL
*/}}
{{- define "sacunxt.imageRegistry" -}}
{{- if .Values.global.imageRegistry }}
{{- .Values.global.imageRegistry }}
{{- else }}
{{- "your-registry.example.com" }}
{{- end }}
{{- end }}

{{/*
Create full image name for a service
*/}}
{{- define "sacunxt.image" -}}
{{- $registry := include "sacunxt.imageRegistry" . }}
{{- $repository := .repository }}
{{- $tag := .tag | default "latest" }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Common resource limits and requests
*/}}
{{- define "sacunxt.resources" -}}
{{- if .resources }}
resources:
{{ toYaml .resources | indent 2 }}
{{- else }}
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
{{- end }}
{{- end }}

{{/*
Service selector labels for specific service
*/}}
{{- define "sacunxt.service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sacunxt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Service labels for specific service
*/}}
{{- define "sacunxt.service.labels" -}}
{{ include "sacunxt.labels" . }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Common security context
*/}}
{{- define "sacunxt.securityContext" -}}
{{- if .Values.securityContext }}
securityContext:
{{ toYaml .Values.securityContext | indent 2 }}
{{- else }}
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
{{- end }}
{{- end }}

{{/*
Common pod security context
*/}}
{{- define "sacunxt.podSecurityContext" -}}
{{- if .Values.podSecurityContext }}
securityContext:
{{ toYaml .Values.podSecurityContext | indent 2 }}
{{- else }}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end }}
{{- end }}

{{/*
Common node selector
*/}}
{{- define "sacunxt.nodeSelector" -}}
{{- if .Values.nodeSelector }}
nodeSelector:
{{ toYaml .Values.nodeSelector | indent 2 }}
{{- end }}
{{- end }}

{{/*
Common tolerations
*/}}
{{- define "sacunxt.tolerations" -}}
{{- if .Values.tolerations }}
tolerations:
{{ toYaml .Values.tolerations | indent 2 }}
{{- end }}
{{- end }}

{{/*
Common affinity
*/}}
{{- define "sacunxt.affinity" -}}
{{- if .Values.affinity }}
affinity:
{{ toYaml .Values.affinity | indent 2 }}
{{- end }}
{{- end }}

{{/*
Storage class name
*/}}
{{- define "sacunxt.storageClass" -}}
{{- if .Values.global.storageClass }}
{{- .Values.global.storageClass }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}

{{/*
Check if service is enabled
*/}}
{{- define "sacunxt.service.enabled" -}}
{{- if hasKey . "enabled" }}
{{- .enabled }}
{{- else }}
{{- true }}
{{- end }}
{{- end }}

{{/*
Generate namespace name
*/}}
{{- define "sacunxt.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Common volume mounts
*/}}
{{- define "sacunxt.volumeMounts" -}}
{{- if .Values.extraVolumeMounts }}
{{ toYaml .Values.extraVolumeMounts }}
{{- end }}
{{- end }}

{{/*
Common volumes
*/}}
{{- define "sacunxt.volumes" -}}
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes }}
{{- end }}
{{- end }}
