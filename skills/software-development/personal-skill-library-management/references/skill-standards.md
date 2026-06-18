# Skill Frontmatter Standard

All custom skills MUST include complete frontmatter:

```yaml
---
name: skill-name
description: "What this skill does"
version: X.Y.Z
author: tome
license: MIT-0
metadata:
  hermes:
    tags: [tag1, tag2]
    homepage: https://github.com/tomekdot/repo-name
    related_skills: [other-skill]
---
```

Missing any of these fields = incomplete. User will ask to fix.

# Skill Library Sync Workflow

Single source of truth: `C:\Users\tomekdot\hermes-skills\skills\`

After any change:
1. `git add -A`
2. `git commit -m "Description"`
3. `git push origin main`
4. Copy to `AppData\Local\hermes\skills\<category>\<skill>\`

Hermes reads from AppData. `.hermes/skills/` is deprecated.

# Merging Skills

When combining N skills into 1 umbrella:
- Keep ALL content from all source skills
- Use class-level name (not specific plugin name)
- Include all commands, data models, installation methods
- Preserve all GitHub URLs in Sources section
- Add `references/original-skills.md` with source metadata
