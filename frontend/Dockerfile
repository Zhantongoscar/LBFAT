FROM node:16-alpine as builder

RUN npm config set registry https://registry.npmmirror.com

WORKDIR /app

COPY package*.json ./

# 添加 vuex 和 sass 依赖到 package.json
RUN sed -i '/"dependencies": {/a\    "vuex": "^4.0.2",' package.json && \
    npm install -D sass

RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# 创建用于存放环境变量替换的临时文件
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"] 