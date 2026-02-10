{{/*
Expand the name of the chart.
*/}}
{{- define "sacunxt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
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
Create image pull secrets
Only include imagePullSecrets if the secret name is set AND either:
- createACRSecret is true (chart creates the secret), or
- dockerConfigJson is provided (pre-existing secret data)
*/}}
{{- define "sacunxt.imagePullSecrets" -}}
{{- if and .Values.global.imagePullSecrets (or .Values.secrets.createACRSecret .Values.global.dockerConfigJson) }}
imagePullSecrets:
  - name: {{ .Values.global.imagePullSecrets }}
{{- end }}
{{- end }}

{{/*
Create image URL
*/}}
{{- define "sacunxt.image" -}}
{{- $registry := index . 1 "registry" | default .Values.global.registry -}}
{{- $repository := index . 1 "repository" -}}
{{- $tag := index . 1 "tag" | default .Chart.AppVersion -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end }}

{{/*
Create namespace name for microservices
*/}}
{{- define "sacunxt.namespace" -}}
{{- .Values.global.namespace | default "sacunxt" -}}
{{- end }}

{{/*
Create database environment variables for a service
Usage: {{ include "sacunxt.dbEnvVars" (dict "Values" .Values "service" .Values.apiService) }}
*/}}
{{- define "sacunxt.dbEnvVars" -}}
{{- $service := .service -}}
{{- if $service.database -}}
- name: DB_HOST
  value: {{ $service.database.host | default "postgres-service.database.svc.cluster.local" | quote }}
- name: DB_PORT
  value: {{ $service.database.port | default "5432" | quote }}
- name: DB_USER
  value: {{ $service.database.username | quote }}
- name: DB_NAME
  value: {{ $service.database.name | quote }}
- name: DB_SCHEMA
  value: {{ $service.database.schema | quote }}
- name: SSL_MODE
  value: {{ $service.database.sslMode | default "false" | quote }}
{{- if $service.database.passwordSecret }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $service.database.passwordSecret.name | quote }}
      key: {{ $service.database.passwordSecret.key | default "password" | quote }}
      optional: {{ $service.database.passwordSecret.optional | default true }}
{{- else if $service.database.password }}
- name: DB_PASSWORD
  value: {{ $service.database.password | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create namespace name for Redis
*/}}
{{- define "sacunxt.redisNamespace" -}}
{{- .Values.redis.namespace | default "redis-cache" -}}
{{- end }}

{{/*
Create namespace name for PostgreSQL
*/}}
{{- define "sacunxt.postgresqlNamespace" -}}
{{- .Values.postgresql.namespace | default "database" -}}
{{- end }}

{{/*
Create namespace name for Kafka
*/}}
{{- define "sacunxt.kafkaNamespace" -}}
{{- .Values.kafka.namespace | default "kafka-system" -}}
{{- end }}

{{/*
Init containers for dependency waiting
*/}}
{{- define "sacunxt.initContainers" -}}
initContainers:
{{- if .Values.postgresql.enabled }}
  - name: wait-for-postgresql
    image: busybox:1.35
    command: ['sh', '-c']
    args:
      - |
        until nc -z {{ .Values.postgresql.serviceName | default "postgres-service" }}.{{ include "sacunxt.postgresqlNamespace" . }}.svc.cluster.local 5432; do
          echo "Waiting for PostgreSQL..."
          sleep 2
        done
        echo "PostgreSQL is ready!"
{{- end }}
{{- if .Values.redis.enabled }}
  - name: wait-for-redis
    image: busybox:1.35
    command: ['sh', '-c']
    args:
      - |
        until nc -z {{ .Values.redis.serviceName | default "redis" }}.{{ include "sacunxt.redisNamespace" . }}.svc.cluster.local 6379; do
          echo "Waiting for Redis..."
          sleep 2
        done
        echo "Redis is ready!"
{{- end }}
{{- if .Values.kafka.enabled }}
  - name: wait-for-kafka
    image: busybox:1.35
    command: ['sh', '-c']
    args:
      - |
        until nc -z {{ .Values.kafka.serviceName | default "kafka-service" }}.{{ include "sacunxt.kafkaNamespace" . }}.svc.cluster.local 9092; do
          echo "Waiting for Kafka..."
          sleep 2
        done
        echo "Kafka is ready!"
{{- end }}
{{- end }}
