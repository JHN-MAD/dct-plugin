---
name: requesting-code-review
description: 작업 완료, 주요 기능 구현, 또는 병합 전에 요구사항 충족 검증을 위해 사용
---

# Requesting Code Review

문제가 연쇄되기 전에 문제를 잡기 위해 superpowers:code-reviewer subagent 파견.

**핵심 원칙:** 자주, 일찍 검토.

## 언제 검토 요청하는가

**필수:**
- subagent-driven 개발에서 각 작업 후
- 주요 기능 완료 후
- main으로 병합 전

**선택적이지만 가치 있음:**
- 막혔을 때 (신선한 관점)
- 리팩토링 전 (기본선 확인)
- 복잡한 버그 고친 후

## 요청 방법

**1. Git SHA 가져오기:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 또는 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. code-reviewer subagent 파견:**

Task 도구와 superpowers:code-reviewer 타입 사용, `code-reviewer.md`에 템플릿 채우기

**플레이스홀더:**
- `{WHAT_WAS_IMPLEMENTED}` - 방금 만든 것
- `{PLAN_OR_REQUIREMENTS}` - 뭘 해야 하는지
- `{BASE_SHA}` - 시작 커밋
- `{HEAD_SHA}` - 끝 커밋
- `{DESCRIPTION}` - 짧은 요약

**3. 피드백에 행동:**
- Critical 문제 즉시 고치기
- Important 문제는 진행 전 고치기
- Minor 문제는 나중을 위해 메모하기
- 리뷰어가 틀렸으면 밀어붙이기 (이유 있게)

## 예시

```
[방금 Task 2 완료: 검증 함수 추가]

You: 진행하기 전에 코드 검토 요청하자.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: 대화 인덱스를 위한 검증 및 복구 함수
  PLAN_OR_REQUIREMENTS: docs/plans/deployment-plan.md의 Task 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: 4가지 이슈 타입으로 verifyIndex() 및 repairIndex() 추가

[Subagent 반환]:
  강점: 깔끔한 아키텍처, 실제 테스트
  이슈:
    Important: 진행 지표 누락
    Minor: 보고 간격의 매직 숫자 (100)
  평가: 진행 준비됨

You: [진행 지표 고치기]
[Task 3로 진행]
```

## 워크플로우와의 통합

**Subagent-Driven 개발:**
- 각 작업 후 검토
- 문제가 복합되기 전에 잡기
- 다음 작업으로 가기 전에 고치기

**계획 실행:**
- 각 배치 후 검토 (3개 작업)
- 피드백 받기, 적용, 계속

**Ad-Hoc 개발:**
- 병합 전 검토
- 막혔을 때 검토

## 빨간 깃발

**절대로:**
- "간단하니까" 검토 건너뛰기
- Critical 문제 무시
- 고쳐지지 않은 Important 문제로 진행
- 유효한 기술적 피드백과 논쟁

**리뷰어가 틀렸으면:**
- 기술적 추론으로 밀어붙이기
- 테스트/코드로 작동하는 거 보여주기
- 명확화 요청

템플릿 참조: requesting-code-review/code-reviewer.md
