# Lens: performance

Will this be slow or expensive at real data sizes?

- Queries in loops (N+1), missing indexes for new filters or joins, unbounded `SELECT`s.
- Work repeated per item or per request that could be done once; blocking I/O on a hot or
  async path.
- Unbounded memory: loading whole tables or files, growing caches without eviction.
- Algorithmic blow-ups: nested scans over collections that grow with users or data.
- Only report what a realistic input size makes matter; say what size that is.
