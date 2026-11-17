FROM swift:6.4-noble AS builder
WORKDIR /app
COPY . .
RUN swift build --package-path Packages/{{TEMPLATE_APP_NAME}}Server \
      -c release --product {{TEMPLATE_APP_NAME}}serverd

# The -slim image carries the Swift runtime libraries the binary links against
# (and matches the builder's glibc); plain ubuntu has neither.
FROM swift:6.4-noble-slim
WORKDIR /app
COPY --from=builder /app/Packages/{{TEMPLATE_APP_NAME}}Server/.build/release/{{TEMPLATE_APP_NAME}}serverd .
EXPOSE {{TEMPLATE_SERVER_PORT}}
CMD ["./{{TEMPLATE_APP_NAME}}serverd", "serve", "--port", "{{TEMPLATE_SERVER_PORT}}"]
