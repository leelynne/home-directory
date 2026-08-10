FROM node:20-alpine

RUN apk add --no-cache bash shellcheck shfmt socat \
    && npm install -g bash-language-server

ENTRYPOINT ["bash-language-server"]
