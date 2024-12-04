FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install mqtt readline

COPY . .

CMD ["node", "mqtt-client.js"] 