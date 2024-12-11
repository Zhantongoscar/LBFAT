#!/bin/sh

# 替换前端构建文件中的环境变量
if [ -d "/usr/share/nginx/html" ]; then
    echo "Replacing environment variables in JS files"
    # 递归查找所有js文件
    find /usr/share/nginx/html -type f -name "*.js" -exec sed -i "s|VITE_API_URL|${VITE_API_URL}|g" {} \;
fi

# 启动nginx
exec "$@" 