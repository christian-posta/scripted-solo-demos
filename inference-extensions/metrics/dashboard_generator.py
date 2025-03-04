#!/usr/bin/env python3
import json
import requests
import argparse
import os
from kubernetes import client, config

def get_vllm_pods_in_namespace(namespace="default"):
    """
    Retrieve all vLLM pods running in the specified namespace.
    """
    try:
        # Load Kubernetes config
        config.load_kube_config()
        v1 = client.CoreV1Api()
        
        # List pods with the vLLM label
        pods = v1.list_namespaced_pod(
            namespace=namespace,
            label_selector="app=vllm-llama2-7b-pool"  # Adjust this selector based on your labeling convention
        )
        
        return [pod.metadata.name for pod in pods.items]
    except Exception as e:
        print(f"Error retrieving pods: {e}")
        # For testing purposes, return a sample pod
        return ["vllm-llama2-7b-pool"]

def create_dashboard(pods, grafana_url, api_key=None):
    """
    Create a Grafana dashboard with panels for each vLLM pod.
    """
    # Basic dashboard structure
    dashboard = {
        "dashboard": {
            "id": None,
            "uid": "vllm-monitoring-dashboard",
            "title": "vLLM Pod Monitoring",
            "tags": ["vllm", "llm", "gpu", "monitoring"],
            "timezone": "browser",
            "schemaVersion": 30,
            "version": 1,
            "refresh": "10s",
            "panels": []
        },
        "overwrite": True
    }

    # Start with one panel for GPU cache usage
    y_pos = 0
    panel_height = 8
    panel_width = 12

    panel_id = 1

    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": 3, "w": 24, "x": 0, "y": y_pos},
        "type": "text",
        "title": "Resource Utilization",
        "options": {
            "mode": "markdown",
            "content": "# Resource Utilization\nMetrics related to GPU and memory utilization across vLLM pods"
        }
    })
    panel_id += 1
    y_pos += 3    
    
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": panel_width, "x": 0, "y": y_pos},
        "type": "timeseries",
        "title": "GPU Cache Usage (%)",
        "description": "Percentage of GPU cache being used by each vLLM pod",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"vllm:gpu_cache_usage_perc * 100",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 70},
                        {"color": "red", "value": 90}
                    ]
                },
                "unit": "percent"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1

    # CPU Cache Usage Panel
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": panel_width, "x": panel_width, "y": y_pos},
        "type": "timeseries",
        "title": "CPU Cache Usage (%)",
        "description": "Percentage of CPU cache being used by each vLLM pod",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"vllm:cpu_cache_usage_perc * 100",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 70},
                        {"color": "red", "value": 90}
                    ]
                },
                "unit": "percent"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    y_pos += panel_height

    # === Queue Status Section ===
    # Add section header
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": 3, "w": 24, "x": 0, "y": y_pos},
        "type": "text",
        "title": "Queue Status",
        "options": {
            "mode": "markdown",
            "content": "# Queue Status\nMetrics related to request queuing and processing"
        }
    })
    panel_id += 1
    y_pos += 3

    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 8, "x": 0, "y": y_pos},
        "type": "timeseries",
        "title": "Waiting Requests",
        "description": "Number of requests waiting in queue",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"vllm:num_requests_waiting",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 5},
                        {"color": "red", "value": 10}
                    ]
                }
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 8, "x": 8, "y": y_pos},
        "type": "timeseries",
        "title": "Running Requests",
        "description": "Number of requests currently being processed",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"vllm:num_requests_running",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None}
                    ]
                }
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 8, "x": 16, "y": y_pos},
        "type": "timeseries",
        "title": "Swapped Requests",
        "description": "Number of requests that have been swapped due to memory pressure",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"vllm:num_requests_swapped",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 1},
                        {"color": "red", "value": 5}
                    ]
                }
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    y_pos += panel_height
    
    # Queue Time Panel
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 12, "x": 0, "y": y_pos},
        "type": "timeseries",
        "title": "Average Queue Time (s)",
        "description": "Average time requests spend in queue before processing",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"rate(vllm:request_queue_time_seconds_sum[5m]) / rate(vllm:request_queue_time_seconds_count[5m])",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 1},
                        {"color": "red", "value": 5}
                    ]
                },
                "unit": "s"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    
    # Queue to Running Ratio Panel
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 12, "x": 12, "y": y_pos},
        "type": "timeseries",
        "title": "Queue to Running Ratio",
        "description": "Ratio of waiting to running requests (higher indicates queue buildup)",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"vllm:num_requests_waiting / (vllm:num_requests_running > 0)",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 0.5},
                        {"color": "red", "value": 1}
                    ]
                }
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    y_pos += panel_height    
        
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": 3, "w": 24, "x": 0, "y": y_pos},
        "type": "text",
        "title": "Performance Metrics",
        "options": {
            "mode": "markdown",
            "content": "# Performance Metrics\nLatency, throughput, and token processing metrics"
        }
    })
    panel_id += 1
    y_pos += 3

# Token Processing Metrics
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 12, "x": 0, "y": y_pos},
        "type": "timeseries",
        "title": "Time per Output Token (s)",
        "description": "Average time to generate each output token",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"rate(vllm:time_per_output_token_seconds_sum[5m]) / rate(vllm:time_per_output_token_seconds_count[5m])",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 0.1},
                        {"color": "red", "value": 0.2}
                    ]
                },
                "unit": "s"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1

    # Time To First Token Metrics
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 12, "x": 12, "y": y_pos},
        "type": "timeseries",
        "title": "Time To First Token (s)",
        "description": "Average time to generate the first output token",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"rate(vllm:time_to_first_token_seconds_sum[5m]) / rate(vllm:time_to_first_token_seconds_count[5m])",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 0.5},
                        {"color": "red", "value": 1.0}
                    ]
                },
                "unit": "s"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    y_pos += 3

    # End to End Request Latency
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 12, "x": 0, "y": y_pos},
        "type": "timeseries",
        "title": "End to End Request Latency (s)",
        "description": "Average end-to-end latency for processing requests",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"rate(vllm:e2e_request_latency_seconds_sum[5m]) / rate(vllm:e2e_request_latency_seconds_count[5m])",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 1.0},
                        {"color": "red", "value": 2.0}
                    ]
                },
                "unit": "s"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1

    # 95th Percentile Request Latency
    dashboard["dashboard"]["panels"].append({
        "id": panel_id,
        "gridPos": {"h": panel_height, "w": 12, "x": 12, "y": y_pos},
        "type": "timeseries",
        "title": "95th Percentile Request Latency (s)",
        "description": "95th percentile of end-to-end request latency",
        "datasource": {"type": "prometheus", "uid": "prometheus"},
        "targets": [
            {
                "expr": f"histogram_quantile(0.95, sum(rate(vllm:e2e_request_latency_seconds_bucket[5m])) by (le, instance))",
                "legendFormat": "{{instance}}",
                "refId": "A"
            }
        ],
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "lineInterpolation": "linear",
                    "lineWidth": 1,
                    "pointSize": 5,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                },
                "mappings": [],
                "thresholds": {
                    "mode": "absolute",
                    "steps": [
                        {"color": "green", "value": None},
                        {"color": "yellow", "value": 2.0},
                        {"color": "red", "value": 4.0}
                    ]
                },
                "unit": "s"
            }
        },
        "options": {
            "legend": {"calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom"},
            "tooltip": {"mode": "single", "sort": "none"}
        }
    })
    panel_id += 1
    y_pos += 3

    # Convert dashboard to JSON
    dashboard_json = json.dumps(dashboard, indent=2)
    
    # If we're just testing, print the dashboard JSON
    if not grafana_url:
        print("Dashboard JSON (for testing):")
        print(dashboard_json)
        return
    
    # Deploy the dashboard to Grafana
    headers = {
        "Content-Type": "application/json",
    }
    
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    
    try:
        response = requests.post(
            f"{grafana_url}/api/dashboards/db",
            headers=headers,
            data=dashboard_json
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"Dashboard created successfully: {result['url']}")
        else:
            print(f"Error creating dashboard: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Error connecting to Grafana: {e}")

def create_full_dashboard(pods, grafana_url, api_key=None):
    """
    Create a complete dashboard with all the required panels for monitoring vLLM pods.
    This will be implemented after we validate the basic approach works.
    """
    # This function will be expanded later to include all panels
    pass

def main():
    parser = argparse.ArgumentParser(description="Generate Grafana dashboard for vLLM pod monitoring")
    parser.add_argument("--namespace", default="default", help="Kubernetes namespace containing vLLM pods")
    parser.add_argument("--grafana-url", default=os.environ.get("GRAFANA_URL"), help="Grafana base URL")
    parser.add_argument("--api-key", default=os.environ.get("GRAFANA_API_KEY"), help="Grafana API key")
    args = parser.parse_args()
    
    # Get vLLM pods in the specified namespace
    pods = get_vllm_pods_in_namespace(args.namespace)
    print(f"Found {len(pods)} vLLM pods in namespace {args.namespace}: {', '.join(pods)}")
    
    # Create the initial dashboard with one panel
    create_dashboard(pods, args.grafana_url, args.api_key)

if __name__ == "__main__":
    main()