# Fork Protocol

Use this protocol when splitting work into branch modes or persona-specific explorations.

## When To Fork

Fork when:
- a speculative direction needs room to develop
- adversarial critique should proceed separately from generation
- multiple interpretations need parallel treatment
- a worldbuilding branch should not rewrite the kernel prematurely

## Fork Rules

1. Name the fork clearly.
2. Record its purpose.
3. Define the active mode or persona.
4. State what the fork is not allowed to change.
5. Require later merge review.

## Fork Record Template

```yaml
fork_name: example-fork
purpose: short description
active_mode: Chorus
protected_layers:
  - kernel
  - invariants
outputs_expected:
  - concepts
  - notes
  - critiques
merge_required: true
```

## Constraint

A fork can generate possibilities, but it cannot silently alter durable continuity.
