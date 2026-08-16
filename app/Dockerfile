# ---------- Stage 1: build the app ----------
FROM node:24 AS builder
WORKDIR /app
COPY . .

# Install deps and build the static site (produces /app/build)
RUN corepack enable && yarn install --network-timeout 1000000 && yarn build

# ---------- Stage 2: serve the built files ----------

# nginx-unprivileged runs as a non-root user for security
FROM nginxinc/nginx-unprivileged:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 8080