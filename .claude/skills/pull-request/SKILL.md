---
name: pull-request
description: 현재 브랜치를 원격 저장소에 push하고 Pull Request를 생성하거나 업데이트합니다.
---

# Pull Request 생성 가이드

## 목표

현재 브랜치의 커밋을 원격 저장소에 push하고, 프로젝트 PR 형식에 맞는 제목과 본문으로 Pull Request를 생성(또는 업데이트)하는 것이 목표입니다.

---

## 요구사항

이 스킬은 `gh` CLI(GitHub CLI)를 사용합니다. `gh` 명령어를 먼저 확인하고, 없을 경우 아래 안내를 사용자에게 전달하고 스킬을 종료합니다.

**gh CLI 설치 및 인증 방법:**
```bash
# 설치
brew install gh

# 사내 GitHub 환경 인증 로그인
gh auth login --hostname git.linecorp.com
# → "Login with a web browser" 선택 후 브라우저 인증
```

**gh 설치 여부 확인:**
```bash
gh --version
```

명령이 실패하면 사용자에게 위 설치 방법을 안내하고 작업을 종료합니다.

---

## 주의사항

- **커밋은 직접 생성하지 않습니다.** 커밋은 사용자의 역할 범주입니다.
- **rebase는 직접 수행하지 않습니다.** rebase가 필요한 경우 사용자에게 권고하고 종료합니다.
- PR 제목과 본문은 반드시 `.claude/skills/pull_request/PR_FORMAT.md`를 참고하여 작성합니다.
- 이미 PR이 존재하는 경우 새로 생성하지 않고 제목과 본문을 업데이트합니다.

---

## 세부 작업 순서

### Step 0: gh CLI 확인

**목적:** 필수 도구인 `gh` CLI가 설치되어 있는지 확인합니다.

**수행 작업:**
- `gh --version` 실행
- 실패 시: 사용자에게 설치 방법(요구사항 섹션 참고)을 안내하고 **작업 종료**

---

### Step 1: Git 상태 확인

**목적:** 커밋되지 않은 변경사항이 있는지 확인하고, 사용자에게 진행 여부를 묻습니다.

**수행 작업:**
- `git status` 실행
- untracked 파일 또는 staged/unstaged 변경사항이 존재하는 경우:
  - 해당 파일 목록을 사용자에게 보여줌
  - "이 파일들을 커밋하지 않고 PR을 올려도 괜찮습니까?" 라고 반드시 확인
  - 사용자가 거부하면: **작업 종료** (사용자에게 먼저 커밋할 것을 안내)
  - 사용자가 승인하면: 다음 단계로 진행

---

### Step 2: 현재 브랜치에 push할 커밋이 있는지 확인

**목적:** 원격에 push되지 않은 커밋이 존재하는지 확인합니다.

**수행 작업:**
- 현재 브랜치명 확인: `git branch --show-current`
- 원격 브랜치 대비 로컬 커밋 수 확인:
  ```bash
  git fetch origin
  git rev-list --count origin/<current-branch>..HEAD
  ```
  - 원격 브랜치가 아직 없는 경우(신규 브랜치): 로컬 커밋 수 확인
    ```bash
    git rev-list --count HEAD
    ```
- push할 커밋이 0개이면: "push할 새로운 커밋이 없습니다." 안내 후 **작업 종료**

---

### Step 3: Remote main 브랜치와의 rebase 필요 여부 확인

**목적:** 현재 브랜치가 원격 main 기준으로 최신 상태인지 확인합니다.

**수행 작업:**
- 원격 main 최신 커밋 가져오기:
  ```bash
  git fetch origin main
  ```
- 현재 브랜치의 base가 origin/main보다 뒤처져 있는지 확인:
  ```bash
  git rev-list --count HEAD..origin/main
  ```
- 반환값이 1 이상이면 (origin/main에 현재 브랜치가 포함하지 않는 커밋이 존재):
  - "현재 브랜치가 origin/main 기준으로 최신이 아닙니다. PR 생성 전에 rebase를 권장합니다." 안내
  - 사용자에게 아래 명령어를 제안:
    ```bash
    git rebase origin/main
    ```
  - **작업 종료** (rebase는 직접 수행하지 않음)
- 반환값이 0이면: 다음 단계로 진행

---

### Step 4: 현재 브랜치를 원격 저장소에 push

**목적:** 로컬 커밋을 원격 브랜치에 반영합니다.

**수행 작업:**
- push 실행:
  ```bash
  git push origin <current-branch>
  ```
  - 원격 브랜치가 없는 경우 (`-u` 옵션 포함):
    ```bash
    git push -u origin <current-branch>
    ```
- push 실패 시: 에러 메시지를 사용자에게 전달하고 **작업 종료**

---

### Step 5: PR 생성 또는 업데이트 준비 — 제목과 본문 작성

**목적:** 프로젝트 규칙에 맞는 PR 제목과 본문을 작성합니다.

**수행 작업:**
- `.claude/skills/pull_request/PR_FORMAT.md`를 읽어 제목 규칙과 본문 템플릿을 파악
- 현재 브랜치명, 커밋 로그(`git log origin/main..HEAD --oneline`), 변경 파일 목록을 기반으로 내용 추론
- **제목**: PR_FORMAT.md의 제목 규칙(정규식)을 만족하도록 작성
- **본문**: `.github/pull_request_template.md` 전체 구조를 유지하며 작성
  - `Type of change` 체크박스 목록 전체 유지, 해당 항목만 `[x]` 표시
  - `Link` 섹션: 브랜치명 또는 커밋 메시지에서 Jira 이슈 ID 추론하여 기재
  - `Description in detail`: 변경 사항 요약

---

### Step 6: PR 생성 또는 업데이트

**목적:** 원격 저장소에 PR을 생성하거나 기존 PR을 업데이트합니다.

**수행 작업:**

#### 기존 PR 확인:
```bash
gh pr list --repo <remote-repo> --head <current-branch> --state open
```

#### 기존 PR이 없는 경우 — 신규 생성:
```bash
gh pr create \
  --repo <remote-repo> \
  --title "<title>" \
  --body "<body>" \
  --base main
```

#### 기존 PR이 있는 경우 — 제목/본문 업데이트:
```bash
gh pr edit <pr-number> \
  --repo <remote-repo> \
  --title "<title>" \
  --body "<body>"
```

**원격 저장소 주소 확인 방법:**
```bash
git remote get-url origin
# 예: git@git.linecorp.com:AI-Solution/agent-flow.git
# → repo: git.linecorp.com/AI-Solution/agent-flow
```

---

### Step 7: 결과 보고

**목적:** 작업 완료를 사용자에게 알립니다.

**수행 작업:**
- PR URL을 사용자에게 전달
- 제목과 본문 내용을 요약하여 보여줌
- 추가 수정이 필요한 경우 직접 PR 페이지에서 수정 가능함을 안내
