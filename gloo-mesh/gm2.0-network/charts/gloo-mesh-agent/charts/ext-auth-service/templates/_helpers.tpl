
{{- define "ext-auth-service.extraLabels" -}}
{{- range $key, $value := $.Values.extraLabels -}}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{- define "ext-auth-service.extraTemplateAnnotations" -}}
{{- range $key, $value := $.Values.extraTemplateAnnotations -}}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{- define "ext-auth-service.signingKeyValue" -}}
{{- $extAuth := $.Values.extAuth -}}
{{- if $extAuth.signingKey -}}
{{- $extAuth.signingKey | b64enc | quote -}}
{{- else -}}
{{- randAlphaNum 10 | b64enc | quote -}}
{{- end -}}
{{- end -}}