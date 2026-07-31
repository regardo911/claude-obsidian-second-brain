# Decisions

- 2026-04-14 Fix in the join layer, not the API handler. The handler is
  correct; it is being handed too many rows.
- 2026-04-15 Ruled out caching. The slow path is a cold read by definition.
- 2026-04-19 Friday deadline agreed with Priya. See [[q3-pricing-brief]] for
  what that date is actually tied to.
