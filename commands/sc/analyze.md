---
allowed-tools: [Read, Grep, Glob, Bash, TodoWrite]
description: "코드 품질/보안/성능/아키텍처 종합 분석"
---

# /sc:analyze — 코드 분석

## 목적
품질·보안·성능·아키텍처 전 영역을 종합적으로 분석한다.

## 사용법
```
/sc:analyze [대상] [--focus quality|security|performance|architecture] [--depth quick|deep]
```

## 실행 순서
1. 파일 탐색 및 분류, 적절한 분석 도구 적용
2. 심각도 등급과 함께 발견 사항 리포트 생성
3. 우선순위가 매겨진 실행 가능한 개선안 제시

## 예시
```
/sc:analyze src/ --focus security --depth deep
/sc:analyze ./api --focus performance
```
