#!/bin/bash
SOURCE_DIR=$PWD
source ./env.sh


kubectl --context $CLUSTER_1 patch -n istio-system deploy/istiod --patch '{
	"spec": {
			"template": {
				"spec": {
						"initContainers": [
							{
									"args": [
										"init-container"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent-init"
							}
						],
						"containers": [
							{
									"args": [
										"sidecar"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent"
							}
						],
						"volumes": [
							{
									"name": "cacerts",
									"secret": null,
									"emptyDir": {
										"medium": "Memory"
									}
							}
						]
				}
			}
	}
}'

kubectl --context $CLUSTER_2 patch -n istio-system deploy/istiod --patch '{
	"spec": {
			"template": {
				"spec": {
						"initContainers": [
							{
									"args": [
										"init-container"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent-init"
							}
						],
						"containers": [
							{
									"args": [
										"sidecar"
									],
									"env": [
										{
												"name": "PILOT_CERT_PROVIDER",
												"value": "istiod"
										},
										{
												"name": "POD_NAME",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.name"
													}
												}
										},
										{
												"name": "POD_NAMESPACE",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "metadata.namespace"
													}
												}
										},
										{
												"name": "SERVICE_ACCOUNT",
												"valueFrom": {
													"fieldRef": {
															"apiVersion": "v1",
															"fieldPath": "spec.serviceAccountName"
													}
												}
										}
									],
									"volumeMounts": [
										{
												"mountPath": "/etc/cacerts",
												"name": "cacerts"
										}
									],
									"imagePullPolicy": "IfNotPresent",
									"image": "gcr.io/gloo-mesh/istiod-agent:1.1.3",
									"name": "istiod-agent"
							}
						],
						"volumes": [
							{
									"name": "cacerts",
									"secret": null,
									"emptyDir": {
										"medium": "Memory"
									}
							}
						]
				}
			}
	}
}'