# Idea: retry the export job instead of widening the timeout

Captured: April 20, 2026

Widening the timeout just moves the failure later. A bounded retry with a
smaller page size is closer to the real fix. Check whether this contradicts
[[rate-limit-postmortem]] before writing it up.
