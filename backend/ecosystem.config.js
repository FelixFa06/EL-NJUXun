// PM2 进程管理配置
// 使用: pm2 start ecosystem.config.js
// 文档: https://pm2.keymetrics.io/

module.exports = {
  apps: [
    {
      name: 'njuxun',
      cwd: './',
      script: 'app.js',
      // 监听文件变化自动重启（开发时开启，稳定后关闭）
      watch: false,
      // 忽略监听的文件
      ignore_watch: ['node_modules', 'public', '../frontend'],
      // 实例数（单实例即可）
      instances: 1,
      // 内存超限自动重启
      max_memory_restart: '300M',
      // 环境变量
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      // 日志配置
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      // 崩溃自动重启
      autorestart: true,
      // 启动失败重试
      max_restarts: 10,
      restart_delay: 2000,
    },
  ],
};
