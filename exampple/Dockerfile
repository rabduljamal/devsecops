# Multi-platform build untuk GitHub Actions
FROM --platform=$BUILDPLATFORM alpine:3.19 AS builder

# Build arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Install nginx dan wget untuk health check
RUN apk add --no-cache nginx wget ca-certificates

# Final stage
FROM alpine:3.19

# Labels untuk metadata (GitHub Container Registry)
LABEL org.opencontainers.image.source="https://github.com/$GITHUB_REPOSITORY"
LABEL org.opencontainers.image.description="DevSecOps Pipeline Visualization"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="DevSecOps Team"

# Install dependencies
RUN apk add --no-cache nginx wget ca-certificates && \
    # Create nginx user and group
    addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx && \
    # Create required directories
    mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/conf.d /run/nginx && \
    # Set permissions
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /run/nginx && \
    # Remove default nginx files
    rm -rf /usr/share/nginx/html/* && \
    # Clean up
    rm -rf /var/cache/apk/*

# Copy HTML files
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/

# Copy nginx configuration
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf

# Create non-root user for security
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# Security: run as non-root user
USER nginx

# Start nginx
CMD ["nginx", "-g", "daemon off;"]