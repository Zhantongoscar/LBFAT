const db = require('../utils/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const VALID_ROLES = ['admin', 'user'];
const VALID_STATUSES = ['active', 'inactive'];

const userController = {
    // 用户登录
    async login(req, res) {
        try {
            const { username, password } = req.body;
            console.log('收到登录请求:', { username });
            
            // 参数验证
            if (!username || !password) {
                console.log('参数验证失败：用户名或密码为空');
                return res.status(400).json({
                    code: 400,
                    message: '用户名和密码不能为空'
                });
            }

            // 查询用户
            const sql = 'SELECT * FROM users WHERE username = ? AND status = "active"';
            console.log('执行SQL查询:', { sql, username });
            const [user] = await db.query(sql, [username]);
            console.log('查询结果:', { found: !!user, role: user?.role });

            if (!user) {
                console.log('用户不存在或状态不是active');
                return res.status(401).json({
                    code: 401,
                    message: '用户名或密码错误'
                });
            }

            // 验证密码
            const isValid = password === user.password;
            console.log('密码验证:', { isValid });
            if (!isValid) {
                console.log('密码验证失败');
                return res.status(401).json({
                    code: 401,
                    message: '用户名或密码错误'
                });
            }

            // 生成 JWT token
            const token = jwt.sign(
                { 
                    id: user.id,
                    username: user.username,
                    role: user.role
                },
                JWT_SECRET,
                { expiresIn: '24h' }
            );
            console.log('生成JWT token成功');

            // 返回用户信息和token
            const responseData = {
                code: 200,
                message: '登录成功',
                data: {
                    token,
                    user: {
                        id: user.id,
                        username: user.username,
                        display_name: user.display_name,
                        email: user.email,
                        role: user.role
                    }
                }
            };
            console.log('返回登录响应:', responseData);
            res.json(responseData);
        } catch (error) {
            console.error('登录失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message || '登录失败'
            });
        }
    },

    // 获取当前用户信息
    async getCurrentUser(req, res) {
        try {
            const userId = req.user.id; // 从 JWT 中获取
            
            const sql = `
                SELECT id, username, display_name, email, role, status, created_at, updated_at 
                FROM users 
                WHERE id = ?
            `;
            
            const [user] = await db.query(sql, [userId]);
            
            if (!user) {
                return res.status(404).json({
                    code: 404,
                    message: '用户不存在'
                });
            }

            res.json({
                code: 200,
                message: 'success',
                data: user
            });
        } catch (error) {
            console.error('获取当前用户信息失败:', error);
            res.status(500).json({
                code: 500,
                message: error.message || '获取当前用户信息失败'
            });
        }
    },

    // 获取所有用户
    async getAllUsers(req, res) {
        try {
            console.log('=== 开始获取用户列表 ===');
            console.log('请求头:', req.headers);
            console.log('请求参数:', req.query);

            const sql = `
                SELECT id, username, display_name, email, role, status, created_at, updated_at 
                FROM users 
                ORDER BY created_at DESC
            `;
            console.log('准备执行SQL查询:', { sql });

            const users = await db.query(sql);
            console.log('查询结果:', users);
            console.log(`获取到 ${users.length} 个用户`);
            
            res.json({
                code: 200,
                message: 'success',
                data: users
            });
        } catch (error) {
            console.error('获取用户列表失败:', error);
            console.error('错误堆栈:', error.stack);
            res.status(500).json({
                code: 500,
                message: error.message || '获取用户列表失败'
            });
        }
    },

    // 获取单个用户
    async getUser(req, res) {
        try {
            const { id } = req.params;
            console.log('获取用户详情, ID:', id);

            const sql = `
                SELECT id, username, display_name, email, role, status, created_at, updated_at 
                FROM users 
                WHERE id = ?
            `;
            console.log('准备执行SQL查询:', { sql, params: [id] });

            const [user] = await db.query(sql, [id]);
            console.log('查询结果:', user);
            
            if (!user) {
                console.log('用户不存在, ID:', id);
                return res.status(404).json({
                    code: 404,
                    message: '用户不存在'
                });
            }

            res.json({
                code: 200,
                message: 'success',
                data: user
            });
        } catch (error) {
            console.error('获取用户信息失败:', error);
            console.error('错误堆栈:', error.stack);
            res.status(500).json({
                code: 500,
                message: error.message || '获取用户信息失败'
            });
        }
    },

    // 创建用户
    async createUser(req, res) {
        try {
            const { username, display_name, email, password, role = 'user', status = 'active' } = req.body;
            console.log('创建用户请求:', { username, display_name, email, role, status });
            
            // 参数验证
            if (!username || !password) {
                return res.status(400).json({
                    code: 400,
                    message: '用户名和密码不能为空'
                });
            }

            // 验证角色
            if (!VALID_ROLES.includes(role)) {
                return res.status(400).json({
                    code: 400,
                    message: `无效的角色值，必须是以下之一: ${VALID_ROLES.join(', ')}`
                });
            }

            // 验证状态
            if (!VALID_STATUSES.includes(status)) {
                return res.status(400).json({
                    code: 400,
                    message: `无效的状态值，必须是以下之一: ${VALID_STATUSES.join(', ')}`
                });
            }

            // 检查用户名是否已存在
            const checkSql = 'SELECT id FROM users WHERE username = ?';
            console.log('检查用户名:', { sql: checkSql, params: [username] });
            const existingUsers = await db.query(checkSql, [username]);
            
            if (existingUsers.length > 0) {
                console.log('用户名已存在:', username);
                return res.status(400).json({
                    code: 400,
                    message: '用户名已存在'
                });
            }

            // 对密码进行加密
            // const hashedPassword = await bcrypt.hash(password, 10);
            // console.log('密码加密完成');
            console.log('使用明文密码');

            const sql = `
                INSERT INTO users (username, display_name, email, password, role, status) 
                VALUES (?, ?, ?, ?, ?, ?)
            `;
            
            const params = [username, display_name, email, password, role, status];
            console.log('准备执行SQL插入:', { 
                sql, 
                params: params.map((p, i) => i === 3 ? '******' : p) 
            });

            const result = await db.query(sql, params);
            console.log('插入结果:', result);

            res.status(201).json({
                code: 200,
                message: '用户创建成功',
                data: {
                    id: result.insertId,
                    username,
                    display_name,
                    email,
                    role,
                    status
                }
            });
        } catch (error) {
            console.error('创建用户失败:', error);
            console.error('错误堆栈:', error.stack);
            res.status(500).json({
                code: 500,
                message: error.message || '创建用户失败'
            });
        }
    },

    // 更新用户
    async updateUser(req, res) {
        try {
            const { id } = req.params;
            const { display_name, email, role, status, password } = req.body;
            console.log('更新用户请求:', { id, display_name, email, role, status });
            
            // 验证角色
            if (role && !VALID_ROLES.includes(role)) {
                return res.status(400).json({
                    code: 400,
                    message: `无效的角色值，必须是以下之一: ${VALID_ROLES.join(', ')}`
                });
            }

            // 验证状态
            if (status && !VALID_STATUSES.includes(status)) {
                return res.status(400).json({
                    code: 400,
                    message: `无效的状态值，必须是以下之一: ${VALID_STATUSES.join(', ')}`
                });
            }
            
            let sql = `
                UPDATE users 
                SET display_name = ?, 
                    email = ?
            `;
            const params = [display_name, email];

            if (role) {
                sql += ', role = ?';
                params.push(role);
            }
            
            if (status) {
                sql += ', status = ?';
                params.push(status);
            }

            if (password) {
                // const hashedPassword = await bcrypt.hash(password, 10);
                sql += ', password = ?';
                params.push(password);
            }

            sql += ' WHERE id = ?';
            params.push(id);

            console.log('准备执行SQL更新:', { 
                sql, 
                params: params.map(p => typeof p === 'string' && p.startsWith('$2b$') ? '******' : p)
            });
            await db.query(sql, params);

            // 获取更新后的用户信息
            const selectSql = `
                SELECT id, username, display_name, email, role, status, created_at, updated_at 
                FROM users 
                WHERE id = ?
            `;
            console.log('获取更新后的用户:', { sql: selectSql, params: [id] });
            const [updatedUser] = await db.query(selectSql, [id]);
            console.log('更新后的用户信息:', updatedUser);

            res.json({
                code: 200,
                message: '用户更新成功',
                data: updatedUser
            });
        } catch (error) {
            console.error('更新用户失败:', error);
            console.error('错误堆栈:', error.stack);
            res.status(500).json({
                code: 500,
                message: error.message || '更新用户失败'
            });
        }
    },

    // 删除用户
    async deleteUser(req, res) {
        try {
            const { id } = req.params;
            console.log('删除用户请求:', { id });

            const sql = 'DELETE FROM users WHERE id = ?';
            console.log('准备执行SQL删除:', { sql, params: [id] });
            await db.query(sql, [id]);
            
            res.json({
                code: 200,
                message: '用户删除成功'
            });
        } catch (error) {
            console.error('删除用户失败:', error);
            console.error('错误堆栈:', error.stack);
            res.status(500).json({
                code: 500,
                message: error.message || '删除用户失败'
            });
        }
    }
};

module.exports = userController; 