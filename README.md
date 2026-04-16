# 工业逻辑竞技场 · Industrial Logic Arena

> **全球首款"虚实协同 + UGC回合制对抗"工业排故推演沙盘**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Project Status: Active](https://img.shields.io/badge/Status-Active-brightgreen.svg)]()

---

## 产品简介

**工业逻辑竞技场（Industrial Logic Arena）** 是一款专为职业院校工业工艺教学设计的虚实协同沙盘竞技平台。以 **Aspen 工业过程仿真引擎**为核心，融合卡牌竞技的 **Cost/Action 游戏机制**，将枯燥的化工/制药参数分析转化为团队 PVP（玩家对战）竞技体验，让学生在"为了赢得比赛"的强烈动机下，主动深入研究工艺原理与故障机制。

### 核心价值

| 维度 | 传统仿真软件 | 工业逻辑竞技场 |
|------|-------------|--------------|
| 可玩性 | 照答案操作，一次即废 | UGC出题 + PVP对抗，无限复玩 |
| 科学严谨性 | 固定剧本，无物理推演 | Aspen实时仿真，百分百真实 |
| 学习动机 | 被动完成任务 | 主动研究，为了"阴"过对方 |
| 团队协作 | 个人操作 | 中控员+巡检员强制分工协同 |
| 硬件成本 | 数十至百万元物理模型 | 极简硬件底座 + 软件为核心 |

---

## 目录结构

```
projectroot/
├── frontend/                # 前端项目（Vue.js）
│   ├── src/
│   │   ├── assets/         # 静态资源
│   │   ├── components/     # 组件
│   │   ├── views/          # 页面
│   │   ├── store/          # 状态管理
│   │   ├── utils/          # 工具函数
│   │   └── api/            # API接口
│   ├── public/
│   ├── tests/
│   └── package.json
│
├── backend/                 # 后端项目（Node.js）
│   ├── src/
│   │   ├── controllers/    # 控制器
│   │   ├── services/       # 服务层
│   │   ├── models/         # 数据模型
│   │   └── utils/          # 工具函数
│   ├── config/
│   ├── tests/
│   └── package.json
│
├── docker/                  # Docker配置
│   ├── frontend/           # 前端 Nginx 配置
│   ├── backend/            # 后端容器配置
│   ├── mysql/              # MySQL 数据库配置
│   └── emqx/               # EMQX MQTT 消息服务
│
├── docs/                    # 项目文档
│   ├── Industrial-Logic-Arena/   # 产品策划与设计文档
│   ├── 01-requirements/         # 需求文档
│   ├── 02-architecture/         # 架构设计
│   ├── 03-detailed-design/      # 详细设计
│   └── 04-standards/            # 开发规范
│
└── docker-compose.yml       # 容器编排配置
```

---

## 快速开始

### 开发环境

```bash
# 初始化开发环境
./scripts/init-dev.sh

# 启动开发环境（含热重载）
docker-compose -f docker-compose.dev.yml up
```

### 生产部署

```bash
# 部署应用
./scripts/deploy.sh

# 数据备份
./scripts/backup.sh
```

### 容器服务说明

| 服务 | 说明 |
|------|------|
| `frontend` | Vue.js 前端应用 |
| `backend` | Node.js 后端 API 服务 |
| `mysql` | MySQL 数据库 |
| `emqx` | MQTT 消息服务（设备通信） |

---

## 核心文档

- 📋 [产品策划书](docs/Industrial-Logic-Arena/产品策划书.md) — 完整商业策划与游戏机制设计
- 🏗️ [项目架构](docs/02-architecture/project-progress.md)
- 🔌 [MCU-MQTT通信协议](docs/03-detailed-design/mcu-mqtt-communication.md)
- 📖 [开发规范](docs/04-standards/development-standard.md)

---

## 原始项目说明

本仓库由 **LBFAT（Leybold 面板功能验收测试）** 项目演化而来，已全面转型为工业逻辑竞技场产品。历史技术积累（Vue.js 前端、Node.js 后端、MQTT 通信、Docker 容器化部署）将作为竞技场平台的底层基础设施继续使用。

详见迁移说明：[MIGRATION.md](MIGRATION.md)
