---
name: software-engineering
description: "Software engineering practices: TDD, code review, debugging, codebase inspection, spike/prototyping, and parallel cleanup. Use when implementing features, fixing bugs, reviewing code, inspecting codebases, or validating before commit."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [software-engineering, tdd, code-review, debugging, testing, quality, sprint, development]
---

# Software Engineering Practices

Covers the full software development lifecycle from writing tests to code review to debugging.

---

## 1. Test-Driven Development (TDD)

**Iron law:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.

### Red-Green-Refactor Cycle

1. **RED** — Write one minimal test showing what should happen
2. **Verify RED** — Run the test, confirm it fails for the expected reason
3. **GREEN** — Write the simplest code to pass (hardcoding is OK)
4. **Verify GREEN** — Test passes, all other tests still pass
5. **REFACTOR** — Clean up, keep tests green

### Good Test
```python
def test_retries_failed_operations_3_times():
    attempts = 0
    def operation():
        nonlocal attempts
        attempts += 1
        if attempts < 3: raise Exception('fail')
        return 'success'
    result = retry_operation(operation)
    assert result == 'success' and attempts == 3
```

### Rationalizations to Reject
- "Too simple to test" — Simple code breaks. Test takes 30 seconds.
- "I'll test after" — Tests passing immediately prove nothing.
- "Already manually tested" — Ad-hoc ≠ systematic. No record, can't re-run.

Full reference: `references/tdd.md`

---

## 2. Pre-Commit Code Verification

**Core principle:** No agent should verify its own work. Fresh context finds what you miss.

### Pipeline
1. Get diff: `git diff --cached` or `git diff`
2. Static security scan (secrets, injection, eval, pickle)
3. Baseline tests/linting (stash → run → pop → compare)
4. Self-review checklist (secrets, validation, error handling, tests)
5. Independent reviewer subagent via `delegate_task`
6. Auto-fix loop (max 2 cycles)
7. Commit with `[verified]` prefix

### Security Scan Patterns
```bash
git diff --cached | grep "^+" | grep -iE "(api_key|secret|password|token)\s*=\s*['\"][^'\"]{6,}['\"]"
git diff --cached | grep "^+" | grep -E "os\.system\(|subprocess.*shell=True"
```

### Reviewer Subagent Prompt
```
Review the git diff. Return ONLY JSON:
{"passed": true/false, "security_concerns": [], "logic_errors": [], "suggestions": [], "summary": "..."}
```

Full reference: `references/code-verification.md`

---

## 3. Simplify Code (Parallel 3-Agent Cleanup)

Review recent code changes with three focused reviewers running in parallel.

### Three Reviewers
1. **Code Reuse** — Finds duplicated functionality, existing utilities
2. **Code Quality** — Finds redundant state, parameter sprawl, leaky abstractions
3. **Efficiency** — Finds unnecessary work, missed concurrency, hot-path bloat

### Process
```python
delegate_task(tasks=[
    {"goal": "Review diff for code reuse issues", "toolsets": ["terminal", "file"]},
    {"goal": "Review diff for quality problems", "toolsets": ["terminal", "file"]},
    {"goal": "Review diff for efficiency problems", "toolsets": ["terminal", "file"]},
])
```
Aggregate findings → deduplicate → apply fixes → verify.

---

## 4. Systematic Debugging

**Iron law:** NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.

### 4-Phase Process
1. **Understand** — Reproduce, gather evidence, read error messages
2. **Hypothesize** — Form specific theories about root cause
3. **Test** — Design experiments to confirm/refute each hypothesis
4. **Fix** — Apply targeted fix, verify resolution

### Anti-Patterns
- Random fixes without understanding
- Quick patches that mask underlying issues
- "It works now" without knowing why

### Node.js Debugging
```bash
node --inspect script.js  # V8 inspector
# Then use node inspect or CDP via chrome-remote-interface
```

Full reference: `references/debugging.md`

---

## 5. Spike (Throwaway Experiments)

**Core principle:** Validate ideas before building. Spikes are disposable.

### Process
1. **Decompose** — Break into 2-5 independent feasibility questions
2. **Research** — Brief, surface competing approaches, pick one
3. **Build** — One directory per spike, bias toward interactive output
4. **Verdict** — VALIDATED | PARTIAL | INVALIDATED with evidence

### Output
```
spikes/
├── 001-websocket-streaming/
│   ├── README.md  # Question, approach, results, verdict
│   └── main.py
```

Full reference: `references/spike.md`

---

## 6. Codebase Inspection (pygount)

```bash
pip install pygount
pygount --format=summary \
  --folders-to-skip=".git,node_modules,venv,.venv,__pycache__,dist,build" .
```
Always exclude dependency directories or pygount will hang on large repos.

---

## 7. Frontend UI Debugging (React)

Common patterns for toggle buttons, conditional rendering bugs, and visual feedback:
- **Badge condition bug**: Using `(flag || !otherField)` instead of just `flag` in JSX — conflates separate concerns
- **Toggle visual feedback**: Use semantic colors (rose=hidden, emerald=shown), tooltips, counts, distinct icons
- **Windows git-bash**: `npx vite build` may fail silently — use `npm run build`

Full reference: `references/frontend-ui-debugging.md`

---

## Quick Reference

| Practice | Skill Section | Key Tool |
|----------|--------------|----------|
| TDD | Section 1 | pytest |
| Pre-commit verification | Section 2 | delegate_task (reviewer) |
| Parallel cleanup | Section 3 | delegate_task (3 agents) |
| Debugging | Section 4 | systematic approach |
| Spike | Section 5 | throwaway code |
| Codebase inspection | Section 6 | pygount |
