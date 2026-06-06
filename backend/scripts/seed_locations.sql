-- ============================================
-- NJUXun 地点种子数据
-- 从 locations.json 迁移而来，24 个校园实景地点
-- 执行方式：mysql -u root -p njuxun < seed_locations.sql
-- ============================================

USE njuxun;

INSERT INTO locations (name, px_x, px_y, image_url, area, difficulty) VALUES
('e1',  1776, 1985, '/images/e1.jpg',  '东区', 3),
('e2',  1593, 1584, '/images/e2.jpg',  '东区', 3),
('e3',  1095, 1600, '/images/e3.jpg',  '东区', 3),
('e4',  1235, 1757, '/images/e4.jpg',  '东区', 3),
('e5',   929, 1118, '/images/e5.jpg',  '东区', 3),
('e6',   987, 1042, '/images/e6.jpg',  '东区', 3),
('e7',  1413,  905, '/images/e7.jpg',  '东区', 3),
('e8',  1248,  879, '/images/e8.jpg',  '东区', 3),
('e9',  1483, 1283, '/images/e9.jpg',  '东区', 3),
('e10', 1782, 1224, '/images/e10.jpg', '东区', 3),
('e11', 1871, 2332, '/images/e11.jpg', '东区', 3),
('h1',  1566, 1329, '/images/h1.jpg',  '核心区', 3),
('h2',  1892, 1675, '/images/h2.jpg',  '核心区', 3),
('h3',  1941, 1831, '/images/h3.jpg',  '核心区', 3),
('h4',  1980, 2024, '/images/h4.jpg',  '核心区', 3),
('m1',  1376, 1733, '/images/m1.jpg',  '中区', 3),
('m2',  1343, 1668, '/images/m2.jpg',  '中区', 3),
('m3',   987, 1277, '/images/m3.jpg',  '中区', 3),
('m4',   929,  931, '/images/m4.jpg',  '中区', 3),
('m5',  1477, 1153, '/images/m5.jpg',  '中区', 3),
('m6',   929, 1061, '/images/m6.jpg',  '中区', 3),
('m7',   891,  819, '/images/m7.jpg',  '中区', 3),
('m8',  1968, 1485, '/images/m8.jpg',  '中区', 3),
('m9',  1852, 2170, '/images/m9.jpg',  '中区', 3);

-- 验证导入
SELECT COUNT(*) AS total_locations FROM locations;
SELECT * FROM locations;
