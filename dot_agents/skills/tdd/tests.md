# Good and Bad Tests

## What counts as observable behavior

"Test the public interface" is a useful shorthand but not the real rule — a public method can itself be a leaked implementation detail, and testing it is brittle no matter how public it is.

For each API member you're about to test, ask whether it does one of these:

1. **Exposes an operation** that lets a client achieve a goal in a single call, or
2. **Exposes state** that a client needs in order to achieve a goal.

If neither, it's a leak. Either stop testing it, or hide it and test the goal it serves.

The inverse holds too: **a unit is a unit of behavior, not a class or a file.** A test that runs through five collaborators to verify one behavior is not a smell — it's the point. Internal classes are implementation details; reach them through the API of the larger unit rather than writing a test file per class.

## Good Tests

Test through real code, not mocks of internal parts.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Characteristics:

- Tests behavior users/callers care about
- Every member it touches passes the operations-or-state check above
- Survives internal refactors
- Describes WHAT, not HOW
- **One AAA triple per test** — arrange, act, assert, then stop

On that last point: there is no rule against several assertions in one test. A single unit of behavior often needs three or four to describe its outcome, and splitting them yields fragmented tests that each say less. What to avoid is a second act — arrange/act/assert/act/assert means you have two tests wearing a trench coat. Likewise, no `if` statements in tests: a branch means the test is describing two behaviors.

Name tests in plain language a non-programmer on the team could read. No rigid `Method_Condition_Result` template — "user cannot check out with an empty cart" beats "checkout_EmptyCart_ThrowsException".

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Red flags:

- Mocking internal collaborators ([mocking.md](mocking.md))
- Asserting a query was called, rather than acting on its result
- Testing private methods, or widening access purely to let a test in
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Trivial code under test — getters, pass-throughs ([testing-styles.md](testing-styles.md))

## Verifying a managed dependency

Round-tripping through your own write-then-read path is the obvious move, and it has a specific failure mode: if the write and the read are broken symmetrically — wrong table, wrong column, wrong serialization on both sides — the test passes and the data is still wrong.

```typescript
// RISKY as the only check: a symmetric bug in create + get cancels out
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});

// BETTER for an integration test: verify end state independently
test("createUser stores the user", async () => {
  const user = await createUser({ name: "Alice" });
  const row = await readUserRow(user.id); // raw query helper, not the production repository
  expect(row.name).toBe("Alice");
});
```

Use a raw read helper written for tests, not the repository the production code writes through. This is not a licence to assert on schema shape everywhere — you're checking that the behavior's end state landed, and the assertion should still be phrased in terms of the data the client cares about.

This applies when the test runs against a real store. For pure in-memory logic, or when you've chosen to mock the data layer, there's no independent state to inspect and the round trip is what you have — just know what it can't catch.
