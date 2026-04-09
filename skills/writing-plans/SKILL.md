---
name: writing-plans
description: 사양이나 요구사항이 있을 때 다중-단계 작업을 위해, 코드 건드리기 전에 사용
---

# Writing Plans

## 개요

포괄적 구현 계획을 작성하되, 우리 코드베이스에 대해 거의 또는 전혀 맥락이 없고 의심스러운 취향의 엔지니어를 가정하라. 문서화해라 모든 것을 : 각 작업에서 건드릴 파일, 코드, 테스트, 확인해야 할 문서, 테스트 방법. 전체 계획을 작은 작업 단위로 제공하라. DRY. YAGNI. TDD. 자주 커밋.

그들은 숙련된 개발자라고 가정하되, 우리 도구세트나 문제 영역을 거의 모른다고 가정하라. 좋은 테스트 디자인을 잘 알지 못한다고 가정하라.

**시작할 때 발표:** "나는 writing-plans 스킬을 사용해서 구현 계획을 만들고 있다."

**맥락:** 이것은 전용 worktree에서 실행되어야 한다 (brainstorming 스킬로 만듦).

**계획 저장처:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## 작은 작업 단위 크기

**각 단계는 하나의 동작 (2-5분):**
- "실패 테스트 작성" - 단계
- "실패하는지 확인하기 위해 실행" - 단계
- "테스트 통과하는 최소 코드 구현" - 단계
- "테스트 실행하고 통과하는지 확인" - 단계
- "커밋" - 단계

## 계획 문서 헤더

**모든 계획은 이 헤더로 시작해야 한다:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [한 문장으로 이것이 뭘 만드는지 설명]

**Architecture:** [2-3문장 접근 방식 설명]

**Tech Stack:** [핵심 기술/라이브러리]

---
```

## 작업 구조

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## 기억할 것
- 정확한 파일 경로 항상
- 계획에 완전한 코드 (단순히 "검증 추가"가 아님)
- 정확한 명령과 예상 출력
- @ 문법으로 관련 스킬 참조
- DRY, YAGNI, TDD, 자주 커밋

## 실행 인수

계획 저장 후, 실행 선택지 제공:

**"계획 완료, `docs/plans/<filename>.md`에 저장됨. 두 가지 실행 옵션:**

**1. Subagent-Driven (이 세션)** - 각 작업마다 새 subagent 파견, 작업 간 검토, 빠른 반복

**2. Parallel Session (별도)** - executing-plans로 새 세션 열기, 체크포인트 있는 배치 실행

**어떤 접근?"**

**Subagent-Driven 선택되면:**
- **필수 SUB-SKILL:** `superpowers:subagent-driven-development` 사용
- 이 세션 유지
- 각 작업마다 새 subagent + 코드 검토

**Parallel Session 선택되면:**
- worktree에서 새 세션 열기 안내
- **필수 SUB-SKILL:** 새 세션은 `superpowers:executing-plans` 사용
