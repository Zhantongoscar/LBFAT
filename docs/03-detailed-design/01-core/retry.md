# 重试机制设计

## 1. 功能描述
提供通用的重试机制，支持自定义重试策略。

## 2. 接口定义
export interface RetryConfig {
    maxRetries: number;
    retryInterval: number;
    timeout: number;
}

export interface RetryStrategy {
    shouldRetry(error: Error, retryCount: number): boolean;
    getDelay(retryCount: number): number;
}

## 3. 使用示例
const retryConfig = {
    maxRetries: 3,
    retryInterval: 1000,
    timeout: 5000
};

const result = await RetryUtil.withRetry(
    async () => {
        // 异步操作
    },
    retryConfig
);
