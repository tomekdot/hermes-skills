# Skill Frontmatter Standard

## Required Format

Every skill SKILL.md MUST start with this exact frontmatter format:

```yaml
---
name: skill-name
description: "Description of what the skill does and when to use it"
version: X.Y.Z
author: tome
license: MIT
metadata:
  hermes:
    tags: [tag1, tag2, tag3]
---
```

## Rules

- **name**: lowercase, hyphens (no spaces)
- **description**: ALWAYS quoted (double quotes)
- **version**: semantic versioning (X.Y.Z)
- **author**: always `"tome"` (GitHub username)
- **license**: always `"MIT"` — NEVER `"MIT-0"`, never anything else. No one can take it away.
- **metadata.hermes.tags**: array of lowercase tags in square brackets
- **NEVER use** `metadata.openclaw` — always `metadata.hermes`
- **NEVER use** `license: MIT-0` — always `license: MIT`

## Example

```yaml
---
name: my-skill-name
description: "Does X, Y, and Z. Use when building A or fixing B."
version: 1.0.0
author: tome
license: MIT
metadata:
  hermes:
    tags: [category, tool, workflow]
---
```

## Common Mistakes

| Wrong | Correct |
|-------|---------|
| `license: MIT-0` | `license: MIT` |
| `metadata.openclaw:` | `metadata.hermes:` |
| `description: unquoted text` | `description: "quoted text"` |
| `author: OWL` | `author: tome` |
| `license: Apache-2.0` | `license: MIT` |
