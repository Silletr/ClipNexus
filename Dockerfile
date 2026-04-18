FROM docker.io/library/node:20-slim AS base


#  ━━━━━ Install Rust and dependencies ━━━━━
RUN apt-get update && apt-get install -y \
    curl gcc g++ libwebkit2gtk-4.0-dev \
    libgtk-3-dev \
    librsvg2-dev patchelf \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . $HOME/.cargo/env \
    && cargo install tauri-cli --version "^2"

ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /app

# Dev stage
FROM base AS development
COPY package*.json ./
COPY pnpm-lock.yaml* yarn.lock* ./
RUN corepack enable && corepack prepare --activate
COPY . .
EXPOSE 1420

CMD ["npm", "run", "tauri", "dev"]

#    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#    ┃    Build stage for bundles    ┃
#    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

FROM base AS builder
COPY --from=development /app /app
RUN npm ci --frozen-lockfile
ARG TARGETPLATFORM
RUN npm run tauri build -- --target universal-apple-darwin,linux,x86_64

RUN mkdir /output && cp src-tauri/target/release/bundle/*deb /output/ || true
FROM scratch AS production
COPY --from=builder /output /output
