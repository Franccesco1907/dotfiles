---
name: prompt-engineering
description: "Trigger: prompt engineering, prompts, AI stages, LLM contracts. Design robust prompts with examples, contracts, and guards."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Prompt Engineering

## Activation Contract

Use when creating or changing prompts, staged AI workflows, LLM output contracts,
repair prompts, classifier prompts, or prompt tests.

## Hard Rules

- Define the stage purpose before instructions: analysis, planning, generation,
  repair, classification, or editing.
- Prefer positive examples for the exact expected output shape; add anti-rules
  only after the correct shape is clear.
- Never ask a model to infer hidden facts. Distinguish user-provided evidence,
  model interpretation, and deterministic system facts.
- Keep semantic intent classification in the model; keep mechanical validation,
  schema checks, and safety guards in code.
- Prompts that require JSON MUST state required fields, forbidden fields, and
  whether the response is final content or an intermediate artifact.
- Repair prompts MUST preserve prior valid context and change only the failed
  shape or unsupported content.

## Decision Gates

| Situation | Prompt Strategy |
|---|---|
| Model confuses stages | Add positive examples for each stage and name forbidden neighboring-stage fields. |
| Output has valid JSON but wrong schema | Strengthen required-field contract and repair prompt; do not relax schema first. |
| User intent is open-ended | Use classifier JSON, then deterministic patch/edit execution. |
| Facts are mechanical and safe | Extract in code and pass as evidence. |
| Model may invent | Add evidence-only rules and guards that reject unsupported output. |

## Execution Steps

1. Identify the stage and its allowed responsibility.
2. Write a compact output contract with required and forbidden fields.
3. Add one positive JSON example that matches the schema exactly.
4. Add evidence rules: what may be used, what must be omitted, and what is forbidden.
5. Add repair rules for common schema failures.
6. Add tests that assert critical prompt phrases and representative examples.

## Output Contract

Return:
- Prompt files changed.
- Stage responsibilities clarified.
- Positive examples added or updated.
- Guard/repair behavior covered by tests.

## References

- None.
