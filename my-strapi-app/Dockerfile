# -------- Build Stage --------
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .
RUN npm run build

# -------- Runtime Stage --------
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app .

EXPOSE 1337

CMD ["npm", "start"]
