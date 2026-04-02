# Jira & Wiki CLI Skills

CLI 도구를 사용하여 Jira 이슈와 Confluence Wiki를 터미널에서 관리하는 Claude Code 스킬입니다.

## Skills 개요

### 1. jira-cli
Jira 이슈를 조회, 생성, 수정, 삭제하는 CLI 도구 스킬

**위치**: `.claude/skills/jira-cli/SKILL.md`

**사용 방법**:
- Claude가 Jira 작업 시 자동으로 활성화
- 또는 `/jira-cli <command> <args>` 형태로 직접 호출

**주요 기능**:
- 이슈 조회, 생성, 수정, 삭제
- 댓글 및 워크로그 관리
- 첨부파일 업로드/다운로드
- 이슈 링크 및 전환 관리
- JQL 검색
- 프로젝트, 보드, 스프린트 관리

### 2. wiki-cli
Confluence Wiki 페이지를 조회, 생성, 수정, 삭제하는 CLI 도구 스킬

**위치**: `.claude/skills/wiki-cli/SKILL.md`

**사용 방법**:
- Claude가 Wiki 작업 시 자동으로 활성화
- 또는 `/wiki-cli <command> <args>` 형태로 직접 호출

**주요 기능**:
- 페이지 조회, 생성, 수정, 삭제
- 버전 히스토리 및 비교
- 첨부파일 관리
- 라벨 관리
- 페이지 검색
- 콘텐츠 형식 변환

---

## CLI 도구 설치

### 필수 요구사항
```bash
brew install node   # Node.js 20+
brew install gh     # GitHub CLI (GHE 인증 필요)
```

### 설치 방법

**방법 1: 한 줄 설치 (권장)**
```bash
gh release download --repo sang-mook-kang/jira-wiki-cli --pattern "jira" --pattern "wiki" --dir ~/.local/bin --clobber && chmod +x ~/.local/bin/jira ~/.local/bin/wiki
```

**방법 2: install.sh 사용**
```bash
gh repo clone sang-mook-kang/jira-wiki-cli /tmp/jwc && bash /tmp/jwc/install.sh && rm -rf /tmp/jwc
```

**PATH 설정** (최초 1회, `~/.local/bin`이 PATH에 없는 경우)
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

---

## 인증 설정

### macOS 키체인에 토큰 저장 (권장)
```bash
# Jira 토큰 저장
security add-generic-password -s JIRA_PAT -w <your-jira-token>

# Wiki 토큰 저장
security add-generic-password -s WIKI_PAT -w <your-wiki-token>

# 저장된 토큰 확인
security find-generic-password -s JIRA_PAT -w
security find-generic-password -s WIKI_PAT -w
```

### .env 파일 사용 (폴백)
`~/.config/jira-wiki-cli/.env` 파일에 다음 내용 추가:
```dotenv
JIRA_PAT=<your-jira-token>
WIKI_PAT=<your-wiki-token>
```

> **보안 주의:** 가능하면 키체인을 사용하세요.

---

## 스킬 적용 방법

### 개인 설정 (모든 프로젝트에서 사용)
```bash
# 스킬 디렉토리 복사
cp -r .claude/skills/jira-cli ~/.claude/skills/
cp -r .claude/skills/wiki-cli ~/.claude/skills/
```

### 프로젝트별 설정
프로젝트 루트의 `.claude/skills/` 디렉토리에 스킬을 복사하거나, 이 저장소를 git submodule로 추가하여 사용할 수 있습니다.

---

## 빠른 시작

### Jira 이슈 조회
```bash
# Claude Code에서 다음과 같이 요청
"Show me issue PROJ-123"
"Search for open issues in project PROJ"
"What's the status of PROJ-456?"
```

### Jira 이슈 생성
```bash
"Create a new task in project PROJ to fix login bug"
"Add a comment to PROJ-123 saying the fix is ready"
```

### Wiki 페이지 조회
```bash
"Show me the wiki page 987654"
"Search for API documentation in TEAM space"
```

### Wiki 페이지 생성
```bash
"Create a new wiki page in TEAM space about deployment guide"
"Update wiki page 987654 with the new API changes"
```

---

## 명령어 참고 (빠른 레퍼런스)

### Jira CLI 주요 명령어

```bash
# 조회
jira <key>                                    # 이슈 조회
jira search "JQL query"                       # JQL 검색
jira comments <key>                           # 댓글 조회

# 생성/수정
jira create --project PROJ --type Task --summary "Title"
jira update <key> --summary "New title"
jira comment <key> "Comment text"

# 워크플로우
jira transitions <key>                        # 가능한 전환 확인
jira transition <key> <transitionId>          # 상태 변경

# 첨부파일
jira attach <key> ./file.png                  # 파일 업로드
jira attachments <key>                        # 첨부파일 목록

# 링크
jira link <key> <targetKey> --type Blocks     # 이슈 링크
jira links <key>                              # 링크 조회

# 프로젝트/보드
jira projects                                 # 프로젝트 목록
jira boards                                   # 보드 목록
jira sprints <boardId>                        # 스프린트 목록
```

### Wiki CLI 주요 명령어

```bash
# 조회
wiki <pageId>                                 # 페이지 조회
wiki search "keyword"                         # 검색
wiki get-by-title <spaceKey> "Title"          # 제목으로 조회

# 생성/수정
wiki create --space SPACE --title "Title" --body "<p>Content</p>"
wiki update <pageId> --title "New Title"
wiki update <pageId> --body "<p>New content</p>"

# 버전 관리
wiki versions <pageId>                        # 버전 목록
wiki diff <pageId> 3 4                        # 버전 비교

# 첨부파일
wiki attach <pageId> ./file.png               # 파일 업로드
wiki attachments <pageId>                     # 첨부파일 목록

# 라벨
wiki label-add <pageId> <label>               # 라벨 추가
wiki labels <pageId>                          # 라벨 조회

# 계층
wiki children <pageId>                        # 자식 페이지 조회

# 스페이스
wiki spaces                                   # 스페이스 목록
wiki space <spaceKey>                         # 스페이스 상세
```

---

## 공통 옵션

모든 명령어에서 사용 가능:

| 옵션 | 설명 |
|---|---|
| `--json` | JSON 출력 (파싱용) |
| `--format <type>` | 출력 포맷: text, json, wrapped-json, raw-json |
| `--fields <f1,f2>` | 특정 필드만 출력 |
| `--limit <n>` | 결과 수 제한 |
| `--offset <n>` | 시작 위치 (0-based) |

---

## 종료 코드

| 코드 | 의미 | 재시도 | 설명 |
|:---:|------|:---:|------|
| 0 | 성공 | — | 정상 완료 |
| 1 | 입력 오류 | ✗ | 잘못된 인자, 형식 오류 |
| 2 | 인증 오류 | ✗ | 토큰 없음/만료, 401/403 |
| 3 | 리소스 없음 | ✗ | 404, 검색 결과 없음 |
| 4 | 네트워크 오류 | ✓ | 연결 실패, 429, 5xx |
| 5 | 타임아웃 | ✓ | 요청 시간 초과, 408 |

---

## 트러블슈팅

### 인증 오류 (종료 코드 2)
```bash
# 토큰 확인
security find-generic-password -s JIRA_PAT -w
security find-generic-password -s WIKI_PAT -w

# 현재 사용자 확인
jira me
wiki me
```

### 리소스 없음 (종료 코드 3)
- 이슈 키나 페이지 ID 확인
- 검색 조건 재검토
- 접근 권한 확인

### 네트워크 오류 (종료 코드 4, 5)
- 네트워크 연결 확인
- 잠시 후 재시도
- VPN 연결 상태 확인

### 스킬이 로드되지 않을 때
```bash
# 스킬 위치 확인
ls -la ~/.claude/skills/jira-cli/
ls -la ~/.claude/skills/wiki-cli/

# 또는 프로젝트 스킬 확인
ls -la .claude/skills/jira-cli/
ls -la .claude/skills/wiki-cli/

# Claude Code 재시작
# 또는 "What skills are available?" 로 확인
```

---

## 사용 예시

### Jira 워크플로우

```bash
# 1. 현재 할당된 이슈 확인
jira search "assignee = currentUser() AND status = 'In Progress'"

# 2. 특정 이슈 상세 조회
jira PROJ-123

# 3. 댓글 추가
jira comment PROJ-123 "작업 완료했습니다. 리뷰 부탁드립니다."

# 4. 상태 전환 (In Progress → Review)
jira transitions PROJ-123
jira transition PROJ-123 31

# 5. 첨부파일 추가
jira attach PROJ-123 ./screenshot.png
```

### Wiki 워크플로우

```bash
# 1. 페이지 검색
wiki search "API 문서" --space TEAM --first

# 2. 새 페이지 생성
wiki create --space TEAM --title "API 가이드" --body "<p>새로운 API 문서</p>"

# 3. 페이지 업데이트
wiki update 987654 --body "<p>업데이트된 내용</p>"

# 4. 첨부파일 추가
wiki attach 987654 ./api-diagram.png

# 5. 라벨 추가
wiki label-add 987654 documentation
wiki label-add 987654 api
```

---

## 추가 문서

- **상세 스킬 문서**:
  - [`.claude/skills/jira-cli/SKILL.md`](.claude/skills/jira-cli/SKILL.md) - Jira CLI 전체 명령어 및 사용법
  - [`.claude/skills/wiki-cli/SKILL.md`](.claude/skills/wiki-cli/SKILL.md) - Wiki CLI 전체 명령어 및 사용법
- **원본 프로젝트**: https://git.linecorp.com/sang-mook-kang/jira-wiki-cli
- **Claude Code 스킬 문서**: https://code.claude.com/docs/ko/skills
