---
name: design-polish
description: >-
  Iterate on a Candela page's design with a headless-browser screenshot loop.
  Use when asked to polish, redesign, or overhaul the look and UX of a page:
  bypass local auth, screenshot the page at desktop and mobile widths, critique
  against the design principles, rework the components, and repeat until
  polished. Triggers on: design overhaul, design polish, redesign this page,
  screenshot loop, make it beautiful, UX pass.
---

# Design polish loop

Rework a page's design by looking at it, not by guessing. Screenshot, critique
against the written principles, edit, re-screenshot. Repeat until it reads
well, then prove the page is back behind auth and ship.

## When to use

- "Overhaul / polish / redesign the design of page X"
- Any task whose acceptance is "looks right" rather than a behavior change

## Required mock-first gate

For a single full-page improvement pass, do not start in React.

1. Read the live page structure, design docs, and any visual reference.
2. Author one complete static HTML/CSS mock using representative real content
   and the product's actual tokens, type, actions, and states.
3. Open the mock in the user's browser and stop for review. Iterate on the mock
   until the user explicitly approves it.
4. Only then implement the approved design in the real app and begin the
   screenshot loop below.

The mock is a design decision surface, not throwaway decoration. It must show
all major regions and the primary task at the target desktop viewport. Do not
edit production React while the mock is under review.

## Setup

1. Local stack up: from `candela-infra`, `dev up hiring` (or the app that owns
   the page). Hiring is http://localhost:3000, admin 3001, eval 3002,
   match 3003, cms 1337.
2. Seeded data: the demo company (`candela-demo`) has a published role with
   packs. To exercise a draft wizard, clone the role:
   `curl -s -X POST http://localhost:3000/api/hiring/roles/<id>/clone`.

## Temporary local auth bypass (candela-orchestrator)

Never commit this. Revert before the PR.

1. Code, in the repo (one throwaway commit is fine, drop it before the PR):
   - New `lib/auth/local-bypass.ts`: export `localAuthBypassUser()` returning
     `{ id, email }` only when `process.env.CANDELA_LOCAL_AUTH_BYPASS === "1"`
     AND `process.env.NODE_ENV !== "production"`. The id must be the seeded
     employer's bound `auth_user_id` (query `people`; email-only fallback hits
     `auth_identity_conflict` when the person row is already bound).
   - `lib/auth/session.ts` `readAuthUser`: return the bypass user first.
   - `lib/supabase/middleware.ts` `updateSession`: early
     `return NextResponse.next({ request })` when the bypass is active.
   - A small unit test: off by default, on with the flag outside production,
     off in production even with the flag.
2. Infra: add `CANDELA_LOCAL_AUTH_BYPASS: "1"` to the service's `environment`
   in `candela-infra/local/compose.yaml` (leave uncommitted), then
   `dev up <app>` to recreate the container.
3. Verify: `curl -s -o /dev/null -w '%{http_code}' <page-url>` returns `200`
   with no session cookie.

## The loop

1. Screenshot every state of the page at both widths:

   ```bash
   node ~/.pi/agent/skills/design-polish/scripts/screenshot.mjs /tmp/design-loop/iterN <url> [url...]
   # custom widths: --viewport 1440x900 --viewport 390x844
   ```

   The script grows the viewport to the document height (app shells defeat
   `fullPage`), and names files from path + query + viewport. Read the PNGs
   with pi's `read` tool.

2. Critique against the principles, in this order:
   - `candela-ui/docs/principles.md`: one document not a dump; rhythm over
     hairlines; hover is the contract; chapters; shape then detail; expand in
     place; number as mark; never a broken chart; product names only.
   - The owning repo's `DESIGN.md` (candela-orchestrator has one; its gold
     standard is `/roles` and the candidate report).
   - UX basics: first-glance comprehension, balanced columns or none, actions
     where the reader needs them, no dead whitespace, mobile order matches
     desktop hierarchy.
   - Copy: no sentence repeated on the page, no positional words ("below")
     that the layout contradicts.
3. Rework the components. Keep behavior hooks (state, API calls) untouched;
   restructure layout and presentation. Keep tests green; update assertions
   that pinned the old layout and add coverage for new behavior.
4. Re-screenshot and compare. Repeat until polished at both widths.

## Finishing

- Full test suite + typecheck + coverage gates green.
- Revert the bypass: drop the throwaway commit, `git restore` the compose
  change, `dev up <app>` to recreate, and confirm the same `curl` now returns
  `307` to `/sign-in`. `git grep CANDELA_LOCAL_AUTH_BYPASS` must be empty in
  both repos.
- Ship by PR per the workspace workflow (Linear issue, branch, CI, squash
  merge, worktree sweep).
