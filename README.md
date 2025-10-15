# line_all

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
