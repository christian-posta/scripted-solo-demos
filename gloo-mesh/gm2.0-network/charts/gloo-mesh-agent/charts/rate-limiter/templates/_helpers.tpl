
{{- define "rate-limiter.extraLabels" -}}
{{- range $key, $value := $.Values.extraLabels -}}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{- define "rate-limiter.extraTemplateAnnotations" -}}
{{- range $key, $value := $.Values.extraTemplateAnnotations -}}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}