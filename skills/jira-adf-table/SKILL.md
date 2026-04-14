---
name: jira-adf-table
description: Jira description/댓글에 표를 작성할 때 컬럼별 콘텐츠 길이에 비례해 colwidth 를 자동 계산한 ADF(Atlassian Document Format) JSON으로 변환하는 스킬. markdown 표가 Jira에서 컬럼이 뭉개지는 문제를 해결한다.
---

# Jira ADF Table 스킬

Jira 에디터는 **"내용에 맞춰 자동"** 컬럼 너비를 네이티브로 지원하지 않는다. markdown 표를 그대로 업로드하면 컬럼이 균등 분할되어 **짧은 컬럼은 공간이 남고 긴 컬럼은 줄바꿈**이 과하게 일어난다. 이 스킬은 markdown 표를 **가중 글자수 기반 픽셀 colwidth 가 박힌 ADF JSON**으로 변환한다.

## 언제 사용하나

- `/dct-plan` — 플랜을 Jira **description**에 올릴 때 표가 포함되면
- `/dct-complete` — 완료 요약 **댓글**에 표가 포함되면
- `/dct-job` — 위 두 단계 모두에서 자동 적용
- 그 외 `jira_update_issue`/`jira_add_comment` 로 표가 포함된 문서를 올리는 모든 상황

표가 없으면 이 스킬을 건너뛴다 (markdown 문자열 그대로 `mcp-atlassian` 에 전달하면 됨).

## 휴리스틱

### 1. 글자 가중치
| 문자 유형 | 가중치 | 유니코드 범위 |
|-----------|--------|---------------|
| 한글(Hangul) | **2** | U+AC00 ~ U+D7AF |
| CJK 한자 | **2** | U+4E00 ~ U+9FFF |
| CJK 기호 | **2** | U+3000 ~ U+303F |
| 이모지 | **2** | U+1F300 ~ U+1FAFF |
| ASCII/숫자/공백 기타 | **1** | 나머지 전부 |

### 2. 컬럼 가중치
- 각 컬럼에 대해 **헤더 + 모든 행 중 최대 가중 글자수**를 취한다
- `col_weight[i] = max(weight(row[i]) for row in rows)`

### 3. 픽셀 배분
- 전체 예산: **680px** (Jira 기본 컨테이너 너비)
- 컬럼별: `width[i] = round(680 * col_weight[i] / sum(col_weights))`
- 클램핑: **min 80px, max 500px**
- 클램핑으로 합이 680을 초과/미달하면 가장 큰 컬럼에서 차이를 흡수 (표가 망가지지 않을 정도로 보정)

### 4. 경계 케이스
- 빈 테이블(헤더만): colwidth 지정 불필요 (기본값으로 둠)
- 단일 컬럼: colwidth 지정 생략 (균등 분할로 충분)
- 컬럼 수 > 6: 전체 예산을 **900px 로 상향** (Jira wide layout 고려)

## ADF 구조 템플릿

Jira 표 하나는 `table > tableRow > (tableHeader | tableCell) > paragraph > text` 계층이다.

```json
{
  "type": "table",
  "attrs": { "isNumberColumnEnabled": false, "layout": "default" },
  "content": [
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableHeader",
          "attrs": { "colwidth": [120] },
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "컬럼1" }] }]
        },
        {
          "type": "tableHeader",
          "attrs": { "colwidth": [380] },
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "설명" }] }]
        }
      ]
    },
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableCell",
          "attrs": { "colwidth": [120] },
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "값1" }] }]
        },
        {
          "type": "tableCell",
          "attrs": { "colwidth": [380] },
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "긴 설명 텍스트가 여기에 들어간다" }] }]
        }
      ]
    }
  ]
}
```

중요 포인트:
- `colwidth` 는 **배열** (colspan=1 이면 원소 1개)
- 헤더 행은 `tableHeader`, 본문 행은 `tableCell`
- 셀 안은 **반드시 paragraph 로 감싸고** 그 안에 text 노드를 둔다 (생 text 금지)
- 전체 description/comment 를 감쌀 때는 **`doc` 루트 노드** 필요:
  ```json
  { "type": "doc", "version": 1, "content": [ <table_node>, <paragraph_node>, ... ] }
  ```

## 전체 변환 절차

### Step 1 — markdown 문서를 노드 시퀀스로 파싱
- 제목(`##`) → `heading` 노드 (`attrs.level`)
- 일반 문단 → `paragraph` 노드
- 불릿 리스트(`- `) → `bulletList > listItem > paragraph`
- 번호 리스트(`1. `) → `orderedList > listItem > paragraph`
- 코드 블록(```) → `codeBlock` 노드
- 표 (`| h1 | h2 |` + `|---|---|` + 이하 행) → 이 스킬의 변환 로직

### Step 2 — 표 노드 생성
1. 헤더 + 데이터 행 파싱
2. 컬럼별 가중 글자수 계산 (위 휴리스틱)
3. 픽셀 배분 및 클램핑
4. 위 템플릿대로 ADF 노드 조립

### Step 3 — 전체 문서를 `doc` 노드로 감싸기
```json
{ "type": "doc", "version": 1, "content": [ ... ] }
```

### Step 4 — Jira 로 업로드
두 경로 중 하나 선택:

**경로 A — mcp-atlassian 우선 시도**
```
mcp__mcp-atlassian__jira_update_issue
  issue_key: DCTC-1808
  fields: { "description": <ADF doc dict> }
```
- 최신 버전의 mcp-atlassian 은 description 에 dict 전달 시 ADF 로 pass-through
- 댓글은 `jira_add_comment` 의 `comment` 인자에 ADF dict 전달 (지원 여부 확인 필요)

**경로 B — curl fallback** (mcp-atlassian 이 dict 를 문자열화해버리는 경우)

description 업데이트:
```bash
# 토큰/URL 추출 (세션 로그 유출 방지 — 절대 echo 금지)
JIRA_URL=$(jq -r '.mcpServers["mcp-atlassian"].env.JIRA_URL' ~/.claude.json)
JIRA_USER=$(jq -r '.mcpServers["mcp-atlassian"].env.JIRA_USERNAME' ~/.claude.json)
JIRA_TOKEN=$(jq -r '.mcpServers["mcp-atlassian"].env.JIRA_API_TOKEN' ~/.claude.json)

# ADF payload 파일로 작성 (커맨드라인 노출 방지)
cat > /tmp/adf-payload.json <<'EOF'
{ "fields": { "description": <ADF doc> } }
EOF

curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
  -X PUT "$JIRA_URL/rest/api/3/issue/DCTC-1808" \
  -H "Content-Type: application/json" \
  -d @/tmp/adf-payload.json

rm /tmp/adf-payload.json
```

댓글 등록:
```bash
curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST "$JIRA_URL/rest/api/3/issue/DCTC-1808/comment" \
  -H "Content-Type: application/json" \
  -d '{ "body": <ADF doc> }'
```

## 실전 예시

### 입력 (markdown)
```markdown
## 예상 영향 파일

| 파일 | 변경 내용 | 영향도 |
|------|-----------|--------|
| src/components/Sidebar.tsx | 애니메이션 duration 조정 | 낮음 |
| src/hooks/useSidebarState.ts | 상태 리듀서 단순화 | 중간 |
| src/styles/sidebar.module.css | 클래스 네이밍 통일 | 낮음 |
```

### 컬럼 가중치 계산
| 컬럼 | 최대 가중 글자수 |
|------|------------------|
| 파일 | `src/components/Sidebar.tsx` = 27 (ASCII 1배) |
| 변경 내용 | `애니메이션 duration 조정` = 18자 중 한글 7×2 + 나머지 11 = **25** |
| 영향도 | `낮음`=4, `중간`=4 → **4** |

`sum = 27 + 25 + 4 = 56`

### 픽셀 배분 (총 680, min 80, max 500)
- 파일: `680 × 27/56 = 327px` → 327
- 변경 내용: `680 × 25/56 = 303px` → 303
- 영향도: `680 × 4/56 = 48px` → **min 클램프 80**
- 합 = 710 → 초과분 30px 을 가장 큰 컬럼(파일)에서 차감 → 최종 `[297, 303, 80]`

### 출력 ADF (일부 발췌)
```json
{
  "type": "table",
  "attrs": { "isNumberColumnEnabled": false, "layout": "default" },
  "content": [
    {
      "type": "tableRow",
      "content": [
        { "type": "tableHeader", "attrs": { "colwidth": [297] }, "content": [...] },
        { "type": "tableHeader", "attrs": { "colwidth": [303] }, "content": [...] },
        { "type": "tableHeader", "attrs": { "colwidth": [80]  }, "content": [...] }
      ]
    },
    ...
  ]
}
```

## 실패 모드와 대응

| 증상 | 원인 | 대응 |
|------|------|------|
| 업로드 후 Jira에서 여전히 균등 분할로 보임 | mcp-atlassian 이 dict 를 JSON string 으로 직렬화해버림 | 경로 B (curl) 로 재시도 |
| 400 Bad Request | ADF 루트에 `doc` 빠짐 또는 version 누락 | 최상위를 `{ "type": "doc", "version": 1, "content": [...] }` 로 감쌈 |
| 403 Forbidden | 토큰 권한 부족 / 리드온리 카드 | 사용자에게 알림 후 중단 |
| 컬럼이 한 칸으로 합쳐짐 | 셀 content 가 paragraph 로 감싸지지 않음 | 생 text 를 `{type:paragraph, content:[{type:text,text:"..."}]}` 로 wrap |

## 보안

- **토큰 출력 금지**: `JIRA_TOKEN`, `JIRA_USER` 를 절대 echo 하지 말 것. `jq` 로 추출한 값은 bash 변수에만 담고 사용 후 자동 해제되게 한다
- **임시 파일 정리**: payload 파일은 업로드 후 `rm` 필수
- `~/.claude.json` 전체를 `Read` 도구로 출력하지 말 것 — 특정 키만 `jq` 로 추출

## 규칙 준수

- **Jira 문서 가시성**: 표가 스캔 가능하게 구성되었는지 업로드 전 검토. 컬럼 3~5개 권장, 그 이상이면 표 분할 고려
- **markdown 단순 텍스트 부분**: 표가 아닌 내용(헤더/리스트/문단)도 ADF 노드로 변환해야 전체 문서가 일관됨. 표만 ADF 로 올리고 나머지를 markdown 문자열로 섞으면 mcp-atlassian 이 문자열 전체를 재해석하면서 표가 망가질 수 있음
