const mysql = require('mysql2/promise');

/**
 * MySQL 数据库连接池
 *
 * 从 .env 读取配置，创建 mysql2 连接池实例。
 * 连接池维护一组长连接，复用连接避免频繁创建/销毁，
 * 通过 connectionLimit 限制最大并发连接数。
 *
 * 环境变量（均在 .env 中配置）：
 *   DB_HOST      — 数据库主机地址，默认 localhost
 *   DB_PORT      — 数据库端口，默认 3306
 *   DB_NAME      — 数据库名，默认 njuxun
 *   DB_USER      — 数据库用户名，默认 root
 *   DB_PASSWORD  — 数据库密码
 */

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 3306,
  database: process.env.DB_NAME || 'njuxun',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;
