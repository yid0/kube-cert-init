ARG ALPINE_VERSION=latest
ARG WORKDIR_APP=/app
ARG K8S_CERT_INIT_ENV=dev
ARG VIRTUAL_ENV=${WORKDIR_APP}/venv

## builder image
FROM yidoughi/pythopine:${ALPINE_VERSION} AS builder

ARG WORKDIR_APP

ARG VIRTUAL_ENV
ARG K8S_CERT_INIT_ENV

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR ${VIRTUAL_ENV}

RUN ls -la ${VIRTUAL_ENV}/lib64 &&  ls -la ${VIRTUAL_ENV}/lib

COPY --chown=1001:1001 requirement.txt ${VIRTUAL_ENV}/requirement.txt

RUN mkdir -p certs && pip --no-cache-dir install -r requirement.txt

COPY --chown=1001:1001 src ${VIRTUAL_ENV}/src
COPY --chown=1001 --chmod=755 scripts/start.sh ${VIRTUAL_ENV}/bin/start.sh
COPY --chown=1001 --chmod=755 scripts/entrypoint.sh ${VIRTUAL_ENV}/bin/entrypoint.sh


## prod image
FROM yidoughi/pythopine:latest

ARG WORKDIR_APP=/app
ARG VIRTUAL_ENV 
ARG K8S_CERT_DIR=/var/lib

ENV VIRTUAL_ENV=${VIRTUAL_ENV}

ENV HOME=${VIRTUAL_ENV}

ARG K8S_CERT_INIT_ENV
ENV K8S_CERT_INIT_ENV=${K8S_CERT_INIT_ENV} \
    K8S_CERT_DIR=${K8S_CERT_DIR} \
    PYTHONPATH="$HOME/src"

ENV PATH="$PYTHONPATH:$PATH"

WORKDIR ${HOME}

COPY --from=builder --chown=1001 ${VIRTUAL_ENV} ${VIRTUAL_ENV} 

RUN  apk update --no-cache && apk --no-cache add openssl && rm -rf /usr/lib/python**/__pycache__** && \
    find ${VIRTUAL_ENV} -type d -name "tests" -exec rm -rf {} + && \
    find /usr/lib/ -type d -name "tests" -exec rm -rf {} + && \
    find /usr/lib/ -type d -name "docs" -exec rm -rf {} + && \
    find ${VIRTUAL_ENV} -type d -name "__pycache__" -exec rm -rf {} + && \
    rm -rf /var/cache/apk/* /tmp/* /**/.cache/pip

USER 1001

CMD ["tail", "-f", "/dev/null"]
