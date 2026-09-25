---
name: goal
description: >-
  Set a durable objective for pi to pursue to completion across turns. Use only
  when the user invokes /skill:goal with an objective.
disable-model-invocation: true
---

# Goal

Accept `/skill:goal <objective>`.

## Parse

- If the objective is empty, show `Usage: /goal <objective>`.
- There is no deadline, token budget, or turn budget. A goal continues until it is complete.
- If the request leads with a time limit such as `30m` or `2h`, say plainly that time-limited goals are not supported, then create the goal without one rather than folding the limit into the objective.
- "Every ..." describes recurring work and belongs to `loop`, not `goal`.

pi has no separate goal object: the objective lives in this conversation, and pi sessions persist across turns, so the goal survives until it is done or the user abandons it.

## Start

1. Restate the objective clearly, including every explicit deliverable or required evidence you will verify against the repo.
2. Perform the first concrete unit of work immediately in this turn; do not stop after planning or restating.
3. If the next work is meaningfully multi-step, track it with `plan_task` when Plan/Build is active, or keep a short visible checklist. Do not treat a plan update as a substitute for doing the work.

## Continuation

- The goal persists across turns. Ending a turn does not require shrinking the objective to what fits now.
- Keep the full objective intact. If it cannot be finished now, make concrete progress toward the real requested end state, leave the goal active, and do not redefine success around a smaller or easier task.
- Work from the current working tree and external state as authoritative. Earlier conversation can locate work, but inspect the current state before relying on it. Improve, replace, or remove existing work as needed.

## Fidelity

- Optimize each turn for movement toward the requested end state, not for the smallest stable-looking subset or the easiest passing change.
- Do not substitute a narrower, safer, smaller, merely compatible, or easier-to-test solution because it is more likely to pass current tests.
- An edit is aligned only if it makes the requested final state more true; useful-looking behavior that preserves a different end state is misaligned.

## Completion audit

Before deciding the goal is achieved, treat completion as unproven and verify it against the actual current state:

- Derive concrete requirements from the objective and any referenced files, plans, specifications, or issues.
- Preserve the original scope; do not redefine success around work that already exists.
- For every explicit requirement, numbered item, named artifact, command, test, gate, invariant, and deliverable, identify the authoritative evidence that would prove it, then inspect the relevant current-state sources: files, command output, test results, PR state, rendered artifacts, runtime behavior.
- For each item, decide whether the evidence proves completion, contradicts it, shows incomplete work, is too weak or indirect, or is missing.
- Match the verification scope to the requirement's scope; do not use a narrow check to support a broad claim.
- Treat tests, manifests, and green checks as evidence only after confirming they cover the requirement.
- Treat uncertain or indirect evidence as not achieved; gather stronger evidence or continue the work.

Do not rely on intent, partial progress, memory of earlier work, or a plausible final answer as proof. Report the goal achieved only when current evidence proves every requirement has been satisfied and no required work remains. If any requirement is missing, incomplete, or unverified, keep working.
