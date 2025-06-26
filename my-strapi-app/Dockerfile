# -------- Build Stage --------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy and install dependencies
COPY package*.json ./
COPY yarn.lock ./
RUN npm install --omit=dev

# Copy application source
COPY ./src ./src
COPY ./config ./config
COPY ./public ./public
COPY ./admin ./admin
COPY ./database ./database
COPY ./index.js ./index.js

# Build admin panel
RUN npm run build

# -------- Runtime Stage --------
FROM node:20-alpine

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app .

# Remove dev dependencies
RUN npm prune --omit=dev

EXPOSE 1337

CMD ["npm", "start"]
