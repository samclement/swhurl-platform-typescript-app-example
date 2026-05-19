FROM node:24-bookworm-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
ARG NPM_CONFIG_LOGLEVEL=warn
RUN npm ci

FROM deps AS build
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:24-bookworm-slim AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
ARG NPM_CONFIG_LOGLEVEL=warn
RUN npm ci --omit=dev

FROM gcr.io/distroless/nodejs24-debian12:nonroot AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY --from=prod-deps --chown=65532:65532 /app/node_modules ./node_modules
COPY --from=prod-deps --chown=65532:65532 /app/package.json ./package.json
COPY --from=build --chown=65532:65532 /app/dist ./dist
EXPOSE 3000
CMD ["dist/server.js"]
