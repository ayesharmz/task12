# -------- Build Stage --------
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy only necessary app source files (no .env, no secrets)
COPY ./src ./src
COPY ./config ./config
COPY ./public ./public
COPY ./admin ./admin
COPY ./yarn.lock ./yarn.lock
COPY ./database ./database
COPY ./index.js ./index.js

# Build admin panel
RUN npm run build

# -------- Runtime Stage --------
FROM node:20-alpine

WORKDIR /app

# Copy built app
COPY --from=builder /app .

RUN npm prune --omit=dev

EXPOSE 1337

CMD ["npm", "start"]
