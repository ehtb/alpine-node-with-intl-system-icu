FROM alpine:3.6

ENV VERSION=v8.4.0 NPM_VERSION=5.3 YARN_VERSION=latest

RUN apk add --no-cache icu-libs && \
  apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ icu-dev && \
  curl -sSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
    grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep . && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --with-intl=system-icu --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  npm install -g npm@${NPM_VERSION} && \
  find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
    6A010C5166006599AA17F08146C2130DFD2497F5 && \
  curl -sSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
  gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
  mkdir /usr/local/share/yarn && \
  tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
  ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
  ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
  rm ${YARN_VERSION}.tar.gz* && \
  apk del curl make gcc g++ python linux-headers binutils-gold gnupg && \
  rm -rf /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts
