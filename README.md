# Chess Club ENS: setup

GitHub Pages hosts the website (`index.html`). GitHub cannot host a database, so the data and the logins live in a free Supabase project; `schema.sql` in this repo lets you rebuild it at any time.

## Steps
1. **Supabase**: create a new project (the free plan allows 2 active projects).
   Authentication → Email provider: turn **off** "Confirm email" (accounts use usernames, not real emails) and set the **minimum password length to 8**. The menu names change from time to time.
2. **Database**: SQL Editor → paste all of `schema.sql` → Run.
3. **Admin account, before publishing the site**: Authentication → Users → Add user →
   email `admin@chess-ens.club`, a strong password, tick "Auto confirm user". Students log in with usernames; the admin logs in with the username `admin` and this password.
4. **Keys**: Project Settings → API. Copy the Project URL and the `anon` (or "publishable") key into the two constants at the top of the script in `index.html` (`SB_URL`, `SB_KEY`). Never put the `service_role` key anywhere in the repo.
5. **GitHub**: create a public repository, upload `index.html` (and these files), then Settings → Pages → Deploy from branch `main`, folder `/ (root)`.
6. **Test**: log in as `admin` and post a lesson; in a private window create a student account and start a game.

## Things to know
- **Admin password**: Supabase rejects passwords shorter than 6 characters by default, so `admin` is refused. It would also let anyone who finds the site post as the club president. Choose a strong password, and use the "Password" button in the header to change it later.
- **Resetting a student's password or deleting an account**: Supabase dashboard → Authentication → Users.
- **Free plan**: a project with no activity for a week is paused (restore it with one click in the dashboard) and there are no automatic backups. Export the tables now and then.
- **Fair play**: access rules protect the data, but chess moves are not checked on the server; this is built for a trusting club.
- **Privacy**: accounts hold only a username and a hashed password. Ask students not to use their full real names.
