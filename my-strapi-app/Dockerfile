# -------- Build Stage --------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy and install dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application source
COPY ./src ./src
COPY ./config ./config
COPY ./public ./public

# Build admin panel
RUN npm run build

# -------- Runtime Stage --------
FROM node:20-alpine

WORKDIR /app

# Copy built app
COPY --from=builder /app .

# Remove dev dependencies
RUN npm prune --omit=dev

EXPOSE 1337

CMD ["npm", "start"]
