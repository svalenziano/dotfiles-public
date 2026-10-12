# Interface Design for Testability

Good interfaces make testing natural. In priority order:

1. **Separate decisions from side effects** — the highest-leverage move

   Have the logic compute _what should happen_ and return it; let a thin outer layer carry it out. The decision is then testable output-based, with no collaborators to inject and nothing to mock. The outer layer ends up so thin it barely needs testing.

   ```typescript
   // Testable: returns a decision
   function calculateDiscount(cart, coupon): Discount {}

   // Hard to test: mutates, returns nothing to assert on
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

   This is functional core / imperative shell — a design goal, not just a testing trick. If most of your logic sits in pure functions, most of your suite is fast and refactor-proof by construction.

2. **Accept unmanaged dependencies, don't create them**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

   This is for reaching genuine external boundaries — see [mocking.md](mocking.md). It is not a default posture toward every collaborator. Injecting your own modules so tests can swap them is how communication-based tests and one-to-one interfaces creep in, and both cost refactoring resistance. Try step 1 first; inject only what remains.

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup
   - Every member should pass operations-or-state ([tests.md](tests.md)); anything else is a leak you'll end up testing

**Never widen access for tests.** No exposing internals, no test-only hooks or flags in production code. If a behavior can't be reached through the API, either it's not observable behavior, or the API is missing something a real client would also want.
