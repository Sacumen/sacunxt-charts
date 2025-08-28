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
*/}}
{{- define "sacunxt.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
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
