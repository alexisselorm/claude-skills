# Research notes

Return format for the market research agent. These are working notes: they never go into the
repo. The plan carries only the distilled table and citations.

Live web only. Never fill a competitor, price, feature or number from memory. Date every source.

## Competitors

One entry per competitor the search surfaces as touching this feature. Don't pad the list.

- **<Name>**: <what it is, who it targets>
  - Feature: yes / no / partial — <what exactly>
  - Tier and price: <where it sits in their pricing>
  - Source: <url> (accessed <YYYY-MM-DD>)
  - Evidence: vendor page | docs | changelog | independent review | user report. Marketing
    claims (latency, accuracy, win rates) are marked unverified unless an independent source
    backs them.

## Industry method

How the underlying problem is solved, independent of any vendor. This makes the approach
defensible even where nobody ships the feature.

- Standard approach, with source
- Known pitfalls, with source
- Tooling: libraries, licences (and whether they oblige attribution or copyleft), costs

## Absence claims

Only if the search supports "nobody ships this". Make it falsifiable:

- Queries run: `<terms>`
- What came back
- Conclusion: supported or inconclusive

## Bearing on the plan

One line per finding that should change a decision. Findings that change nothing are left out.

- <finding>: <what the plan should do differently>

## If web tools failed

Say so, list the exact queries to run, and return nothing else.
