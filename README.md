# line_all
🚀 release v1.0.0 


## 프로젝트 개요
- 컨테이너 운임 계산, 견적서 생성, 할증 옵션 등 다양한 기능을 제공하는 Flutter 기반 앱입니다.

---

## 주요 환경 및 세팅

- **Flutter SDK**: 3.35.0 (`.fvmrc`로 FVM 버전 관리)
- **Dart SDK**: >=3.9.0 <4.0.0
- **FVM**: 프로젝트별 Flutter 버전 일관성 유지

---

## 주요 의존성 패키지

- **상태관리**: `flutter_riverpod`
- **코드 생성**: `freezed`, `freezed_annotation`, `build_runner`, `json_serializable`
- **라우팅**: `go_router`
- **Firebase 연동**: `firebase_core`, `firebase_crashlytics`, `firebase_analytics`
- **국제화**: `intl`
- **반응형 UI**: `flutter_screenutil`
- **환경변수 관리**: `flutter_dotenv`
- **코드 자동 생성**: `flutter_gen_runner`
- **코드 린트**: `flutter_lints`
- **온보딩/가이드**: `tutorial_coach_mark`

---

## 개발 및 실행 방법

1. **프로젝트 클론**
   ```bash
   git clone <저장소 주소>
   cd line_all
   ```

2. **FVM Flutter 버전 설치**
   ```bash
   fvm install
   ```

3. **패키지 설치**
   ```bash
   fvm flutter pub get
   ```

4. **(필요시) 환경변수 파일(.env) 및 키 파일 별도 복사**

5. **앱 실행**
   ```bash
   fvm flutter run
   ```

---

## 기타 참고

- **pubspec.yaml**에 주요 패키지와 버전 명시
- **.fvmrc**로 Flutter 버전 고정
- **.gitignore**에 .env, 키 파일 등 민감 정보 제외 권장
- **macOS, iOS, Android, Windows 등 멀티 플랫폼 지원**

---

## 브랜치 전략(추천)

- `main`: 배포/최종 코드
- `develop`: 통합 개발(선택)
- `feature/기능명`: 기능별 개발 브랜치
- `hotfix/버그명`: 긴급 수정 브랜치

---

## 문의
- 환경 세팅, 패키지 호환, 기능 개발 등 궁금한 점은 이슈로 등록해주세요.

---

## 💡 2026년 4월 운영지침 인천/평택 할증 (스위칭 룰) 가이드

4월 고시부터 적용되는 인천/평택 지역 할증은 다른 %할증(예: 탱크 30%)의 유무에 따라 **계산 방식(Base 금액)이 대규모로 스위칭**됩니다. (모든 기점 및 거리별 구간 동일 적용)

### 1. 단독 모드 (인천/평택만 선택되었을 때)
다른 %할증 없이 순수하게 '인천' 또는 '평택' 할증만 적용될 경우:
- **운송, 운수, 안전위탁 모두**: `/api/routes`에서 가져온 **공시 운임(`routes`)만**을 최종 금액으로 바로 표출합니다. 
- 기존 탑재되어 있는 `regional-surcharge` 고정액 수치를 앱단에서 더하거나 빼는 동작을 "안 함(무효화)" 처리합니다.

### 2. 혼합 모드 (탱크 30% 등 다른 %할증이 복합 적용되었을 때)
다른 %할증(상위 3개 합산)이 포함되는 순간, 계산의 기초가 되는 Base 금액을 강제로 재설정합니다.
- **안전위탁운임**: 기점/거리 상관없이 무조건 **역산**을 수행합니다. 
  - `Base = round((routes / divRate) / 10) * 10`
  - *divRate: 인천(1.2), 평택(1.18)*
- **안전운송 & 운수사업자간운임**: 기점/거리 상관없이 무조건 **차감**을 수행합니다.
  - `Base = routes - regional_API값`

> **결론**: 단독 모드에서는 **`routes`**가 불변의 진리! 혼합 모드에서는 **안전위탁은 역산(`/1.2 or 1.18`)**, **운송/운수는 차감(`-regional`)**을 Base로 사용하여 계산의 완벽한 일관성과 무결성을 확보했습니다.
