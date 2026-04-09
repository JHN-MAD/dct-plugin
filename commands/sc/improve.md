---
allowed-tools: [Read, Grep, Glob, Edit, MultiEdit, TodoWrite]
description: "코드 품질·성능·유지보수성·스타일 개선을 체계적으로 적용"
---

# /sc:improve — 코드 개선

## 목적
코드 품질·성능·유지보수성·스타일을 체계적으로 개선한다.

## 사용법
```
/sc:improve [대상] [--type quality|performance|maintainability|style] [--safe] [--preview]
```

## 실행 순서
1. 개선 기회 분석 및 리스크 평가
2. 개선 계획 작성·적용 및 검증
3. 개선 결과 확인 및 변경사항 리포트

## 예시
```
/sc:improve src/utils --type quality --safe
/sc:improve ./api/handlers --type performance --preview
```
