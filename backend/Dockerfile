FROM node:16-alpine

WORKDIR /app

RUN apk add --no-cache curl python3 make g++ 

COPY package*.json ./

RUN sed -i '/"dependencies": {/a\    "jsonwebtoken": "^9.0.0",\n    "bcrypt": "^5.1.0",' package.json

RUN npm install

COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["npm", "start"] 