-- ============================================
-- NJUXun 新增照片数据库同步脚本
-- 新增 26 张照片（e13-e18, h6-h14, m11-m21）
-- 执行方式：mysql -u root -p njuxun < add_new_locations.sql
-- ============================================

USE njuxun;

INSERT INTO locations (name, px_x, px_y, image_url, area, difficulty) VALUES
('e13',  913, 1393, '/images/e13.jpg',  '东区', 3),
('e14', 1828, 2501, '/images/e14.jpg',  '东区', 3),
('e15', 1614, 2756, '/images/e15.jpg',  '东区', 3),
('e16', 1477, 1091, '/images/e16.jpg',  '东区', 3),
('e17', 1668, 1527, '/images/e17.jpg',  '东区', 3),
('e18', 2054, 1967, '/images/e18.jpg',  '东区', 3),
('h6',  1019,  972, '/images/h6.jpg',   '核心区', 3),
('h7',   996, 1195, '/images/h7.jpg',   '核心区', 3),
('h8',   979, 1279, '/images/h8.jpg',   '核心区', 3),
('h9',  1940, 3082, '/images/h9.jpg',   '核心区', 3),
('h10', 1287, 1957, '/images/h10.jpg',  '核心区', 3),
('h11', 1435, 1913, '/images/h11.jpg',  '核心区', 3),
('h12', 1543, 1875, '/images/h12.jpg',  '核心区', 3),
('h13', 1711, 3047, '/images/h13.jpg',  '核心区', 3),
('h14', 1677, 1147, '/images/h14.jpg',  '核心区', 3),
('m11', 1490, 2020, '/images/m11.jpg',  '中区', 3),
('m12', 2091, 2075, '/images/m12.jpg',  '中区', 3),
('m13', 1780, 2295, '/images/m13.jpg',  '中区', 3),
('m14', 1733, 2949, '/images/m14.jpg',  '中区', 3),
('m15', 1601, 2664, '/images/m15.jpg',  '中区', 3),
('m16', 1643, 3014, '/images/m16.jpg',  '中区', 3),
('m17', 1753, 2635, '/images/m17.jpg',  '中区', 3),
('m18', 1656, 2942, '/images/m18.jpg',  '中区', 3),
('m19', 1638, 2838, '/images/m19.jpg',  '中区', 3),
('m20', 1501, 1829, '/images/m20.jpg',  '中区', 3),
('m21', 1426, 1878, '/images/m21.jpg',  '中区', 3);

SELECT COUNT(*) AS total_locations FROM locations;
