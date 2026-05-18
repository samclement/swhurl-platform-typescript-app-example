# swhurl-platform TypeScript App Example

Bare minimum TypeScript HTTP service for the `swhurl-platform` homelab cluster.

## What It Uses

- Node.js built-in HTTP server
- TypeScript compile step
- JSON stdout logging with `pino`
- OpenTelemetry Node auto-instrumentation via `NODE_OPTIONS`
- OTLP HTTP export to the in-cluster OTel collector
- Traefik ingress with shared oauth2-proxy middleware
- cert-manager TLS certificate

## Local Development

```bash
npm install
npm run dev
curl http://localhost:3000
curl http://localhost:3000/healthz
```

## Build

```bash
npm run build
npm start
```

## Container

```bash
docker build -t ghcr.io/samclement/swhurl-platform-typescript-app-example:latest .
```

GitHub Actions builds and pushes images to GHCR on pushes to `main`:

- `ghcr.io/samclement/swhurl-platform-typescript-app-example:<full-commit-sha>`
- `ghcr.io/samclement/swhurl-platform-typescript-app-example:<12-char-commit-sha>`

## Platform Runtime Contract

The Kubernetes manifests set:

- `NODE_OPTIONS=--require @opentelemetry/auto-instrumentations-node/register`
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-k8s-cluster-opentelemetry-collector.logging.svc.cluster.local:4318`
- `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`
- `OTEL_TRACES_EXPORTER=otlp`
- `OTEL_METRICS_EXPORTER=otlp`

Application logs go to stdout as JSON. The platform OTel daemonset collects container logs and exports them to ClickStack.

OAuth is handled at the edge by Traefik and oauth2-proxy. The app can read identity from forwarded headers:

- `X-Auth-Request-User`
- `X-Auth-Request-Email`
- `X-Auth-Request-Preferred-Username`
- `Authorization`

## Render Manifests

```bash
kubectl kustomize k8s/overlays/staging
kubectl kustomize k8s/overlays/prod
```

## Deploy Shape

To make this app Flux-managed by `swhurl-platform`, add a Flux Kustomization in that repo that points at this repository and one of:

- `./k8s/overlays/staging`
- `./k8s/overlays/prod`
