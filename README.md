# Overpass API Helm Chart

This repository contains a Helm chart for deploying Overpass API on Kubernetes. Overpass API is a powerful tool for querying OpenStreetMap data.

## ⚠️ Early Development Warning

**This project is in very early stages of development and is not production-ready.** Use at your own risk and expect frequent changes.

## Quick Start

1. Add the Helm repository:
   ```
   helm repo add overpass-api https://remikalbe.github.io/overpass-api-helm-chart
   ```

2. Update your local Helm chart repository cache:
   ```
   helm repo update
   ```

3. Install the chart:
   ```
   helm install my-overpass-api overpass-api/overpass-api
   ```

## Configuration

For basic configuration options, see the `values.yaml` file. More detailed documentation will be provided as the project matures.

## License

[MIT License](LICENSE)

---

For more information on Overpass API, visit the [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Overpass_API).