FROM swift:6.3-noble AS builder
WORKDIR /app
COPY . .
RUN swift build --package-path Packages/{{TEMPLATE_APP_NAME}}Server \
      -c release --product {{TEMPLATE_APP_NAME}}serverd

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y libstdc++6 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/Packages/{{TEMPLATE_APP_NAME}}Server/.build/release/{{TEMPLATE_APP_NAME}}serverd .
EXPOSE {{TEMPLATE_SERVER_PORT}}
CMD ["./{{TEMPLATE_APP_NAME}}serverd", "serve", "--port", "{{TEMPLATE_SERVER_PORT}}"]
