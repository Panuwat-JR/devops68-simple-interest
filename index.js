const express = require('express');
const app = express();

app.get('/calculate', (req, res) => {
  const { principal, rate, time } = req.query;
  if (!principal || !rate || !time) return res.status(400).json({ error: 'Missing parameters' });
  
  const p = parseFloat(principal);
  const r = parseFloat(rate);
  const t = parseFloat(time);
  
  if (isNaN(p) || isNaN(r) || isNaN(t)) return res.status(400).json({ error: 'All parameters must be numbers' });
  
  const interest = (p * r * t) / 100;
  const total = p + interest;
  
  res.json({ principal: p, rate: r, time: t, simpleInterest: Math.round(interest * 100) / 100, total: Math.round(total * 100) / 100 });
});

app.listen(3019, () => console.log('Simple Interest API on port 3019'));
