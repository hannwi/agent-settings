# agent-settings

AI 에이전트 작업을 위한 모든 설정 모음:
- 글로벌 설정
- 에이전트 설정
- MCP 설정
- 에이전트 스킬
- 지시문, 프롬프트
- 기타

## Global Settings for Claude Code
- `.claude/settings.json`
    - Claude Code Premium Seat 사용자를 위한 글로벌 설정 파일.
    - 이 파일의 내용을 `~/.claude/settings.json`에 복사해서 사용하세요.

## Agent Settings

`.claude/agents/`에 있는 에이전트 목록:

1. **plan-agent** — 코드베이스를 분석하고 구현 계획을 `.claude/plan.md`에 작성합니다.
2. **code-agent** — `.claude/plan.md`를 읽고 계획을 단계별로 구현합니다.
3. **test-runner-agent** — code-agent 완료 후 테스트를 실행하고 결과를 보고합니다.

## Skills

`.claude/skills/`에 있는 Claude Code 스킬 목록:

### jira-cli
Jira 이슈와 프로젝트를 터미널에서 조회·생성·수정·삭제하는 스킬. JQL 검색, 댓글·워크로그·첨부파일 관리, 스프린트/에픽/보드 작업을 지원합니다.

**CLI 도구:** [https://git.linecorp.com/sang-mook-kang/jira-wiki-cli](https://git.linecorp.com/sang-mook-kang/jira-wiki-cli)
> 사용 전 CLI 설치와 인증(PAT 토큰) 설정이 필요합니다. 위 GitHub 저장소의 README를 참고해 세팅해두세요.

### wiki-cli
Confluence Wiki 페이지를 터미널에서 조회·생성·수정·삭제하는 스킬. 버전 히스토리, 첨부파일·라벨 관리, 페이지 계층 탐색, 콘텐츠 형식 변환을 지원합니다.

**CLI 도구:** [https://git.linecorp.com/sang-mook-kang/jira-wiki-cli](https://git.linecorp.com/sang-mook-kang/jira-wiki-cli)
> 사용 전 CLI 설치와 인증(PAT 토큰) 설정이 필요합니다. 위 GitHub 저장소의 README를 참고해 세팅해두세요.

### skill-creator ([ref](https://github.com/anthropics/skills/blob/main/skills/skill-creator))
새 스킬을 작성하거나 기존 스킬을 개선하고 평가하는 스킬. 스킬 초안 작성, 테스트 케이스 실행, 정량적 벤치마크, 트리거 설명 최적화를 지원합니다.

---

## Scripts

### apply_agents.sh

`scripts/apply_agents.sh`를 사용해 이 저장소의 에이전트 설정을 Claude 에이전트 디렉터리에 복사합니다.

#### Usage

```
bash scripts/apply_agents.sh [--local] [--project-root PATH] [--agents AGENT ...]
```

| Option | Description |
|---|---|
| `--local` | 글로벌 `~/.claude/` 대신 로컬 프로젝트에 적용 |
| `--project-root PATH` | 로컬 프로젝트의 루트 경로 (`--local` 사용 시 필수) |
| `--agents AGENT ...` | 적용할 에이전트 이름 (`.md` 제외). 생략 시 전체 적용 |

같은 이름의 에이전트가 대상 위치에 이미 있으면 덮어쓰기 전에 확인을 요청합니다.

#### Examples

```bash
# 모든 에이전트를 글로벌 ~/.claude/agents/ 디렉터리에 적용 (기본값)
bash scripts/apply_agents.sh

# 특정 에이전트만 글로벌 적용
bash scripts/apply_agents.sh --agents plan-agent code-agent

# 모든 에이전트를 로컬 프로젝트에 적용
bash scripts/apply_agents.sh --local --project-root ~/projects/my-app

# 특정 에이전트를 로컬 프로젝트에 적용
bash scripts/apply_agents.sh --local --project-root ~/projects/my-app --agents plan-agent
```

### apply_skills.sh

`scripts/apply_skills.sh`를 사용해 이 저장소의 스킬을 Claude 스킬 디렉터리에 복사합니다.

#### Usage

```
bash scripts/apply_skills.sh [--local] [--project-root PATH] [--skills SKILL ...]
```

| Option | Description |
|---|---|
| `--local` | 글로벌 `~/.claude/` 대신 로컬 프로젝트에 적용 |
| `--project-root PATH` | 로컬 프로젝트의 루트 경로 (`--local` 사용 시 필수) |
| `--skills SKILL ...` | 적용할 스킬 이름 (폴더명). 생략 시 전체 적용 |

같은 이름의 스킬이 대상 위치에 이미 있으면 덮어쓰기 전에 확인을 요청합니다.

#### Examples

```bash
# 모든 스킬을 글로벌 ~/.claude/skills/ 디렉터리에 적용 (기본값)
bash scripts/apply_skills.sh

# 특정 스킬만 글로벌 적용
bash scripts/apply_skills.sh --skills jira-cli wiki-cli

# 모든 스킬을 로컬 프로젝트에 적용
bash scripts/apply_skills.sh --local --project-root ~/projects/my-app

# 특정 스킬을 로컬 프로젝트에 적용
bash scripts/apply_skills.sh --local --project-root ~/projects/my-app --skills jira-cli
```
