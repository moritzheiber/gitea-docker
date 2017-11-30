FROM moritzheiber/alpine-base:latest
MAINTAINER Moritz Heiber <hello@heiber.im>

ENV GITEA_VERSION="1.3.0" \
  GITEA_SHA256="19030d46c54f89178dfa63304d3da8ed724ced2880880c0ba396f7bb90d67e37" \
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
