# ArmForge

A mobile-first web app for high school baseball players to track and log their throwing programs.

## Features

- Email/password authentication
- Pre-set interval throwing program schedule
- Log each session: distances, reps, arm feel, and velocity
- View session history and progress over time
- Works on any device — optimized for phones

## Tech Stack

- Vanilla HTML/CSS/JavaScript
- [Supabase](https://supabase.com) — authentication and database
- Hosted on GitHub Pages

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/jbprice2/armforge.git
cd armforge
```

### 2. Configure Supabase

Open `index.html` and replace the placeholder values near the top of the script:

```js
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

### 3. Set up the database

Run the SQL in `schema.sql` inside your Supabase project's **SQL Editor** to create the required tables.

### 4. Deploy

Push to GitHub and enable **GitHub Pages** under Settings → Pages (serve from the `main` branch root).

## License

MIT — see [LICENSE](LICENSE)
