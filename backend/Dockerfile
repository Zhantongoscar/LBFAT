FROM node:16-alpine

WORKDIR /app

RUN apk add --no-cache curl

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["npm", "start"] 