FROM alpine:3.22 AS builder

RUN apk add --no-cache build-base linux-headers git ca-certificates cmake gperf openssl-dev zlib-dev
ARG SOURCE_REF=7232881b39dfcd048a0d569f1983c5184249ee05
ARG BUILD_JOBS=1
WORKDIR /src
RUN git init . \
    && git remote add origin https://github.com/tdlib/telegram-bot-api.git \
    && git fetch --depth 1 origin "$SOURCE_REF" \
    && git checkout --detach FETCH_HEAD \
    && git submodule update --init --recursive --depth 1
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build build --target install --parallel "$BUILD_JOBS" \
    && strip /usr/local/bin/telegram-bot-api

FROM alpine:3.22
RUN apk add --no-cache ca-certificates libstdc++ openssl zlib \
    && addgroup -S -g 101 telegram-bot-api \
    && adduser -S -D -H -u 101 -G telegram-bot-api telegram-bot-api \
    && mkdir -p /var/lib/telegram-bot-api /tmp/telegram-bot-api \
    && chown 101:101 /var/lib/telegram-bot-api /tmp/telegram-bot-api
COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY --from=builder /src/LICENSE_1_0.txt /usr/share/licenses/telegram-bot-api/LICENSE_1_0.txt
USER 101:101
WORKDIR /var/lib/telegram-bot-api
RUN telegram-bot-api --version 2>&1 | grep -Fx 'Bot API 10.4'
EXPOSE 8081
ENTRYPOINT ["/usr/local/bin/telegram-bot-api"]
CMD ["--local", "--http-port=8081", "--dir=/var/lib/telegram-bot-api", "--temp-dir=/tmp/telegram-bot-api"]
