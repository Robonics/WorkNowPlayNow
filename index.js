require('dotenv').config();
console.log("SUPABASE_ANON_KEY:", process.env.SUPABASE_ANON_KEY);
console.log("ENV CHECK:", process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY ? "KEY_OK" : "KEY_MISSING");
const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors');
const subtasksRouter = require('./routes/subtasks');

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/subtasks', subtasksRouter);
app.set('view engine', 'ejs');
app.set('views', 'views');

app.use('/auth',       require('./routes/auth'));
app.use('/tasks',      require('./routes/tasks'));
app.use('/goals',      require('./routes/goals'));
app.use('/points',     require('./routes/points'));
app.use('/streaks',    require('./routes/streaks'));
app.use('/categories', require('./routes/categories'));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.use((err, req, res, next) => {
  console.error('Global error:', JSON.stringify(err, null, 2));
  console.error('Stack:', err.stack);
  res.status(500).json({ error: 'Something went wrong' });
});

app.listen(process.env.PORT || 8080, () => {
  console.log(`App launched! Go to http://localhost:${process.env.PORT || 8080}/ to see`);
});
