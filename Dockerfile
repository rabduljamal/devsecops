# Multi-stage build untuk mengoptimalkan ukuran image
FROM alpine:3.19 AS builder

# Install nginx
RUN apk add --no-cache nginx

# Stage akhir dengan image yang minimal
FROM alpine:3.19

# Install nginx dan dependencies minimal
RUN apk add --no-cache nginx && \
    # Buat user nginx jika belum ada
    addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx && \
    # Buat direktori yang diperlukan
    mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/conf.d /run/nginx && \
    # Set permission
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /run/nginx

# Copy file HTML ke direktori web nginx
COPY index.html /usr/share/nginx/html/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Switch to nginx user untuk security
USER nginx

# Command untuk menjalankan nginx
CMD ["nginx", "-g", "daemon off;"]