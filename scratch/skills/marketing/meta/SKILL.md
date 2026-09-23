---
name: marketing/meta
status: experimental
trigger: Use when preparing or executing a Meta (Facebook/Instagram) Marketing API ad campaign.
owner: Fred
created_from: Ampgent test ad 01 build, digzoman/ampgent branch wip/meta-ads-api, 2026-09-23
related_skills: []
---

# Meta (Facebook/Instagram) Ads — campaign creation

## Purpose

Concrete, tested learnings from building and launching a real Meta
Marketing API campaign end to end (Ampgent test ad 01: campaign, ad set,
creative, ad, all the way to `ACTIVE`), so future ad-preparation work
(spec writing, no live API access — e.g. ChatGPT) and ad-execution work
(live API calls with real credentials — e.g. Claude) don't repeat the same
mistakes or re-derive the same Meta API field-level details from scratch.

Single real run so far. Revisit and tighten once a second campaign
confirms these hold up, then propose promotion to `procedures/skills/`.

## When to use

- Writing a spec for a new Meta ad campaign (objective, targeting,
  budget, copy, creative).
- Implementing or extending a Meta Marketing API client.
- Actually calling the Meta Marketing API to create/verify
  campaigns, ad sets, creatives, or ads.

## Inputs

- A business-grounded ad spec: objective, targeting, budget/duration,
  exact copy, creative asset. Don't invent these — pull from the
  business's actual positioning/site copy, or get them from a human/agent
  with real business context.
- Meta credentials — see "Credential setup" below.
- Target Page ID, Instagram Business ID, ad account ID for the account
  being advertised.

## Outputs

PAUSED campaign/ad set/creative/ad objects, verified correct, ready for
explicit human activation approval. Do not activate without an explicit
go-ahead — this applies regardless of who asked for "a test ad," since
even small budgets are real spend and go through Meta's ad review under
the business's name.

## Method

### For ad-preparation agents (spec authors without live API access, e.g. ChatGPT)

- **Verify your own diff against every explicit requirement before
  reporting a task complete.** In this run, a prompt explicitly asked for
  two new client functions (`createCampaign`, `createAdSet`); the report
  said "done" but the functions were never actually added — caught only
  at execution time. Diff what you changed against the actual ask, not
  just the parts that were interesting or easy.
- **Flag known one-time manual gates instead of assuming pure API
  automation** — see "A brand-new ad account's first ad" under Failure
  modes. A spec that assumes everything is API-drivable will produce a
  confusing false "it's stuck" report when it hits this.
- **Don't invent exact Meta API field shapes for advanced features**
  (multi-destination messaging, dynamic creative optimization, etc.).
  Meta's own public docs for newer features are often incomplete or
  example-only. Flag these as "verify the real field shape at execution
  time" rather than specifying a schema with false confidence — the
  execution agent has to test against the live API anyway.
- Ground targeting/copy/audience choices in the business's actual
  positioning and existing site copy, not generic ad-copy tropes.

### For execution agents (live API callers with real credentials, e.g. Claude)

- **Use a System User token, not a personal user token, wherever
  possible.** A `SYSTEM_USER` type token (`expires_at: 0`, never expires)
  isn't tied to any human's login session, so it survives password/2FA
  changes — the exact failure mode (`error 190/460`, "session
  invalidated") that made the original credential rebuild necessary in
  the first place.
- **A System User only sees assets inside its own Business Manager.**
  One token per Business Manager, not one universal token across a
  person's whole Meta footprint the way a personal token can. Budget for
  one System User setup per Business Manager the work touches.
- **`instagram_basic` scope is required to read an Instagram Business
  Account node directly, or via a Page's `instagram_business_account`
  field, in some cases.** Without it, a genuinely-linked IG account can
  falsely appear "not linked" via the API even though it works fine in
  Ads Manager and for actual ad delivery. **Do not conclude "not linked"
  from API silence alone** — check Business Manager → Settings →
  Instagram accounts directly before believing that, especially before
  telling a human an account needs to be reconnected.
- **Writing an `instagram_user_id` into an ad creative does not require
  the token to have read access to that ID.** Write and read permissions
  are gated separately. A creative can reference and successfully use an
  IG identity the token can't `GET`.
- **Campaign creation on current API versions requires
  `is_adset_budget_sharing_enabled` (true/false)** when not using
  Advantage+ campaign budget — a newer field not mentioned in older
  references/docs. Set `false` for a plain ad-set-budget campaign.
- **For a "manual" combined Facebook Messenger + Instagram Direct message
  destination**: set `destination_type: MESSAGING_INSTAGRAM_DIRECT_MESSENGER`
  and `promoted_object.page_id` on the **ad set**. The creative itself
  does **not** need the complex `asset_feed_spec` /
  `DOF_MESSAGING_DESTINATION` dynamic-creative structure that Meta's own
  "Click to Multidestination" documentation shows for this — a plain,
  single-CTA `object_story_spec` (the same shape used for a
  single-destination Instagram-only ad, `call_to_action.type:
  "INSTAGRAM_MESSAGE"`) works fine once the ad set's `destination_type`
  is set correctly. The dynamic `asset_feed_spec` approach was tried
  first, following the docs, and it actively broke things — it silently
  corrupted the creative's `link_data.link` field with placeholder
  content that was never submitted.
- **`/generatepreviews` iframe URLs only render correctly in an
  authenticated (logged-in) Facebook browser session.** Opening them in a
  logged-out/headless browser (e.g. a bare Patchright/Playwright session
  with no Facebook login) reliably produces a false **"Ad Incomplete —
  missing required fields"** error that looks exactly like a real
  payload/API bug but isn't — it reproduced even on a creative that had
  already rendered a genuinely working preview earlier in the same
  session. Don't trust "Ad Incomplete" from an unauthenticated preview
  check. Verify instead via: the object's own `effective_status` and
  `issues_info` fields (reliable), or the real Ads Manager UI (Identity /
  Ad setup checkmarks, live preview panel).
- **A brand-new ad account's very first-ever ad needs a one-time human
  action in the Ads Manager UI** (clicking "Publish" and accepting ad
  account terms) that has no API equivalent. The API will report
  `status: ACTIVE` with no errors in `issues_info` while the ad sits
  indefinitely at `effective_status: IN_PROCESS`. If this happens on a
  freshly-activated ad on a new account, ask the human to open Ads
  Manager and look for a "fix error"/Publish prompt before assuming an
  API-side problem.
- **Credential storage convention on this VM**: `/etc/ampgent/secrets/<name>`,
  one token per file, plain text, owned by the operating user (not root),
  mode `600`. Matches the existing convention for other service
  credentials already stored there.

## Evidence requirements

Cite specific object IDs and the branch/commit, not just "it worked."
This run's evidence: `digzoman/ampgent`, branch `wip/meta-ads-api`,
campaign `52548715432364`, ad set `52548715467764`, ad `52548715524564`,
creative `1606579800868457` — confirmed `ACTIVE` and correct via both the
API and the real Ads Manager UI. See `scratch/notes/meta-ads-setup.md` in
that repo for the full run log, including the dead ends.

## Tools and scripts

`digzoman/ampgent`, `scratch/scripts/meta-ads/meta-client.js` — zero-dependency
`fetch`-based Meta Marketing API v22.0 client. Exports `getAdAccounts`,
`getCampaigns`, `getAds`, `getAdInsights`, `getAdAccountInsights`,
`getAllAdsWithInsights`, `uploadImage`, `createCreative`,
`updateAdCreative`, `uploadVideo`, `waitForVideo`, `createVideoCreative`,
`createAd`, `createCampaign`, `createAdSet`. All IDs/tokens are
caller-supplied, nothing hardcoded.

## Failure modes

Quick-reference — symptom → real cause, not the misleading first guess:

| Symptom | Looks like | Actually is |
|---|---|---|
| IG account "not linked" via API (empty `instagram_business_account`) | Account genuinely unlinked | Missing `instagram_basic` scope on the token — check Business Manager UI before concluding this |
| "Ad Incomplete" from `/generatepreviews` | Broken creative payload | Unauthenticated/headless browser rendering the preview iframe — check `effective_status`/`issues_info` or the real Ads Manager UI instead |
| Ad stuck at `effective_status: IN_PROCESS` indefinitely, no errors | API bug or stuck review | First-ad-on-a-new-account terms acceptance gate — needs a human to click Publish once in the UI |
| Campaign creation fails, "Invalid parameter" | Wrong objective/budget field | Missing `is_adset_budget_sharing_enabled` |
| Creative accepted at creation time but silently wrong `link` field | — | Using `call_to_action.type: "MESSAGE_PAGE"` combined with `asset_feed_spec`/`DOF_MESSAGING_DESTINATION` — use the simple single-CTA structure instead |

## Learnings / evolution

- **2026-09-23** — skill created from the Ampgent test ad 01 build
  (digzoman/ampgent, branch `wip/meta-ads-api`). First real run. All
  learnings above are from this single campaign build; treat the specific
  field-level claims as strong hints, not guaranteed-stable API contracts
  — Meta's Marketing API changes field requirements across versions
  (e.g. `is_adset_budget_sharing_enabled` itself is evidence of this).
