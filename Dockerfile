FROM alpine:3.13.5

WORKDIR /app

# install awscli v2 on alpine
# https://stackoverflow.com/questions/61918972/how-to-install-aws-cli-on-alpine
RUN apk --no-cache add \
    binutils \
    curl \
    && GLIBC_VER=$(curl -s https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/latest | grep tag_name | cut -d : -f 2,3 | tr -d \",' ') \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
    glibc-${GLIBC_VER}.apk \
    glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
    binutils \
    curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright

RUN apk add --update --no-cache openssh
RUN apk add --update --no-cache bash
RUN apk add --update --no-cache curl
RUN apk add --update --no-cache unzip
RUN apk add --update --no-cache git


RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.10/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl

ADD ./asu-ssh-config/jkieley_asu /app/jkieley_asu
ADD ./asu-ssh-config/ssh-config.txt /app/ssh-config.txt
ADD ./asu-ssh-config/prepare-config.sh /app/prepare-config.sh

RUN mkdir /root/.ssh

RUN PATH_TO_SSH_KEY=/app/jkieley_asu SRC_FILE=/app/ssh-config.txt OUTPUT_FILE=/root/.ssh/config bash -c '/app/prepare-config.sh'
RUN chmod 400 /app/jkieley_asu

COPY . /app

RUN chmod +x /app/entrypoint.sh
RUN cp /app/config/known_hosts /root/.ssh/

ENTRYPOINT bash -x /app/entrypoint.sh
