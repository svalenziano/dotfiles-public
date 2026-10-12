---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# Test-Driven Development

## Philosophy

**Core principle**: Tests should verify observable behavior, not implementation details. Code can change entirely; tests shouldn't.

Tests are judged on four properties: protection against regressions, resistance to refactoring, fast feedback, and maintainability. The first three trade off against each other. **Resistance to refactoring is the one you never trade away** — a suite that goes red every time you restructure working code stops being believed, and once red is ignored the real failures get ignored too.

**Good tests** exercise real code paths and describe _what_ the system does, not _how_. "User can checkout with valid cart" tells you exactly what capability exists. These survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation: they mock internal collaborators or your own database, assert that a query was called, or reach into private methods. The warning sign is a failure with no bug behind it — you renamed something and the suite went red.

Note that "public" is not the same as "observable." A public method can itself be a leaked implementation detail, and a test on it will be brittle regardless. The real check is per API member: does it let a client achieve a goal in one call, or expose state a client needs for a goal? See [tests.md](tests.md).

See also [testing-styles.md](testing-styles.md) for which style of test to reach for and what isn't worth testing at all, and [mocking.md](mocking.md) for what to mock.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

### 1. Planning

When exploring the codebase, use the project's domain glossary so that test names and interface vocabulary match the project's language, and respect ADRs in the area you're touching.

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Check each planned API member against operations-or-state — drop the leaks
- [ ] Identify opportunities for [deep modules](deep-modules.md) (small interface, deep implementation)
- [ ] Design interfaces for [testability](interface-design.md)
- [ ] Separate decisions from side effects so the logic can be tested output-based
- [ ] Identify which dependencies are unmanaged (mock) vs managed (prefer real)
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything, and shouldn't.** Confirm with the user exactly which behaviors matter most. Complex domain logic earns heavy testing; orchestration earns a few integration tests; trivial code earns none. A test on a getter can never fail for a reason you care about but can still break under refactoring — that's pure liability. See the quadrants in [testing-styles.md](testing-styles.md).

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Everything asserted on is an operation or state a client needs
[ ] Test would survive internal refactor (no false positives)
[ ] Mocks are justified, and assert only on outgoing commands
[ ] One AAA triple, no branching
[ ] Code is minimal for this test
[ ] No speculative features added
```

If a test needs elaborate setup or a pile of mocks to exist, that's the design talking — split the code rather than writing a cleverer test.
