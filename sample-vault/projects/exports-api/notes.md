# Notes

The join fans out one row per line item per export, so a wide date range
multiplies rather than adds. Nothing in the handler bounds it.

Open question: does the same fan-out hit the nightly report job? I wrote
this up once already in [[exports-api-retro]] and cannot find it.

Older write-up, same bug family: [the retro](retro-2026-04.md)
