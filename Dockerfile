FROM node:14-alpine as BUILD_IMAGE

# required for node prune and build sqlite
RUN apk update && apk add curl make g++ python3 && ln -sf python3 /usr/bin/python && rm -rf /var/cache/apk/* 

# install node-prune (https://github.com/tj/node-prune)
RUN curl -sf https://gobinaries.com/tj/node-prune | sh

WORKDIR /usr/src/app

COPY package.json yarn.lock ./

COPY . ./

# If you are building your code for production
# RUN npm ci --only=production
RUN yarn install --production=true --frozen-lockfile
# tried vercel ncc, but doesn't find correct sqlite3.db file
# RUN yarn global add @vercel/ncc && ncc build index.js -o dist

# remove development dependencies
RUN npm prune --production

# run node prune
RUN node-prune

# may be others to remove du -sh ./node_modules/* | sort -nr | grep '\dM.*'



FROM node:14-alpine
LABEL org.opencontainers.image.source=https://ghcr.io/cbrown350/rpilocatorbot

# Create app directory
WORKDIR /app

ENV NODE_ENV production

# Install app dependencies
# RUN npm install -g npm@latest
# COPY package.json yarn.lock ./
# RUN yarn install --production=true --frozen-lockfile
COPY --from=BUILD_IMAGE /usr/src/app/node_modules ./node_modules

COPY . ./
# COPY migrations ./migrations
# COPY --from=BUILD_IMAGE /usr/src/app/dist/index.js ./
# COPY --from=BUILD_IMAGE /usr/src/app/node_modules/sqlite3/lib ./lib
# COPY --from=BUILD_IMAGE /usr/src/app/node_modules/telebot/plugins /plugins

CMD [ "node", "index.js" ]
