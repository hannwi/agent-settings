---
name: commit
description: 이미 staged된 변경사항을 커밋합니다. git add는 수행하지 않습니다.
---

# Commit 가이드

## 목표

`git add`로 이미 staged된 변경사항을 분석하여 적절한 커밋 메시지를 작성하고 커밋하는 것이 목표입니다.

---

## 주의사항

- **`git add`는 원칙적으로 수행하지 않습니다.** staged 상태는 사용자가 직접 관리합니다.
  - 유일한 예외: pre-commit hook이 formatter/lint를 자동 수정한 경우 (Step 4 참고)
- staged된 파일만 커밋 대상으로 판단합니다.
- staged 파일이 없으면 즉시 작업을 종료합니다.
- 커밋 메시지 제목은 PR 제목 규칙과 동일한 형식을 따릅니다.

---

## 커밋 메시지 규칙

커밋 제목은 아래 정규식을 만족해야 합니다 (PR 제목과 동일):

```
^([a-z]+: )*\[([A-Z]+-\d+(,[A-Z]+-\d+)*|NON-ISSUE|DEPLOY)\]\s.*$
```

구조:

```
[type: ][ISSUE-ID] Short description
```

- **type** (선택): 소문자 접두사. 예: `feat: `, `fix: `, `docs: `, `refactor: `, `chore: `
- **ISSUE-ID**: `[AIX-835]`, `[AIS-1234]` 등 대문자 프로젝트 코드 + 하이픈 + 숫자
  - Jira 이슈 없음: `[NON-ISSUE]`
- **Short description**: 변경 내용을 간결하게 기술

### 예시

```
feat: [AIX-835] Add auto-prompt-gen pipeline config
fix: [AIX-835] Fix config validation error
docs: [NON-ISSUE] Update README with new examples
refactor: [AIX-813] Extract common module for feedback clustering
```

---

## 세부 작업 순서

### Step 1: Staged 파일 확인

**목적:** 커밋 대상이 존재하는지 확인합니다.

**수행 작업:**
- staged 파일 목록 확인:
  ```bash
  git diff --cached --name-only
  ```
- staged 파일이 없으면: "커밋할 staged 파일이 없습니다." 안내 후 **즉시 종료**
- staged 파일 목록이 있으면: 다음 단계로 진행

---

### Step 2: Unstaged 변경사항 확인

**목적:** staged되지 않은 변경사항이 있는지 확인하고, 사용자의 의도를 확인합니다.

**수행 작업:**
- unstaged 변경사항 및 untracked 파일 확인:
  ```bash
  git status
  ```
- unstaged 변경사항(modified) 또는 untracked 파일이 존재하는 경우:
  - 해당 파일 목록을 사용자에게 보여줌
  - "위 파일들은 staged되지 않아 이번 커밋에 포함되지 않습니다. 계속 진행하겠습니까?" 라고 확인
  - 사용자가 **종료**를 원하면: **즉시 작업 종료**
  - 사용자가 **진행**을 원하면: 다음 단계로 진행
- unstaged 변경사항이 없으면: 바로 다음 단계로 진행

---

### Step 3: JIRA Ticket ID 추출

**목적:** 현재 브랜치명에서 JIRA ticket ID를 추론합니다.

**수행 작업:**
- 현재 브랜치명 확인:
  ```bash
  git branch --show-current
  ```
- 브랜치명의 마지막 `/` 이후 문자열에서 `[A-Z]+-\d+` 패턴 탐색
  - 예: `feat/AIX-835` → 마지막 `/` 이후 `AIX-835` → ticket ID: `AIX-835`
  - 예: `feat/AIX-813/add-clustering` → 마지막 `/` 이후 `add-clustering` → 패턴 없음 → 브랜치 전체에서 재탐색 → `AIX-813`
- 브랜치 전체에서도 패턴이 없으면: `[NON-ISSUE]` 사용

---

### Step 4: 변경 내용 분석

**목적:** staged 파일의 변경 내용을 파악하여 커밋 메시지를 작성합니다.

**수행 작업:**
- staged diff 확인:
  ```bash
  git diff --cached
  ```
- 변경된 파일의 종류와 내용을 바탕으로 아래를 결정:
  - **type**: 변경 성격에 따라 선택 (`feat`, `fix`, `docs`, `refactor`, `chore`, `test` 등)
  - **제목(subject)**: 변경 사항을 한 줄로 요약 (영어, 50자 이내 권장)
  - **본문(body)**: 변경의 목적과 주요 내용을 bullet point로 정리 (선택, 필요 시). 파일 경로를 나열하지 말고 변경 사항을 추상적이고 읽기 쉽게 요약할 것

**type 선택 기준:**

| type | 사용 상황 |
|------|-----------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 변경 |
| `refactor` | 기능 변화 없는 코드 개선 |
| `chore` | 빌드, 설정, 의존성 변경 등 |
| `test` | 테스트 추가/수정 |
| `style` | 코드 포맷, 공백 등 스타일 변경 |

---

### Step 5: 커밋 실행

**목적:** 작성한 메시지로 커밋을 생성합니다.

**수행 작업:**
- 본문 없이 한 줄 커밋:
  ```bash
  git commit -m "feat: [AIX-835] Short description"
  ```
- 본문 포함 커밋 (변경 내용이 복잡하거나 설명이 필요한 경우):
  ```bash
  git commit -m "$(cat <<'EOF'
  feat: [AIX-835] Short description

  - 변경 내용 bullet 1
  - 변경 내용 bullet 2
  EOF
  )"
  ```

#### 커밋 실패 시 — pre-commit hook 처리

커밋이 pre-commit hook에 의해 실패한 경우, hook이 수정한 파일을 확인합니다:

```bash
git diff --name-only
```

**케이스 A: Formatter / Lint 자동 수정** (예외적으로 `git add` 허용)

hook이 파일 내용을 자동으로 수정했고, 수정 내용이 formatter(black, isort, prettier 등) 또는 linter의 자동 수정(trailing whitespace, import 정렬 등)으로 판단되는 경우:
- hook이 수정한 파일만 다시 add:
  ```bash
  git add <hook이 수정한 파일들>
  ```
- 동일한 커밋 메시지로 재시도:
  ```bash
  git commit -m "..."
  ```

**케이스 B: 사용자가 직접 수정해야 하는 변경사항**

hook이 실패 메시지를 출력하고 종료했으며, 코드 로직 오류, 타입 에러, 테스트 실패 등 사용자가 직접 수정해야 하는 경우:
- 에러 메시지를 사용자에게 전달
- **작업 종료** (사용자에게 직접 수정 후 재시도를 안내)

---

### Step 6: 결과 보고

**목적:** 커밋 완료를 사용자에게 알립니다.

**수행 작업:**
- `git log -1 --oneline` 으로 커밋 결과 확인
- 커밋 해시와 메시지를 사용자에게 전달
