const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./src/routes/authRoutes');
const eventRoutes = require('./src/routes/eventRoutes');
const attendeeRoutes = require('./src/routes/attendeeRoutes');
const ticketRoutes = require('./src/routes/ticketRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const organizerRoutes = require('./src/routes/organizerRoutes');
const { recommendWithNodeFallback } = require('./scripts/nodeRecommendationFallback');
const { recommendWithLightFM } = require('./scripts/lightfmRecommendations');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/attendee', attendeeRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/organizer', organizerRoutes);

app.get('/', (req, res) => {
    res.json({
        message: 'Jadwal API is running',
        recommendations: 'http://localhost:3000/recommendations'
    });
});

app.get('/api/recommendations-demo', async (req, res) => {
    try {
        const { attendee_id, limit } = req.query;
        const result = recommendWithLightFM(attendee_id, limit);
        res.json(result);
    } catch (error) {
        try {
            const { attendee_id, limit } = req.query;
            const fallback = await recommendWithNodeFallback(attendee_id, limit);
            res.json({
                ...fallback,
                warning: error.message
            });
        } catch (fallbackError) {
            res.status(500).json({ error: fallbackError.message });
        }
    }
});

app.get('/recommendations', (req, res) => {
    res.type('html').send(`
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Jadwal Recommendations</title>
  <style>
    :root { color-scheme: dark; font-family: Arial, sans-serif; }
    body { margin: 0; background: #10160f; color: #f5f7f2; }
    main { max-width: 900px; margin: 0 auto; padding: 32px 20px; }
    h1 { margin: 0 0 18px; font-size: 32px; }
    form { display: flex; gap: 10px; margin-bottom: 22px; flex-wrap: wrap; }
    input { flex: 1 1 340px; padding: 12px 14px; border: 1px solid #384232; border-radius: 8px; background: #182016; color: white; }
    button { padding: 12px 16px; border: 0; border-radius: 8px; background: #9cff00; color: #10160f; font-weight: 700; cursor: pointer; }
    .meta { color: #bac5b5; margin-bottom: 16px; }
    .grid { display: grid; gap: 12px; }
    .card { border: 1px solid #283323; border-radius: 8px; background: #172016; padding: 16px; }
    .row { display: flex; justify-content: space-between; gap: 12px; align-items: start; }
    .rank { color: #9cff00; font-weight: 800; }
    .name { font-size: 20px; font-weight: 800; margin: 0 0 8px; }
    .details, .id { color: #b7c4b0; font-size: 14px; }
    .score { color: #9cff00; font-weight: 700; white-space: nowrap; }
    .error { color: #ff8c8c; white-space: pre-wrap; }
  </style>
</head>
<body>
  <main>
    <h1>Jadwal Recommendations</h1>
    <form id="form">
      <input id="attendeeId" name="attendee_id" placeholder="Attendee ID optional" />
      <button type="submit">Load</button>
    </form>
    <div id="meta" class="meta">Loading recommendations...</div>
    <div id="results" class="grid"></div>
  </main>
  <script>
    const form = document.getElementById('form');
    const input = document.getElementById('attendeeId');
    const meta = document.getElementById('meta');
    const results = document.getElementById('results');

    async function loadRecommendations(attendeeId = '') {
      meta.textContent = 'Loading recommendations...';
      results.innerHTML = '';

      const query = attendeeId ? '?attendee_id=' + encodeURIComponent(attendeeId) : '';
      const response = await fetch('/api/recommendations-demo' + query);
      const payload = await response.json();

      if (!response.ok) {
        throw new Error(payload.error || 'Failed to load recommendations');
      }

      input.value = payload.attendeeId || '';
      meta.textContent = 'Showing recommendations for attendee ' + payload.attendeeId + ' using ' + payload.source + ' scoring.';

      if (!payload.recommendations.length) {
        results.innerHTML = '<div class="card">No recommendable approved events found.</div>';
        return;
      }

      results.innerHTML = payload.recommendations.map((event) => \`
        <article class="card">
          <div class="row">
            <div>
              <div class="rank">#\${event.rank}</div>
              <p class="name">\${escapeHtml(event.event_name || '(Untitled event)')}</p>
              <div class="details">\${escapeHtml(event.category || 'Unknown category')} | \${escapeHtml(event.city || 'Unknown city')} | SAR \${Number(event.price || 0)}</div>
              <div class="id">event_id: \${escapeHtml(event.event_id || '')}</div>
            </div>
            <div class="score">\${Number(event.score || 0).toFixed(3)}</div>
          </div>
        </article>
      \`).join('');
    }

    function escapeHtml(value) {
      return String(value).replace(/[&<>"']/g, (char) => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
      }[char]));
    }

    form.addEventListener('submit', (event) => {
      event.preventDefault();
      loadRecommendations(input.value.trim()).catch((error) => {
        meta.textContent = 'Could not load recommendations';
        results.innerHTML = '<div class="card error">' + escapeHtml(error.message) + '</div>';
      });
    });

    loadRecommendations().catch((error) => {
      meta.textContent = 'Could not load recommendations';
      results.innerHTML = '<div class="card error">' + escapeHtml(error.message) + '</div>';
    });
  </script>
</body>
</html>
    `);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = app;
