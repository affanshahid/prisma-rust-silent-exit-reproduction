FROM rust:1.64-alpine as builder
RUN apk upgrade --update-cache --available
RUN apk add musl-dev
RUN apk add pkgconfig
RUN apk add libressl-dev
RUN rm -rf /var/cache/apk/*
RUN rustup target add x86_64-unknown-linux-musl
WORKDIR /usr/src
RUN USER=root cargo new app
WORKDIR /usr/src/app
RUN USER=root cargo new prisma-cli
COPY Cargo.toml Cargo.lock ./
RUN cargo build --target x86_64-unknown-linux-musl --release
COPY prisma ./prisma
COPY src ./src
RUN touch ./src/main.rs
RUN cargo build -p prisma-rust-silent-exit-reproduction --target x86_64-unknown-linux-musl --release --locked

FROM scratch
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/prisma-rust-silent-exit-reproduction /bin/prisma-rust-silent-exit-reproduction
CMD ["/bin/prisma-rust-silent-exit-reproduction"]
