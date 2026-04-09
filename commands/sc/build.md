---
allowed-tools: [Read, Bash, Glob, TodoWrite, Edit]
description: "프로젝트 빌드·컴파일·패키징 (에러 처리 및 최적화 포함)"
---

# /sc:build — 프로젝트 빌드

## 목적
에러 처리와 최적화를 동반한 빌드·컴파일·패키징 실행.

## 사용법
```
/sc:build [대상] [--type dev|prod|test] [--clean] [--optimize] [--verbose]
```

## 실행 순서
1. 프로젝트 구조 분석, 의존성·환경 검증
2. 에러 모니터링과 진단을 포함한 빌드 수행
3. 결과 최적화 및 리포트 출력
