# GCP CLI Agent 유의사항

## 필수 확인 사항
- `gcloud config get-value project` 로 **현재 프로젝트 확인 후 작업** (의도치 않은 프로젝트에 대한 변경 방지)
- 프로덕션 / 개발 프로젝트를 반드시 구분
- 작업 전 `gcloud auth list` 로 active account 확인 (마스킹 이메일만 출력됨)

## Cloud Storage 우선 — `gcloud storage` 사용
- **`gsutil` 대신 `gcloud storage` 사용**. 성능 2~5배 빠르고 Google 이 적극 관리
- 자주 쓰는 패턴:
  ```bash
  gcloud storage buckets list --limit=<N>        # 목록
  gcloud storage ls gs://<bucket>/               # 내용
  gcloud storage cp <local> gs://<bucket>/<path> # 업로드
  gcloud storage cp gs://<bucket>/<path> <local> # 다운로드
  gcloud storage du gs://<bucket> --summarize    # 용량 집계
  ```
- 재귀 조회는 항상 `--limit` 또는 특정 prefix 로 범위 제한

## 절대 금지 사항
- **IAM 권한(역할, 정책) 추가/삭제/수정 절대 금지** — 필요하면 사용자/담당자에게 안내만
- 사용자 확인 없이 리소스 삭제 명령 실행 금지 (`delete`, `rm`, `remove`, `destroy`)
- IAM 에 `roles/owner`, `roles/editor` 같은 광범위 역할 부여 금지 — 최소 권한 원칙
- Cloud Storage 버킷 **퍼블릭 접근** 설정 금지 (`allUsers`, `allAuthenticatedUsers` IAM binding) — 명시적 요청 없는 한
- Firewall 에 `0.0.0.0/0` 인바운드 룰 추가 금지 (SSH, RDP 등)
- **서비스 계정 JSON 키 생성 지양** — 개인 계정 인증(`gcloud auth login`) 으로 대체. JSON 키 파일은 절대 리포 커밋 금지
- `gcloud auth application-default print-access-token`, `gcloud auth print-identity-token` 등 **토큰 출력 명령 절대 실행 금지** (세션 로그 유출)
- 시크릿, 토큰, service account key 를 로그/채팅에 노출 금지

## 비용 관련 주의
- 대용량 버킷 재귀 조회 (`gcloud storage ls -r`) 는 과금 + 시간 소요 → `--limit` 필수
- **Cross-region 데이터 전송은 egress 비용**. `gcloud storage buckets describe gs://<bucket>` 로 리전 확인 후 작업
- Cloud Storage class 이전(Standard → Nearline/Coldline) 시 조회 비용 증가 경고
- BigQuery 쿼리 실행 시 **`--dry-run` 으로 스캔량 먼저 확인**. TB 단위 스캔은 사용자 승인 필수
- Compute Engine 인스턴스 생성 시 machine type 비용 영향 안내

## 작업 패턴
- 파괴적 작업 전 `--dry-run` 지원 명령은 먼저 실행 (예: `gcloud storage rm --dry-run`)
- 복잡한 인프라 변경은 Terraform / Deployment Manager 권장
- 명령 실행 후 결과 검증 명령 함께 제시
- 에러 발생 시 `--verbosity=debug` 또는 `--log-http` 로 상세 진단 (단, `--log-http` 는 요청 본문에 토큰 포함될 수 있으므로 출력 주의)
- 여러 프로젝트 사이를 전환할 때는 `gcloud config configurations` (named config) 사용
