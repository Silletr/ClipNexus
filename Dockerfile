FROM docker.io/library/node:20-slim AS base

#  ━━━━━ Install Rust and dependencies ━━━━━

RUN apt-get update && apt-get install -y \
    curl gcc g++ libwebkit2gtk-4.0-dev \
    libgtk-3-dev libayatana-appindicator3-dev \
    librsvg2-dev patchelf \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . $HOME/.cargo/env \
    && cargo install tauri-cli --version "^2"  # Adjust for Tauri v2 if used [web:14]

ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /app

# Dev stage
FROM base AS development
COPY package*.json ./
COPY pnpm-lock.yaml* yarn.lock* ./
RUN corepack enable && corepack prepare --activate  # For pnpm/yarn; or npm ci
COPY . .
EXPOSE 1420  # Default Tauri dev port; SvelteKit on 5173

CMD ["npm", "run", "tauri", "dev"]  # Assumes "tauri dev" in package.json [web:13]

#    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#    ┃    Build stage for bundles    ┃
#    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

FROM base AS builder
COPY --from=development /app /app
RUN npm ci --frozen-lockfile
ARG TARGETPLATFORM
RUN npm run tauri build -- --target universal-apple-darwin,linux,x86_64  # Adjust targets [web:16]

#  ━━━━━ Extract bundles (example for Linux) ━━━━━
RUN mkdir /output && cp src-tauri/target/release/bundle/*deb /output/ || true
FROM scratch AS production
COPY --from=builder /output /output
