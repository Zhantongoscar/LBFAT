FROM neo4j:5.12.0

# 安装Python和必要的库
RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && pip3 install pandas \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /var/lib/neo4j

# 设置环境变量
ENV NEO4J_AUTH=neo4j/13701033228 \
    NEO4J_dbms_memory_pagecache_size=1G \
    NEO4J_dbms.memory.heap.initial_size=1G \
    NEO4J_dbms_memory_heap_max__size=1G \
    NEO4J_dbms_security_procedures_unrestricted=apoc.*,algo.* \
    NEO4J_apoc_import_file_enabled=true \
    NEO4J_apoc_export_file_enabled=true \
    NEO4J_dbms_security_allow__csv__import__from__file__urls=true

# 暴露端口
EXPOSE 7474 7687

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider localhost:7474 || exit 1 