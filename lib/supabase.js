require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

module.exports = createClient(process.env.DATABASE, process.env.DATABASE_KEY);
