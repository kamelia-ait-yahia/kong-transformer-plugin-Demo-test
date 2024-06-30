FROM kong:3.0

USER root

# Install necessary packages including build tools, expat, and luarocks
COPY kong-plugin-soap-request-transformer-master/spec /usr/local/share/lua/5.1/spec
COPY kong-plugin-soap-request-transformer-master/kong-plugin-soap-request-transformer-0.1.0-0.rockspec /usr/local/share/lua/5.1/
RUN apk add --no-cache \
        gcc \
        make \
        musl-dev \
        luarocks \
        expat\
        expat-dev \
    && luarocks install --only-deps /usr/local/share/lua/5.1/kong-plugin-soap-request-transformer-0.1.0-0.rockspec


USER kong

# Copy the custom plugin to the appropriate directory
COPY kong-plugin-soap-request-transformer-master/kong/plugins/soap-request-transformer /usr/local/share/lua/5.1/kong/plugins/soap-request-transformer
