---
allowed-tools: [Read, Write, Edit, MultiEdit, Bash, Glob, TodoWrite, Task]
description: "기능/컴포넌트 구현 — 지능형 페르소나 자동 활성화 및 MCP 통합"
---

# /sc:implement — 기능 구현

## 목적
기능·컴포넌트·코드를 전문가 페르소나 자동 활성화와 함께 구현한다.

## 사용법
```
/sc:implement [기능설명] [--type component|api|service|feature] [--framework 이름] [--safe] [--with-tests]
```

## 실행 순서
1. 요구사항 분석, 기술 컨텍스트 감지, 페르소나 자동 활성화
2. 모범 사례와 MCP 지원(Magic for UI, Context7 for patterns)으로 구현
3. 보안/품질 검증 및 테스트 권장사항 제공

## 예시
```
/sc:implement 사용자 인증 시스템 --type feature --with-tests
/sc:implement 대시보드 컴포넌트 --type component --framework react
/sc:implement 결제 API --type api --with-tests
```
