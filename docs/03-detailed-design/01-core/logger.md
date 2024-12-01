# 日志工具设计

## 1. 功能描述
提供统一的日志记录机制，支持不同级别的日志输出和格式化。

## 2. 接口定义
export interface ILogger {
    debug(message: string, ...args: any[]): void;
    info(message: string, ...args: any[]): void;
    warn(message: string, ...args: any[]): void;
    error(message: string, ...args: any[]): void;
}

## 3. 配置参数
export interface LoggerConfig {
    level: LogLevel;
    format: LogFormat;
    outputs: LogOutput[];
}

## 4. 使用示例
const logger = new Logger({
    level: 'info',
    format: 'json',
    outputs: ['console', 'file']
});

logger.info('Operation completed', { operationId: 123 });
