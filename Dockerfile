###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:18 As development
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

# Required for Prisma Client to work in container
RUN apt-get update && apt-get install -y openssl

# Create app directory
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image
# pnpm fetch does require only lockfile
COPY --chown=node:node pnpm-lock.yaml ./

# Fetch packages from a lockfile into virtual store
RUN pnpm fetch

# Bundle app source
COPY --chown=node:node . .

# Install app dependencies
RUN pnpm install -r --offline

# Generate Prisma database client code
# RUN npx prisma generate

# Use the node user from the image (instead of the root user)
USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:18 As build
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

WORKDIR /usr/src/app

COPY --chown=node:node pnpm-lock.yaml ./

COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node . .

RUN pnpm build

ENV NODE_ENV production

RUN pnpm install -r --offline --prod

USER node

###################
# PRODUCTION
###################

FROM node:18-alpine As production

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

# Start the server using the production build
CMD [ "node", "dist/main.js" ]
