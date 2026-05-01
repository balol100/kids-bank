# בנק הילדים — Kids Bank

אפליקציית חינוך פיננסי לילדים — מעקב אחרי חיסכון, דמי כיס, הכנסות והוצאות עבור כל ילד במשפחה.

A Hebrew-first, RTL kids' financial education app built as a single static HTML file backed by Supabase.

## Features

- 🔐 PIN-based family login (4-6 digits) with sign-up flow
- 👨‍👩‍👧 Multiple children per family with custom emoji avatar + color
- 💰 Deposits / withdrawals with required description, optional notes, date picker
- 🏷️ 11 built-in categories + custom user categories
- 📅 Balance-at-date — see what each child had on any historical day
- 📊 Full history with filters (date range, child, type, category)
- ⚙️ Settings — change PIN, edit family info, manage categories
- ♿ Accessibility panel with 11 controls (Israeli standard 5568)
- 📱 Mobile-first, dark theme, RTL Hebrew throughout

## Stack

- **Frontend**: Single `index.html` — vanilla JS + inline CSS, no build step
- **Backend**: Supabase (Postgres + REST + RPC) — anon key, security via family PIN
- **Hosting**: Netlify-ready (`netlify.toml` included with CSP + caching headers)

## Local development

Just open `index.html` in a browser, or serve the folder:

```bash
python -m http.server 8000
```

The app talks directly to Supabase from the browser.

## Database schema

See `schema.sql` for the full schema. Tables: `families`, `children`, `categories`, `transactions`. Plus the `get_balance_at_date(child_id, date)` RPC.

## Deploy

Push to a Netlify-connected repo. The included `netlify.toml` provides:
- SPA fallback (`/* → /index.html`)
- Strict CSP allowing only the configured Supabase project
- Long-lived cache for static assets

---

פותח על ידי [lior_Ai](https://lior-ai.com)
