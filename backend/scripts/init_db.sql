-- ============================================
-- NJUXun（南大图寻）数据库初始化脚本
-- 用途：创建数据库和三张核心表
-- 执行方式：mysql -u root -p < init_db.sql
-- ============================================

-- 步骤1：创建数据库
-- CREATE DATABASE = 创建一个新的数据库（相当于新建一个 Excel 文件）
-- IF NOT EXISTS = 如果同名数据库已存在就跳过，防止报错
-- CHARACTER SET utf8mb4 = 使用 utf8mb4 字符集，支持中文和 emoji
-- COLLATE utf8mb4_unicode_ci = 排序规则，ci = case insensitive（不区分大小写）
CREATE DATABASE IF NOT EXISTS njuxun
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 切换到 njuxun 数据库（后续操作都在这个库里进行）
USE njuxun;

-- ============================================
-- 步骤2：创建 users 表（用户表）
-- ============================================
-- 为什么先建 users？因为 game_records 依赖 users 和 locations，
-- 被依赖的表必须先创建
CREATE TABLE users (
    -- PRIMARY KEY: 主键，唯一标识每一行
    -- AUTO_INCREMENT: 自动递增，插入时不用手动填 id，MySQL 自动生成 1,2,3...
    id INT PRIMARY KEY AUTO_INCREMENT,

    -- VARCHAR(100): 最多 100 个字符的变长字符串
    -- NOT NULL: 必须填写，不能为空
    -- UNIQUE: 值必须唯一，不能和别人重复（用户名不能重复）
    username VARCHAR(100) NOT NULL UNIQUE,

    -- UNIQUE: 邮箱也不能重复
    email VARCHAR(255) NOT NULL UNIQUE,

    -- 密码存储（实际项目中应存哈希值，不是明文）
    password VARCHAR(255) NOT NULL,

    -- 累计总分，默认 0
    total_score INT DEFAULT 0,

    -- 玩过的游戏次数，默认 0
    games_played INT DEFAULT 0,
    -- created_at: 记录创建时间
    -- DEFAULT CURRENT_TIMESTAMP: 如果插入时不填，自动取当前时间
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 步骤3：创建 locations 表（地点/题目表）
-- ============================================
-- 注意：✅ 使用 px_x, px_y（像素坐标），非经纬度
-- px_x = 像素横坐标（从左到右，0~7087）
-- px_y = 像素纵坐标（从上到下，0~10630）
CREATE TABLE locations (
    id INT PRIMARY KEY AUTO_INCREMENT,

    -- 地点名称，如"鼓楼校区北大楼"
    name VARCHAR(100) NOT NULL,

    -- TEXT: 长文本类型，放地点描述（不限长度）
    description TEXT,

    -- 像素坐标 X（对应地图图片上的水平位置）
    px_x INT NOT NULL,

    -- 像素坐标 Y（对应地图图片上的垂直位置）
    px_y INT NOT NULL,

    -- 实景照片的文件路径/URL
    image_url VARCHAR(255) NOT NULL,

    -- TINYINT: 小整数（-128~127），难度 1~5，默认 3
    difficulty TINYINT DEFAULT 3,

    -- 区域分类，如"北区"、"南园"、"教学区"等
    area VARCHAR(50),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 步骤4：创建 game_records 表（游戏记录表）
-- ============================================
-- 这是"事实表"——记录每次游戏的结果
-- 通过 FOREIGN KEY 关联 users 和 locations
CREATE TABLE game_records (
    id INT PRIMARY KEY AUTO_INCREMENT,


    -- 外键：引用 users.id，记录是哪个用户玩的
    user_id INT NOT NULL,

    -- 外键：引用 locations.id，记录是哪道题
    location_id INT NOT NULL,

    -- 用户在地图上点击猜测的像素坐标
    guess_px_x INT NOT NULL,
    guess_px_y INT NOT NULL,

    -- 猜测位置与真实位置的实际距离（米）
    -- DECIMAL(10,2): 总共 10 位数字，其中 2 位小数
    -- 例如：12345678.90
    distance_meters DECIMAL(10,2) NOT NULL,

    -- 本次得分
    score INT NOT NULL,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- FOREIGN KEY (本表列) REFERENCES 目标表(目标列)
    -- 作用：保证 user_id 一定对应一个真实存在的用户
    FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,   -- 用户被删除时，他的游戏记录也一起删除

    -- 保证 location_id 一定对应一个真实存在的地点
    FOREIGN KEY (location_id) REFERENCES locations(id)
        ON DELETE RESTRICT   -- 地点被引用时不允许删除，保护数据
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 验证：查看所有创建的表
-- ============================================
SHOW TABLES;

-- 查看每张表的结构
-- DESCRIBE = 显示表的列名、类型、约束等信息
DESCRIBE users;
DESCRIBE locations;
DESCRIBE game_records;
