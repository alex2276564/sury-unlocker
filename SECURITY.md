# Security Policy

**⚠️ IMPORTANT NOTE:**

This project follows **best-practice security**, but **cannot guarantee 100% protection** against zero-day exploits or highly targeted attacks.
For **enterprise-grade security requirements**, use **commercially supported solutions** with dedicated threat intelligence.

---

## Threat model

**Considered attack vectors** (prioritized by likelihood/risk):

1. **Supply chain**

## CI hardening

All CI jobs are protected by StepSecurity Harden Runner, which monitors
outbound network and process activity on the runner at runtime.

Third-party Actions are referenced by tag rather than commit SHA.
SHA pinning is intentionally not used — it only provides strong guarantees
when combined with manual review of every upstream commit, which this
single-developer project cannot sustain. Runtime monitoring via Harden Runner
is the primary supply-chain control instead.

## Reporting a vulnerability

If you discover a security vulnerability, please use the
[Security tab](https://github.com/alex2276564/sury-unlocker/security/advisories) to report it privately.  
Do **not** disclose security vulnerabilities publicly before they have been addressed.
