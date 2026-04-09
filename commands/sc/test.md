---
allowed-tools: [Read, Bash, Glob, TodoWrite, Edit, Write]
description: "테스트 실행·리포트 생성·커버리지 관리"
---

# /sc:test — 테스트 및 품질 관리

## 목적
테스트를 실행하고 리포트를 생성하며 커버리지 기준을 유지한다.

## 사용법
```
/sc:test [대상] [--type unit|integration|e2e|all] [--coverage] [--watch] [--fix]
```

## 실행 순서
1. 테스트 탐색 및 적절한 설정으로 실행
2. 결과 모니터링, 메트릭 수집, 리포트 생성
3. 테스트 개선 권장사항 제공

## 커버리지 기준
- 단위 테스트: ≥80%
- 통합 테스트: ≥70%
