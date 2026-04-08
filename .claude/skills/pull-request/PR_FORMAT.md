# PR Format Guide

이 문서는 최근 PR 3개와 `.github/pull_request_template.md`, `.github/line_devtools.yml`을 분석하여 도출한 PR 작성 규칙과 예시입니다.

---

## 제목(Title) 규칙

유효한 PR 제목은 다음 정규식을 만족해야 합니다:

```
^([a-z]+: )*\[([A-Z]+-\d+(,[A-Z]+-\d+)*|NON-ISSUE|DEPLOY)\]\s.*$
```

구조:

```
[type: ][ISSUE-ID] Short description
```

- **type** (선택): 소문자 + 콜론 + 공백. 예: `feat: `, `fix: `, `docs: `, `refactor: `
- **ISSUE-ID**: 대문자 프로젝트 코드 + 하이픈 + 숫자. 예: `[AIX-835]`, `[AIS-1234]`, `[DDAI-42]`
  - 복수 이슈: `[AIX-835,AIS-1234]`
  - Jira 이슈 없음: `[NON-ISSUE]`
  - 배포 PR: `[DEPLOY]`
- **Short description**: 이슈 ID 뒤 공백 후 변경 내용을 간결하게 기술

### 유효한 제목 예시

```
feat: [AIX-831] Added opensearch logging function
feat: [AIX-826] Added Dockerfile
[AIX-813] Add feedback-clustering pipeline
[AIS-1234] Fix authentication bug
[AIX-835,AIX-836] Update pipeline config and prompts
[NON-ISSUE] Fix typo in README
[DEPLOY] feat/AIX-835 → main
```

---

## 본문(Body) 작성 방법

**반드시 `.github/pull_request_template.md` 템플릿을 기반으로 본문을 작성합니다.**

전체 템플릿 구조는 다음과 같습니다:

```markdown
## Type of change

- [ ] ✨ Feature
- [ ] 🔧 Bugfix
- [ ] 📚 Documentation Changes
- [ ] 🎨 Code Style Update
- [ ] 📦 Refactoring
- [ ] 🧠 Testing Updates
- [ ] 🚀 Build and CI Changes
- [ ] 🚨 Deployment (dev → beta → main)
- [ ] 🔍 Security Enhancements
- [ ] ❓ Other... Please describe:

## Link
- Jira / Wiki / Slack:

## Description in detail
- (if you want to describe in detail)
```

### 본문 작성 규칙

1. **Type of change**: 체크박스 목록 전체를 유지하고, 해당 항목만 `[x]`로 표시. 나머지는 `[ ]` 그대로 둠.
2. **Link**: Jira 이슈 ID 또는 URL, Wiki, Slack 링크 등을 기재.
3. **Description in detail**: 변경 사항의 목적, 배경, 영향 범위 등을 상세히 설명.

---

## 실제 PR 예시

### PR #14 — feat: [AIX-831] Added opensearch logging function

**Title:** `feat: [AIX-831] Added opensearch logging function`

**Body:**
```markdown
## Type of change

- [x] ✨ Feature
- [ ] 🔧 Bugfix
- [ ] 📚 Documentation Changes
- [ ] 🎨 Code Style Update
- [ ] 📦 Refactoring
- [ ] 🧠 Testing Updates
- [ ] 🚀 Build and CI Changes
- [ ] 🚨 Deployment (dev → beta → main)
- [ ] 🔍 Security Enhancements
- [ ] ❓ Other... Please describe:

## Link
- Jira / Wiki / Slack: AIX-831

## Description in detail
- 스크립트 실행 모드가 아닌, 서버 모드일 때, 지정된 Opensearch 클러스터에 로그를 적재하는 기능을 추가했습니다.
- Opensearch 엔드포인트, ID, PW 는 직접 환경 변수로 넣어주어야 합니다.
- 현재 AI-Next 용 Opensearch 클러스터가 준비되어 있고, AI-Next Verda Server 에서 해당 클러스터에 로깅을 적재하고 있으며, AI-Next showroom 에서 해당 verda server 를 사용하고 있습니다.
```

---

### PR #13 — feat: [AIX-826] Added Dockerfile

**Title:** `feat: [AIX-826] Added Dockerfile`

**Body:**
```markdown
## Type of change

- [x] ✨ Feature
- [ ] 🔧 Bugfix
- [ ] 📚 Documentation Changes
- [ ] 🎨 Code Style Update
- [ ] 📦 Refactoring
- [ ] 🧠 Testing Updates
- [ ] 🚀 Build and CI Changes
- [ ] 🚨 Deployment (dev → beta → main)
- [ ] 🔍 Security Enhancements
- [ ] ❓ Other... Please describe:

## Link
- Jira / Wiki / Slack: AIX-826

## Description in detail
- 도커 빌드를 위한 도커파일을 추가합니다.
- 도커 환경에서 API 서버를 구동하기 위해 사용합니다.
```

---

### PR #12 — [AIX-813] Add feedback-clustering pipeline

**Title:** `[AIX-813] Add feedback-clustering pipeline`

**Body:**
```markdown
## Type of change

- [x] ✨ Feature
- [ ] 🔧 Bugfix
- [ ] 📚 Documentation Changes
- [ ] 🎨 Code Style Update
- [ ] 📦 Refactoring
- [ ] 🧠 Testing Updates
- [ ] 🚀 Build and CI Changes
- [ ] 🚨 Deployment (dev → beta → main)
- [ ] 🔍 Security Enhancements
- [ ] ❓ Other... Please describe:

## Link
- Jira / Wiki / Slack:
https://jira.workers-hub.com/browse/AIX-813
https://wiki.workers-hub.com/display/LINEDSP/DDAI+-+AITS+-+Eval+-+Criteria+-+00.+Feedback-based+clustering

## Description in detail
- Add feedback-clustering pipeline
```
