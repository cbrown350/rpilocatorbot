FROM node:14 

# Create app directory
WORKDIR /app

ENV NODE_ENV production
# Install app dependencies
COPY package.json package-lock.json /app/

# RUN npm install -g npm@latest

COPY . ./

# If you are building your code for production
RUN npm ci --only=production

CMD [ "node", "index.js" ]
