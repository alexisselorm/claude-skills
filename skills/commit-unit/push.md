# Pushing

Only when the user asks. Run `scripts/check.sh` first, then:

```bash
GIT_TERMINAL_PROMPT=0 git push origin <branch>
```

If it fails on credentials, don't hunt for the credential helper or its socket. Say the
commits are local and unpushed, and hand the push to the user.
