# exports-api

Backend client. The `/api/exports` endpoint returns 500 on date ranges wider
than about ninety days. It is a join-layer problem, not a handler problem.

- What is decided so far: [[decisions]]
- The same list as a relative link, because Obsidian writes both shapes: [decisions](decisions.md)

Next action: reproduce the 500 against the staging dataset with a 120-day range.
