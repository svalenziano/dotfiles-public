# When to Mock

The criterion is **not** "did I write this code." It's whether the dependency is _managed_ or _unmanaged_.

**Unmanaged dependency** — other applications can see it. Third-party APIs, SMTP servers, message buses. Your calls to it are visible to the outside world, so those calls _are_ part of your observable behavior. Breaking them breaks a contract someone else depends on.

→ **Always mock.** Verifying the interaction is legitimate here, because the interaction is the behavior.

**Managed dependency** — only your application touches it. Your own database, your own file storage, a cache nobody else reads.

→ **Prefer a real test instance; mock only when you have a reason to.** How you talk to your own database is an implementation detail, so a test that asserts on _calls_ to it goes red on every ORM swap, table split, or query merge — false positives with no bug behind them. A real test DB avoids that and catches far more. But it costs setup and runtime, and when that cost isn't worth paying for a given test, mocking the data layer is a legitimate trade rather than a rule violation.

Whichever you choose, verify managed dependencies by their **resulting state**, never by the calls made to them.

| Dependency | Mock? | Verify by |
| --- | --- | --- |
| Payment API, SMTP, message bus | Yes | Interaction (outgoing commands only) |
| Your database, your file storage | Prefer a real test instance; mock when the cost isn't worth it | Resulting state |
| Time, randomness | Pass the value in | Output |
| Your own classes and modules | Never | Their observable behavior |

Time and randomness are best handled by passing the value in (`now: Date`, a seed) rather than injecting a clock service. A value has nothing to stub.

## Mock only outgoing commands

Split every interaction with an unmanaged dependency:

- **Command** — changes something out there. Sending an email, publishing a message, charging a card. Asserting it happened is fair.
- **Query** — asks for information and changes nothing. Stub it so the test can proceed, but **never assert it was called.** A query's call count is pure implementation; calling it twice, or caching the result, changes nothing anyone can observe.

## Mock at the far edge

Put the mock at the outermost point you control — the HTTP client, the SMTP gateway — not at the first internal class that wraps it. Every layer left running behind the mock is real code under test. Mocking the class nearest your domain logic gives up most of the regression protection and couples the test to a boundary you invented.

## Designing for mockability

Pass unmanaged dependencies in rather than constructing them internally:

```typescript
// Testable
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to test
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

But reach for this **second**. The first question is always whether the logic can be separated from the collaborator entirely, so there is nothing to inject — see [interface-design.md](interface-design.md). Dependency injection exists here to reach unmanaged boundaries, not as a default posture toward all collaborators.

**Don't create an interface with exactly one implementation just so you can mock it.** One-to-one interfaces are justified for unmanaged dependencies and essentially nowhere else. If the only client of an abstraction is your test suite, the abstraction is test damage.

When you do wrap an external service, prefer a specific function per operation over one generic fetcher — each stub then returns one shape, with no conditional logic in test setup:

```typescript
// GOOD: each operation independently stubbable
const paymentApi = {
  charge: (amount) => ...,
  refund: (chargeId) => ...,
};

// BAD: stub needs branching to know what to return
const paymentApi = {
  request: (endpoint, options) => ...,
};
```

This applies to the boundary wrapper itself. It is not a licence to build one of these per internal module.
