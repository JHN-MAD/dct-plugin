---
allowed-tools: [Read, Grep, Glob, Bash, TodoWrite]
description: "코드·빌드·시스템 동작의 이슈 진단 및 해결"
---

# /sc:troubleshoot — 이슈 진단 및 해결

## 목적
코드·빌드·배포·시스템 동작의 이슈를 체계적으로 진단하고 해결한다.

## 사용법
```
/sc:troubleshoot [이슈] [--type bug|build|performance|deployment] [--trace] [--fix]
```

## 실행 순서
1. 이슈 분석, 컨텍스트 수집, 잠재적 근본 원인 식별
2. 체계적 디버깅 및 진단 수행 (`systematic-debugging` 스킬 활용)
3. 해결책 제안, 수정 적용, 결과 검증

## 예시
```
/sc:troubleshoot 빌드 에러 --type build --trace
/sc:troubleshoot "로그인 후 리다이렉트 안됨" --type bug --fix
```
