FROM node:22.16.0 as dev
WORKDIR /app
RUN npm i -g @nestjs/cli
COPY package.json package-lock.json ./
RUN npm i
CMD ["npm","run","start:dev"]

FROM node:22.16.0 as dev-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM node:22.16.0 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:22.16.0 as prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:22.16.0 as prod
EXPOSE 3000
WORKDIR /app
ENV APP_VERSION=${APP_VERSION}
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
CMD ["node","dist/main.js"]
