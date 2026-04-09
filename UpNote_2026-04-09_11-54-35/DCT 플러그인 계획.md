## DCT 플러그인 계획

개요 :  데이터 컨설팅 초반 AI Native 개발 환경에 빠른 적응을 돕기위해

Claude 작업 환경을 구성을 도와주고, 깃허브 MCP, Atlassian MCP 를 통해 DataConsulting 팀(이하 데컨팀)의 워크플로우를 도와주는 플러그인

<br>

<br>

<br>

1. 현재 dct-jira 관련된 스킬을 설정해놨는데 이거를 플러그인으로 구현하고자 함
2. [https://github.com/hyunseok-blue/claude-team-config/](https://github.com/hyunseok-blue/claude-team-config/blob/main/core/CLAUDE.md) 해당 리포지토리를 개조해서 플러그인으로 만들고자 함
3. 데컨팀만의 워크플로우 플러그인을 구성
4. /dct : 데이터 컨설팅 온보딩 스킬
    - [claude-team-config](https://github.com/hyunseok-blue/claude-team-config/tree/main) 리포 전역에 settings-example.json을 사용자가 우선 작성 유도
        - 지라 셋팅
            - {  
  "$schema": "[https://json.schemastore.org/claude-code-settings.json](https://json.schemastore.org/claude-code-settings.json)",  
  "mcpServers": {  
    "mcp-atlassian": {  
      "command": "uvx",  
      "args": \["mcp-atlassian"\],  
      "env": {  
        "JIRA\_URL": "[https://madup.atlassian.net/jira/software/projects/DCTC/boards/274](https://madup.atlassian.net/jira/software/projects/DCTC/boards/274)",  
        "JIRA\_USERNAME": ["your-email@example.com",](mailto:"your-email@example.com",)  
        "JIRA\_API\_TOKEN": "YOUR\_API\_TOKEN\_HERE",  
        "CONFLUENCE\_URL": "[https://madup.atlassian.net/wiki/spaces/DCT/overview](https://madup.atlassian.net/wiki/spaces/DCT/overview)",  
        "CONFLUENCE\_USERNAME": ["your-email@example.com",](mailto:"your-email@example.com",)  
        "CONFLUENCE\_API\_TOKEN": "YOUR\_API\_TOKEN\_HERE"  
      }  
    }  
  }  
}  

        - 깃허브 셋팅 :
            - ssh 생성해서 깃헙 등록 후 해당 ssh를 사용해서 gh mcp 연결하도록 유도
            - ssh 명칭에는 dct가 들어갔으면 함

    - 입력 정보로 MCP 설정을 진행
5. /dct-job : jira 스토리를 통해 작업을 수행함을 명시함
    - 입력 아규먼트 (예시 : /dct-job DCTC-1234 fix jobs.md
        - 스토리 번호 : 지라에서 발급된 카드 번호 (DCTC-1234)
        - 작업종류 : feature, fix, refactor 등…. 
        - 작업 명령 : 입력 혹은 문서 경로를 작성하여 하고자 하는 작업에 대한 설명을 입력한다.
            - 예 : “프론트에 사이드바 애니메이션을 개선할거야" or “./docs/job.md

    - 입력한 아규먼트 정보로 dev 부모 브랜치로부터 브랜치 생성 or 이미 있으면 체크아웃
    - 메모리 기록 네임에 스토리번호를 넣어서 
    - 해당 작업 명령을 읽고 작업 범위가 넓은지 판단해서 심층깊은 플랜이 필요하다 싶으면 플랜모드로 플랜을 작성
    - 병렬로 작업하는 게 효율적인지 아닌지 분석해서 사용자에게 제안
    - 플랜작성을 완료하고 작업을 시작하기 전에 DCTC-1234 내용에 해당 플랜을 작성
    - 작업이 완료되고 해당 Jira 카드에 전체 작업 내용을 댓글로 정리 (Jira 팀플로우 규칙을 따름) 
6. [CLAUDE.md](https://CLAUDE.md "https://CLAUDE.md")
    - 플러그인 설정 후 DCT 팀에게 기본적으로 셋팅하고자 하는 CLAUDE 설정, 해당 문서 경로에 있는 rules들 또한 깔려 있어야함
    - ```
# 규칙 인덱스 (On-Demand Loading)

모든 사용자 규칙은 `~/.claude/rules/` 에서 관리된다. **전체 규칙을 자동으로 로드하지 말 것.**
아래 인덱스에서 현재 작업과 관련된 규칙 파일만 `Read` 도구로 읽어 적용한다. (컨텍스트 절약)

## 상시 적용 (세션 시작 시 1회 Read 권장)
- `~/.claude/rules/korean-dev.md` — 응답 언어(한국어), 커밋/네이밍 컨벤션
- `~/.claude/rules/personal.md` — 사용 정책 관련 금지사항
- `~/.claude/rules/performance.md` — 모델 선택, 컨텍스트 관리
- `~/.claude/rules/agents.md` — 서브에이전트 위임 기준

## 상황별 (트리거 시 Read)
- `~/.claude/rules/python.md` — Python(.py, pytest, poetry 등) 작업 시
- `~/.claude/rules/team-workflow.md` — GitHub 브랜치/커밋, Jira, Confluence 작업 시
- `~/.claude/rules/doc-updates.md` — 작업 완료 직전 (문서 동기화 체크)

## 운영 원칙
- 트리거 키워드가 없으면 해당 규칙을 읽지 않는다.
- 동일 세션 내 이미 읽은 규칙은 재-Read 하지 않는다.
- 새 규칙은 이 인덱스에 한 줄씩 추가한다 (본문을 CLAUDE.md에 인라인하지 말 것).
```

<br>