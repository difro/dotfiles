# codex flake

OpenAI Codex CLI의 공식 nixpkgs `codex` 패키지 정의를 로컬 flake로 분리한 구성입니다.

이 패키지는 upstream GitHub release tarball을 직접 설치하지 않고, nixpkgs와 동일하게 `openai/codex`의 Rust source를 빌드합니다.

## 파일 구성

- `flake.nix`: 패키지, app, overlay 출력
- `package.nix`: nixpkgs `codex` 패키지 정의
- `fetchers.nix`, `librusty_v8.nix`: V8 prebuilt archive와 src binding fetcher
- `update.sh`: 최신 stable release로 `package.nix`의 version/source hash/cargo hash 갱신 후
  `nix build`로 패키지가 실제로 빌드되는지 검증
- `update-if-needed.sh`: 현재 버전과 upstream 최신 stable release를 비교하고 다를 때만 업데이트
- `nixpkgs-upstream.nix`: nixpkgs master `codex` 레시피의 스냅샷 (수정 금지).
  `watch-nixpkgs.yml` 워크플로우가 매주 nixpkgs master와 비교해서 달라지면 이슈를 만들고 스냅샷을 갱신함

## nixpkgs와의 차이

레시피는 nixpkgs master를 그대로 따르고, version/source hash/cargo hash만 upstream 최신
release를 앞서갑니다. 의도적 차이를 새로 만들면 이 섹션에 기록하세요.

현재 차이: rusty_v8 prebuilt를 denoland/rusty_v8 release가 아니라 openai/codex의
`rusty-v8-v<version>` release에서 받고, `RUSTY_V8_SRC_BINDING_PATH`도 같이 넘깁니다.
0.147.0의 `code-mode-runtime`이 v8 crate의 `v8_enable_sandbox` feature를 켜는데,
denoland는 그 조합(`ptrcomp_sandbox_release`)의 prebuilt를 배포하지 않습니다.
nixpkgs가 같은 문제를 해결하면 스냅샷 diff로 확인 후 그쪽 방식에 맞추면 됩니다.

## 직접 사용

```bash
nix build .#codex
nix run .
nix profile install .#codex
```

## Home Manager에 붙이기

상위 Home Manager flake에서 input과 overlay를 추가합니다.

```nix
inputs.codex.url = "path:./pkgs/codex";
overlays = [ codex.overlays.default ];
```

Home Manager 모듈에서는 `pkgs.codex`를 설치합니다.

```nix
home.packages = [ pkgs.codex ];
```

## 업데이트

```bash
./update-if-needed.sh
```

업데이트 스크립트는 GitHub latest release의 `rust-vX.Y.Z` 태그를 읽고, source hash와 Cargo vendor hash를 다시 계산합니다.
