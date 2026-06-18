# GitHub API Queries for Skill Library Management

## 📋 Check Repo Structure

```bash
# List repo root contents
gh api repos/USERNAME/REPO-NAME/contents/

# List contents of a specific folder
gh api repos/USERNAME/REPO-NAME/contents/skills/software-development/

# Get commit history (for finding deleted/moved skills)
gh api repos/USERNAME/REPO-NAME/commits?per_page=50
```

## 📥 Download Skill from GitHub to Local

```python
import subprocess, json, base64, os

def download_skill_from_gh(repo, skill_path, local_target):
    """Download a skill folder from GitHub to local repo."""
    result = subprocess.run(
        ['gh', 'api', f'repos/{repo}/contents/{skill_path}'],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout)
    
    for item in data:
        if item['type'] == 'file':
            # Get file content
            file_result = subprocess.run(
                ['gh', 'api', f'repos/{repo}/contents/{item["path"]}'],
                capture_output=True, text=True
            )
            file_data = json.loads(file_result.stdout)
            content = base64.b64decode(file_data['content']).decode('utf-8')
            
            # Write to local
            local_path = os.path.join(local_target, item['name'])
            with open(local_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✅ Downloaded: {item['name']}")
```

## 🚨 Pitfalls

### ❌ `jq` not available on Windows git-bash
Use Python to parse JSON instead of `jq`.

### ❌ GitHub API returns truncated output for large repos
Use `?per_page=100` parameter and paginate if needed.

### ✅ Always verify skill structure after download
```bash
ls -R skills/software-development/my-skill/
```
