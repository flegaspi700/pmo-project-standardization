# TODO: decide whether to add a legal and compliance doc

Status: **idea, not started.** Captured 2026-10-12. Do it when a real
project will have users' personal data, EU/UK users, payments, or public
code. Get a lawyer or a reputable policy generator before launching
anything that handles real users' data or money; this doc is a checklist,
not legal advice.

## The idea

Add guidance on the legal and compliance side of running a product with
users: privacy policy, terms and conditions, GDPR, cookie consent, legal
basis, marketing consent, data deletion, data retention, data processing
agreements, third-party disclosure, data security, data breach procedure,
intellectual property, open-source license, payments and subscriptions.

## What already exists

- `docs/14-security.md` → Privacy: a short section (collect only what's
  needed, no personal data in logs).
- `docs/00-vision.md` and `docs/16-budget.md` mention licensing in passing.
- Nothing else.

## Overlap with other ideas

- `security-docs.md` covers **data security** (encryption, backups,
  access).
- `website-launch.md` lists the **privacy policy, terms and cookie
  consent pages** as launch items.

Design all three together so each topic lives in one place and the
others link to it.

## Proposal

An optional "Legal and compliance" doc, marked `Not needed` in
`AGENTS.md` when it doesn't apply. Each section opens with an "n/a if…"
line (no personal data / no EU or UK users / no payments / closed
source).

The core is a **data inventory** table; the privacy policy, retention and
deletion rules all come from it:

| Data | Why we need it | Legal basis | Kept for | Deleted how | Shared with (DPA?) |
|---|---|---|---|---|---|
| <e.g. email address> | <account login> | <contract> | <until account closed + 30 days> | <account deletion job> | <email provider (DPA accepted)> |

## Draft checklist

**Policies users see**
- [ ] Privacy policy: what's collected, why, who it's shared with, how
      long it's kept, how users see or delete it
- [ ] Terms and conditions: acceptable use, liability, disputes,
      account closure
- [ ] Cookie consent before non-essential cookies; refusing is as easy
      as accepting

**GDPR** (applies if any users are in the EU/UK; similar laws elsewhere,
e.g. CCPA)
- [ ] Legal basis named for each kind of data (consent, contract, legal
      obligation, legitimate interest)
- [ ] Marketing consent is separate and opt-in (no pre-ticked boxes);
      every email has an unsubscribe link
- [ ] Data deletion works on request, including backups and third-party
      tools
- [ ] Retention period set for each kind of data, with something that
      enforces it

**Third parties**
- [ ] DPA accepted with every service that handles personal data (host,
      email, analytics…)
- [ ] Every such service listed in the privacy policy

**Security and incidents**
- [ ] Data security in place (see `security-docs.md`)
- [ ] Written breach procedure: contain, assess, notify the authority
      within 72 hours (GDPR), tell affected users if the risk is high

**Ownership**
- [ ] Rights confirmed for all fonts, images, music and other assets
- [ ] Ownership of user-uploaded content stated in the terms
- [ ] License chosen for the project's own code (MIT, Apache, GPL…)
- [ ] Dependency licenses checked for obligations (e.g. GPL)

**Payments and subscriptions**
- [ ] Payment processor used (e.g. Stripe, Paddle); card data never
      touches our servers
- [ ] Clear pricing, refund and cancellation terms
- [ ] Sales tax / VAT handled
- [ ] Auto-renewal disclosed; cancelling is as easy as signing up

## Open questions

- Which upcoming project first needs this (personal data, EU users,
  payments, or public code)? Build against that one.
- One combined doc with `website-launch.md`, or separate? Legal applies
  to non-website products too (apps, APIs), which argues for separate.
