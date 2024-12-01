FROM node:18-alpine

WORKDIR /app

# 创建日志目录
RUN mkdir -p logs

# 复制package.json和package-lock.json（如果存在）
COPY backend/package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY backend/ .

# 确保服务目录存在
RUN mkdir -p services

# 暴露端口
EXPOSE 3000

# 启动应用
CMD ["node", "app.js"]
