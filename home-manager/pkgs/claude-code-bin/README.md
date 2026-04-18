# claude-code-bin flake

Anthropic가 배포하는 Claude Code 바이너리를 nix flake로 패키징한 저장소입니다.

현재 구성은 nixpkgs의 `claude-code-bin` 패턴을 그대로 따르되, 로컬 `manifest.json`을 직접 관리해서 `nixos-unstable`보다 더 빠르게 최신 바이너리 버전을 따라갈 수 있게 되어 있습니다.

## 이 저장소가 가져오는 것

이 저장소는 `npm` 패키지를 빌드하지 않습니다. Claude가 배포하는 공식 Claude Code 바이너리를 직접 내려받아 Nix 패키지로 감쌉니다.

- 바이너리 소스: `package.nix`의 Google Cloud Storage release URL
- 버전 고정 방식: `manifest.json`
- 무결성 검증: `manifest.json`의 플랫폼별 SHA256 checksum

즉, 이 저장소는 nixpkgs의 `claude-code-bin` 계열 패키지 방식입니다.

`2026-04-18` 기준 공식 문서에서는 npm 설치가 아직 deprecated라고 명시되어 있지는 않습니다. 다만 공식 설치 문서에서는 이미 Native Install을 권장하고 있고, npm 설치 섹션에도 npm 패키지가 플랫폼별 native binary를 설치한다고 설명되어 있습니다. 이 저장소는 그 방향에 맞춰 npm 대신 native binary를 직접 고정해서 사용하는 목적에 맞습니다.

## 파일 구성

- `flake.nix`: 패키지, app, overlay 출력
- `package.nix`: `claude-code-bin` 패키지 정의
- `manifest.json`: 현재 고정된 Claude Code 바이너리 버전과 플랫폼별 checksum
- `update.sh`: upstream 최신 `manifest.json`을 그대로 가져옴
- `update-if-needed.sh`: 현재 버전과 upstream `latest`를 비교하고 다를 때만 `update.sh` 실행

## 요구사항

- flakes가 켜진 Nix
- `allowUnfree = true`

## 직접 사용

이 디렉터리에서 바로 빌드:

```bash
nix build .#claude-code-bin
```

실행:

```bash
nix run .
```

프로필에 설치:

```bash
nix profile install .#claude-code-bin
```

## 사내 GHES에서 공유하기

이 디렉터리가 들어 있는 Git 저장소를 `oss.navercorp.com`에 올리면, 다른 사람들은 flake URL로 바로 설치할 수 있습니다.

가장 단순한 방법은 SSH 접근을 사용하는 것입니다. `github:` 단축 문법은 GitHub.com 기준이므로 GHES에는 쓰지 말고 `git+ssh://` 또는 `git+https://`를 사용하세요.

현재 dotfiles 구조에서는 이 flake가 `base` 저장소 안의 `home-manager/pkgs/claude-code-bin` 경로에 있으므로, 원격 설치 시 `dir=home-manager/pkgs/claude-code-bin`를 같이 지정하면 됩니다.

예시:

```bash
nix profile install 'git+ssh://git@oss.navercorp.com/ORG/BASE_REPO.git?ref=main&dir=home-manager/pkgs/claude-code-bin#claude-code-bin'
```

기본 패키지는 `default`도 내보내므로 아래처럼 써도 됩니다.

```bash
nix profile install 'git+ssh://git@oss.navercorp.com/ORG/BASE_REPO.git?ref=main&dir=home-manager/pkgs/claude-code-bin'
```

설치 대상을 특정 커밋으로 고정하려면 `rev`를 같이 넣으면 됩니다.

```bash
nix profile install 'git+ssh://git@oss.navercorp.com/ORG/BASE_REPO.git?ref=main&rev=COMMIT_SHA&dir=home-manager/pkgs/claude-code-bin#claude-code-bin'
```

이 경우 완전히 재현 가능하지만, `nix profile upgrade`로 최신 커밋을 따라가지는 않습니다.

반대로 `ref=main`만 두고 설치하면 이후 아래처럼 업그레이드할 수 있습니다.

```bash
nix profile upgrade --all
```

또는 이름으로 지정:

```bash
nix profile upgrade claude-code-bin
```

권장 운영 방식은 다음 둘 중 하나입니다.

- 빠르게 최신 버전을 따라갈 팀: `?ref=main`
- 검증된 버전만 배포할 팀: 릴리즈 브랜치 또는 태그를 만들고 `?ref=release` 또는 `?ref=v2.1.114`

비공개 저장소라면 설치하는 사람의 머신에서 해당 GHES 저장소를 읽을 수 있어야 합니다. 가장 무난한 방법은 각 사용자 계정에 GHES SSH 키 접근 권한을 주는 것입니다.

## Home Manager에 붙이기

현재 dotfiles 구조에서는 상위 Home Manager flake가 바로 한 단계 위 디렉터리에 있으므로, 가장 단순한 방법은 `path:./pkgs/claude-code-bin` input을 추가하고 overlay를 통해 `pkgs.claude-code-bin`을 쓰는 것입니다.

이 저장소에서는 실제로 아래 방식으로 연결하면 됩니다.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    claude-code-bin.url = "path:./pkgs/claude-code-bin";
  };

  outputs = inputs@{ nixpkgs, home-manager, claude-code-bin, ... }: {
    homeConfigurations."your-name" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = [ claude-code-bin.overlays.default ];
      };

      modules = [
        ({ pkgs, ... }: {
          home.packages = [ pkgs.claude-code-bin ];
        })
      ];
    };
  };
}
```

이미 상위 flake에서 `pkgs`를 만들고 있다면 핵심은 아래 두 줄입니다.

```nix
inputs.claude-code-bin.url = "path:./pkgs/claude-code-bin";
overlays = [ claude-code-bin.overlays.default ];
```

그리고 Home Manager 모듈에서는:

```nix
home.packages = [ pkgs.claude-code-bin ];
```

이 디렉터리 바깥의 다른 flake에서 이 subdir flake를 참조한다면 경로는 저장소 루트 기준으로 다음처럼 잡으면 됩니다.

```nix
nix profile install "$HOME/.dotfiles/base/home-manager/pkgs/claude-code-bin#claude-code-bin"
```

GHES 저장소를 input으로 잡는다면 `dir=`를 같이 지정합니다.

```nix
inputs.claude-code-bin.url = "git+ssh://git@oss.navercorp.com/ORG/BASE_REPO.git?ref=main&dir=home-manager/pkgs/claude-code-bin";
```

## 업데이트

현재 고정된 버전에서 무조건 최신 manifest로 바꾸려면:

```bash
./update.sh
```

현재 버전과 upstream 최신 버전을 비교해서, 다를 때만 업데이트하려면:

```bash
./update-if-needed.sh
```

출력 예시:

```text
local version:  2.1.114
remote version: 2.1.114
already up to date
```

새 버전이 있으면:

```text
local version:  2.1.114
remote version: 2.1.115
updating manifest.json to 2.1.115
updated manifest.json to 2.1.115
```

업데이트 후에는 보통 아래까지 같이 실행하면 됩니다.

```bash
nix build .#claude-code-bin
```

## 참고

- 이 flake는 `manifest.json`에 버전을 고정하므로 재현성이 유지됩니다.
- `latest`를 flake 평가 시점에 직접 참조하지 않습니다.
- `manifest.json`에는 `musl`/`win32` 항목도 들어 있지만, 패키지 메타는 nixpkgs 원본과 맞춰 Darwin/Linux glibc 대상만 노출합니다.
