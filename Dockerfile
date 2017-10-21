FROM moritzheiber/alpine-base:latest
MAINTAINER Moritz Heiber <hello@heiber.im>

ENV GITEA_VERSION="1.2.1" \
  GITEA_SHA256="83b894e321343e253006e689fb5a4d6fee048cf0fa3a169cb54c4060788133df" \
  GITEA_WORK_DIR="/gitea" \
  USERNAME="gitea"

RUN apk add --no-cache curl ca-certificates bash git tzdata openssh sqlite && \
  curl -Lo /usr/bin/gitea https://github.com/go-gitea/gitea/releases/download/v${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64 && \
  echo "${GITEA_SHA256}  /usr/bin/gitea" | sha256sum -c - && \
  chmod 0755 /usr/bin/gitea && \
  addgroup -S ${USERNAME} && \
  adduser -h ${GITEA_WORK_DIR} -s /bin/bash -SD ${USERNAME} && \
  install -d -m0755 -o ${USERNAME} -g ${USERNAME} ${GITEA_WORK_DIR}/config ${GITEA_WORK_DIR}/repositories ${GITEA_WORK_DIR}/data

ADD config/consul-template-config.hcl ${GITEA_WORK_DIR}/config/
ADD config/app.ini.ctmpl ${GITEA_WORK_DIR}/config/

EXPOSE 3000
VOLUME ["${GITEA_WORK_DIR}/repositories", "${GITEA_WORK_DIR}/data"]

WORKDIR ${GITEA_WORK_DIR}
USER ${USERNAME}

CMD ["consul-template","-config=config/consul-template-config.hcl"]
