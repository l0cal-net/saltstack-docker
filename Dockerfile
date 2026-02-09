FROM python:3.10-slim

ARG SALT_VERSION="3007.12"

RUN apt-get update && apt-get install -y curl dumb-init xz-utils

RUN addgroup --system --gid 450 salt && adduser --system --uid 450 --home /home/salt --shell /bin/sh --group salt && \
    mkdir -p /etc/pki /etc/salt/pki /etc/salt/minion.d/ /etc/salt/master.d /etc/salt/proxy.d /var/cache/salt /var/log/salt /var/run/salt && \
    chmod -R 2775 /etc/pki /etc/salt /var/cache/salt /var/log/salt /var/run/salt && \
    chgrp -R salt /etc/pki /etc/salt /var/cache/salt /var/log/salt /var/run/salt

ENTRYPOINT ["/usr/bin/dumb-init"]
CMD ["/usr/local/bin/saltinit"]
ADD saltinit.py /usr/local/bin/saltinit
EXPOSE 4505 4506 8000
VOLUME /etc/salt/pki/

ENV PATH=/opt/saltstack/salt:$PATH

RUN ARCH=$(uname -m | sed 's/aarch64/arm64/'); \
    mkdir -p /opt/saltstack && \
    curl -L "https://packages.broadcom.com/artifactory/saltproject-generic/onedir/${SALT_VERSION}/salt-${SALT_VERSION}-onedir-linux-${ARCH}.tar.xz" | tar -xJf - -C /opt/saltstack/
RUN su - salt -c '/opt/saltstack/salt/salt-run salt.cmd tls.create_self_signed_cert'
