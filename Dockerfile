# hadolint global ignore=DL3008 # We intentionally don't want to pin specific versions for rolling updates

FROM python:3.10-slim AS builder

ARG SALT_VERSION="3007.12"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl xz-utils

RUN set -eux; \
    groupadd --system --gid 450 salt; \
    useradd --system --uid 450 --home-dir /home/salt --create-home --shell /bin/sh --gid 450 salt; \
    mkdir -p /etc/pki /etc/salt/pki /etc/salt/minion.d/ /etc/salt/master.d /etc/salt/proxy.d /var/cache/salt /var/log/salt /var/run/salt; \
    chmod -R 2775 /etc/pki /etc/salt /var/cache/salt /var/log/salt /var/run/salt; \
    chgrp -R salt /etc/pki /etc/salt /var/cache/salt /var/log/salt /var/run/salt

RUN set -eux; \
    ARCH=$(uname -m | sed 's/aarch64/arm64/'); \
    mkdir -p /opt/saltstack; \
    curl -L "https://packages.broadcom.com/artifactory/saltproject-generic/onedir/${SALT_VERSION}/salt-${SALT_VERSION}-onedir-linux-${ARCH}.tar.xz" | tar -xJf - -C /opt/saltstack/ ; \
    su - salt -c '/opt/saltstack/salt/salt-run salt.cmd tls.create_self_signed_cert'


FROM debian:trixie-slim

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        dumb-init \
    ; \
    apt-get dist-clean; \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/dumb-init"]

EXPOSE 4505 4506 8000
ENV PATH=/opt/saltstack/salt:/opt/saltstack/salt/bin:$PATH
VOLUME /etc/salt/pki/

COPY saltinit.py /usr/local/bin/saltinit
CMD ["/usr/local/bin/saltinit"]

RUN set -eux; \
    groupadd --system --gid 450 salt; \
    useradd --system --uid 450 --home-dir /home/salt --create-home --shell /bin/sh --gid 450 salt

COPY --from=builder /etc/pki /etc/pki
COPY --from=builder /etc/salt /etc/salt
COPY --from=builder /var/cache/salt /var/cache/salt
COPY --from=builder /var/log/salt /var/log/salt
COPY --from=builder /var/run/salt /var/run/salt
COPY --from=builder /opt/saltstack /opt/saltstack
