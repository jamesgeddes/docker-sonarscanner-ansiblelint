FROM alpine:3.15.0

# Requirements for sonar scanner
ARG SONAR_SCANNER_VERSION=4.0.0.1744

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    bash \
    gcc \
    git \
    libc-dev \
    make \
    openssh-client \
    unzip \
    zip

## Sonar dependencies
RUN apk add --no-cache \
    curl \
    openjdk8-jre \
    nodejs

RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip -o ./sonarscanner.zip && \
    unzip sonarscanner.zip && \
    rm sonarscanner.zip && \
    mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /usr/lib/sonar-scanner && \
    ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

## Ensure sonar-scanner uses the provided Java for musl (openjdk8) instead of the glibc one it comes bundled with
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /usr/lib/sonar-scanner/bin/sonar-scanner

# Requirements for Ansible lint
## Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3=3.9.7-r4 && ln -sf python3 /usr/bin/python
RUN python -m ensurepip --upgrade
RUN pip3 install pip==21.3.1
RUN pip3 install resolvelib==0.5.4

## Install ansible
RUN apk add ansible=4.8.0-r0

## Ansible lint
RUN apk add yamllint=1.26.3-r0
RUN apk update
RUN apk add --upgrade ansible-lint=4.3.7-r4

## examples for test execution
#RUN wget -cO - https://raw.githubusercontent.com/ansible/ansible-examples/master/lamp_simple/roles/common/tasks/main.yml> good.yml
#RUN wget -cO - https://raw.githubusercontent.com/tonykay/bad-ansible/master/main.yml > bad.yml
