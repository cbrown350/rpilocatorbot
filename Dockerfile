FROM node:14-alpine as BUILD_IMAGE

# required to build sqlite
RUN apk update && apk add curl make g++ python3 && ln -sf python3 /usr/bin/python && rm -rf /var/cache/apk/* 

# install node-prune (https://github.com/tj/node-prune)
RUN curl -sf https://gobinaries.com/tj/node-prune | sh

WORKDIR /usr/src/app

COPY package.json yarn.lock ./


# If you are building your code for production
# RUN npm ci --only=production
RUN yarn install --production=true --frozen-lockfile

# remove development dependencies
RUN npm prune --production

# run node prune
RUN node-prune

# may be others to remove du -sh ./node_modules/* | sort -nr | grep '\dM.*'



FROM node:14-alpine

# Create app directory
WORKDIR /app

ENV NODE_ENV production

# Install app dependencies
COPY package.json yarn.lock ./
COPY --from=BUILD_IMAGE /usr/src/app/node_modules ./node_modules

# RUN npm install -g npm@latest

COPY . ./

CMD [ "node", "index.js" ]
