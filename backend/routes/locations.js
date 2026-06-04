const express = require('express');
const router = express.Router();

module.exports = function(pool) {
  // GET /api/locations/random — 随机获取一个地点（支持排除已选题目）
  router.get('/locations/random', async (req, res) => {
    try {
      const excludeRaw = req.query.exclude || '';
      const excludeIds = excludeRaw
        ? excludeRaw.split(',').map(Number).filter(id => !isNaN(id) && id > 0)
        : [];

      let rows;
      if (excludeIds.length > 0) {
        const placeholders = excludeIds.map(() => '?').join(',');
        const sql = `SELECT * FROM locations WHERE id NOT IN (${placeholders}) ORDER BY RAND() LIMIT 1`;
        [rows] = await pool.query(sql, excludeIds);
      } else {
        [rows] = await pool.query('SELECT * FROM locations ORDER BY RAND() LIMIT 1');
      }

      if (rows.length === 0) {
        return res.status(404).json({ error: 'No locations available' });
      }

      res.json(rows[0]);
    } catch (err) {
      console.error('Error fetching random location:', err);
      res.status(500).json({ error: 'Database error' });
    }
  });

  return router;
};
