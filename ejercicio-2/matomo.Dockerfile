FROM matomo:latest

# Set PHP memory limit environment variable
ENV PHP_MEMORY_LIMIT=512M

# Create custom PHP configuration file with upload and post size limits
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini && \
    echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/zzz-matomo.ini