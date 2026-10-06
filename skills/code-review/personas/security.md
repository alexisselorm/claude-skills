# Lens: security and data safety

What could leak, be abused, or destroy data?

- Secrets: credentials, tokens, keys or `.env` values hardcoded, logged, echoed or committed.
- Injection: SQL, shell, path, SSRF or template built from input instead of parameterised.
- Authn and authz: is each new route or handler authenticated and authorised? Is ownership
  checked (IDOR), or can one tenant read another's rows? A missing owner predicate is the
  classic miss.
- Input validation at the trust boundary; unbounded size, count or depth (DoS).
- Data safety: destructive migrations (drops, type narrowing, non-null without default),
  missing downgrade or backfill, irreversible writes, multi-step writes without a transaction.
- PII or secrets in logs, error messages or responses.
- Timing-unsafe token comparison; missing rate limits on new public endpoints.
- New dependencies: pinned? Reputable? Pulled from where?
