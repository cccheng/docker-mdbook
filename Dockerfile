FROM rust:1.60-slim as builder

ENV ARC="x86_64-unknown-linux-musl"
ENV CARGO_INSTALL_ROOT="/usr/local/"
ENV CARGO_TARGET_DIR="/tmp/target/"

RUN apt update
RUN apt install -y libssl-dev pkg-config ca-certificates build-essential make perl gcc libc6-dev musl-tools

RUN rustup target add "$ARC"
RUN cargo install --target "$ARC" mdbook
RUN cargo install --target "$ARC" mdbook-linkcheck
RUN cargo install --target "$ARC" mdbook-toc
RUN cargo install --target "$ARC" mdbook-plantuml --no-default-features
RUN cargo install --target "$ARC" mdbook-graphviz

# Final image
FROM openjdk:19-jdk-alpine
MAINTAINER docker@cccheng.net

RUN apk add --no-cache graphviz wget ca-certificates ttf-dejavu fontconfig
RUN mkdir /plantuml && \
    wget "https://github.com/plantuml/plantuml/releases/download/v1.2022.4/plantuml-1.2022.4.jar" -O /plantuml/plantuml.jar
RUN apk del wget ca-certificates

COPY --from=builder /usr/local/bin/mdbook* /usr/bin/
COPY plantuml /usr/bin/

ENTRYPOINT ["/usr/bin/mdbook"]
CMD []

