# 项目迁移说明 · Migration Guide

## 从 LBFAT 迁移至工业逻辑竞技场（Industrial Logic Arena）

---

## 概述

本文档记录了 **LBFAT（Leybold 面板功能验收测试）** 项目向 **工业逻辑竞技场（Industrial Logic Arena）** 产品的正式迁移过程。

| 项目 | 内容 |
|------|------|
| **原始仓库** | `Zhantongoscar/LBFAT` |
| **产品演化方向** | 工业逻辑竞技场 · Industrial Logic Arena |
| **迁移时间** | 2026 年 4 月 |
| **迁移类型** | 产品定位重构 + 文档更新（代码基础设施保留） |

---

## 迁移内容

### ✅ 保留内容（全部继承）

| 内容 | 说明 |
|------|------|
| 完整代码库 | `frontend/`、`backend/`、`mysql/`、`tests/` 全部保留 |
| Docker 部署配置 | `docker-compose.yml` 及所有 `Dockerfile` 保留 |
| MQTT 通信架构 | EMQX 消息服务及硬件通信协议保留，作为沙盘硬件通信基础 |
| 数据库设计 | MySQL 模型及历史迁移脚本保留 |
| 开发规范 | `docs/04-standards/` 下的开发规范继续沿用 |
| 历史 Git 记录 | 完整 commit 历史保留，维护演进可追溯性 |

### 🔄 更新内容

| 文件 | 变更说明 |
|------|---------|
| `README.md` | 全面更新为工业逻辑竞技场产品简介、架构说明和快速开始指南 |
| `docs/Industrial-Logic-Arena/产品策划书.md` | **新增** — 完整商业策划书，含产品定位、核心机制、商业模式 |
| `MIGRATION.md` | **新增** — 本文件，记录迁移过程 |

### 📋 后续待创建文档（规划中）

| 文件 | 说明 |
|------|------|
| `docs/Industrial-Logic-Arena/游戏机制详细设计.md` | Cost/Action/卡牌系统的详细规则 |
| `docs/Industrial-Logic-Arena/Aspen集成方案.md` | Aspen API 对接技术方案 |
| `docs/Industrial-Logic-Arena/硬件通信协议.md` | 沙盘探针方块与后端的通信规范 |
| `docs/Industrial-Logic-Arena/赛事运营手册.md` | 组织班级/校际对抗赛的操作指南 |

---

## 新建独立仓库指南（推荐步骤）

如需将本项目完整迁移至一个全新的独立 GitHub 仓库（如 `Industrial-Logic-Arena`），建议执行以下步骤：

### 方法一：使用 GitHub 导入功能（推荐）

1. 登录 GitHub，访问 https://github.com/new
2. 填写仓库名称：`Industrial-Logic-Arena`
3. 添加描述：`全球首款虚实协同 + UGC回合制对抗工业排故推演沙盘 | Industrial Logic Arena`
4. 创建后，在新仓库设置页面选择 **"Import repository"** 或使用 GitHub Importer
5. 填写源仓库地址：`https://github.com/Zhantongoscar/LBFAT`
6. 等待导入完成（将完整保留 Git 历史）

### 方法二：手动 Git 镜像克隆

```bash
# 1. 裸克隆原始仓库（保留完整历史和所有分支）
git clone --mirror https://github.com/Zhantongoscar/LBFAT.git

# 2. 在 GitHub 上手动创建新仓库 Industrial-Logic-Arena（不要初始化）

# 3. 推送到新仓库
cd LBFAT.git
git remote set-url origin https://github.com/Zhantongoscar/Industrial-Logic-Arena.git
git push --mirror

# 4. 删除裸克隆临时目录
cd ..
rm -rf LBFAT.git
```

### 方法三：仅迁移当前内容（不含历史）

```bash
# 1. 克隆当前仓库
git clone https://github.com/Zhantongoscar/LBFAT.git Industrial-Logic-Arena
cd Industrial-Logic-Arena

# 2. 移除原始远程地址
git remote remove origin

# 3. 在 GitHub 创建新仓库后，添加新远程地址
git remote add origin https://github.com/Zhantongoscar/Industrial-Logic-Arena.git

# 4. 推送
git push -u origin main
```

---

## 原始项目（LBFAT）说明

**LBFAT** 全称 Leybold Board Function Acceptance Test，是为莱宝真空设备面板功能验收测试设计的自动化测试系统，主要功能包括：

- 测试实例管理（PENDING / RUNNING / COMPLETED / ABORTED 状态机）
- 基于真值表的测试组/测试项管理
- MQTT 通信驱动的硬件指令下发与结果采集
- Vue.js 前端 + Node.js 后端 + MySQL 数据库全栈架构

LBFAT 的核心技术积累（Vue.js 全栈、MQTT 通信、Docker 容器化、MySQL 数据模型）将被完全继承，作为工业逻辑竞技场平台的底层基础设施重新激活。

---

## 联系与贡献

如有问题，请在 GitHub Issues 中提交，或联系项目负责人。

欢迎提交 Pull Request，共同构建这个"让学生为了阴人而主动学习"的工业逻辑竞技场！
