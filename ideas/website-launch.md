# TODO: decide whether to add a website launch checklist

Status: **idea, not started.** Captured 2026-10-12. Do it when a real
project is about to launch a public website.

## The idea

Add a pre-launch checklist for public websites to the template.

## What already exists

- `docs/15-accessibility.md`: alt text, color contrast.
- `docs/14-security.md`: secrets and input validation (in general terms).
- Nothing on legal pages, SEO, performance, analytics or launch polish.

## Proposal

An optional doc (e.g. "Website launch"), marked `Not needed` in
`AGENTS.md` when the project isn't a website, like the other optional
docs. It links to `14` and `15` for items they already cover instead of
repeating them. Possibly a `/launch-check` skill later, like
`/security-check` and `/a11y-check`.

## Draft checklist

**Legal and trust**
- [ ] Privacy policy page: what data is collected and why (needed once
      anything is collected, including analytics or form emails)
- [ ] Terms and conditions page (mainly if selling or user accounts)
- [ ] Cookie consent banner before non-essential cookies (EU/UK); may be
      unnecessary with no cookies or cookie-free analytics

**Security**
- [ ] No secrets in frontend code: anything sent to the browser is public;
      private keys stay on a server
- [ ] HTTPS forced (http redirects to https)
- [ ] Forms validated in the browser *and* on the server
- [ ] Spam protection on forms (CAPTCHA, honeypot field, or rate limit)

**Search and sharing**
- [ ] Unique meta title and description per page
- [ ] Social preview image (Open Graph tags)
- [ ] Favicon
- [ ] `sitemap.xml` and `robots.txt`

**Accessibility and design** (see `15-accessibility.md`)
- [ ] Alt text on meaningful images
- [ ] Color contrast at least 4.5:1
- [ ] Mobile friendly: no sideways scrolling, tap targets big enough

**Performance**
- [ ] Images compressed, right size, modern format (e.g. WebP)
- [ ] Page speed checked with Lighthouse or PageSpeed Insights

**Polish**
- [ ] Custom 404 page with a link home
- [ ] No broken links (run a link checker)
- [ ] Analytics set up (ties to privacy policy and cookie consent)
- [ ] One clear call to action per page

**Added (not on the original list)**
- [ ] Custom domain and DNS set up; HTTPS certificate renews automatically
- [ ] Error monitoring, so breakages are noticed
- [ ] Backups, if the site stores data
- [ ] Every form tested end to end: submissions actually arrive

## Open questions

- Which upcoming project is the first public website? Build the doc
  against that one, not in the abstract.
- One doc, or fold the security items into `14-security.md` and keep only
  the rest in the launch doc?
