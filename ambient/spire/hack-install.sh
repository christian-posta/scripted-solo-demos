#!/usr/bin/env sh

# Copyright 2024 Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SPIRE_HELM_OVERRIDE=$(
cat <<'END_HEREDOC'
global:
  spire:
    trustDomain: cluster.local
spire-agent:
    authorizedDelegates:
        - "spiffe://cluster.local/ns/istio-system/sa/ztunnel"
    sockets:
        admin:
            enabled: true
            mountOnHost: true
        hostBasePath: /run/spire/agent/sockets
    tolerations:
      - effect: NoSchedule
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoExecute
        operator: Exists
spire-server:
    persistence:
        type: emptyDir

spiffe-csi-driver:
    tolerations:
      - effect: NoSchedule
        operator: Exists
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoExecute
        operator: Exists
END_HEREDOC
)

echo "Installing SPIRE CRDS"
helm upgrade --install -n spire-server spire-crds spire-crds --repo https://spiffe.github.io/helm-charts-hardened/ --create-namespace

echo "Installing SPIRE and waiting for all pods to be ready before continuing..."
echo "$SPIRE_HELM_OVERRIDE" | helm upgrade --install -n spire-server spire spire --repo https://spiffe.github.io/helm-charts-hardened/ --wait -f -

echo "Applying ClusterSPIFFEID for ztunnel"

kubectl apply -f - <<EOF
apiVersion: spire.spiffe.io/v1alpha1
kind: ClusterSPIFFEID
metadata:
  name: istio-ztunnel-reg
spec:
  spiffeIDTemplate: "spiffe://{{ .TrustDomain }}/ns/{{ .PodMeta.Namespace }}/sa/{{ .PodSpec.ServiceAccountName }}"
  podSelector:
    matchLabels:
      app: "ztunnel"
EOF

echo "Applying ClusterSPIFFEID for waypoints"

kubectl apply -f - <<EOF
apiVersion: spire.spiffe.io/v1alpha1
kind: ClusterSPIFFEID
metadata:
  name: istio-waypoint-reg
spec:
  spiffeIDTemplate: "spiffe://{{ .TrustDomain }}/ns/{{ .PodMeta.Namespace }}/sa/{{ .PodSpec.ServiceAccountName }}"
  podSelector:
    matchLabels:
      istio.io/gateway-name: waypoint
EOF

echo "Applying ClusterSPIFFEID for workloads"
kubectl apply -f - <<EOF
apiVersion: spire.spiffe.io/v1alpha1
kind: ClusterSPIFFEID
metadata:
  name: istio-ambient-reg
spec:
  spiffeIDTemplate: "spiffe://{{ .TrustDomain }}/ns/{{ .PodMeta.Namespace }}/sa/{{ .PodSpec.ServiceAccountName }}"
  podSelector:
    matchLabels:
      istio.io/dataplane-mode: ambient
EOF
