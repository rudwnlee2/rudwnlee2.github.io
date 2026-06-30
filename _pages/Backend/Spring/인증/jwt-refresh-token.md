---
title: "JWT Refresh Token 재발급 흐름 정리"
date: "2026-06-29"
description: "Access Token 만료 이후 Refresh Token으로 인증 상태를 이어가는 흐름과 예외 기준을 정리합니다."
keyword: "JWT"
tags:
    - Backend
    - Spring
    - 인증
thumbnail: /assets/img/thumbnail/backend-notes.png
bookmark: true
---

## Access Token은 짧게 둔다

Access Token은 요청마다 사용되기 때문에 노출 가능성을 항상 고려해야 한다. 그래서 만료 시간을 짧게 두고, 사용자가 계속 서비스를 이용할 때만 Refresh Token으로 새 토큰을 발급한다.

짧은 만료 시간은 보안에는 유리하지만 사용자 경험을 해칠 수 있다. 재발급 흐름은 이 균형을 맞추는 장치다.

## Refresh Token은 저장 기준이 중요하다

Refresh Token은 단순히 긴 만료 시간을 가진 토큰이 아니다. 서버가 회수하거나 교체할 수 있어야 하므로 저장소에 상태를 남기는 편이 안전하다.

```java
public TokenPair reissue(String refreshToken) {
    RefreshToken savedToken = refreshTokenRepository.findValidToken(refreshToken)
        .orElseThrow(InvalidTokenException::new);

    return tokenIssuer.issue(savedToken.getMemberId());
}
```

핵심은 토큰 문자열 자체보다 서버가 유효성을 판단할 수 있는 기준이다. 만료, 로그아웃, 재발급 이력 같은 상태를 저장해야 운영 중 문제를 추적할 수 있다.

## 재발급 실패는 명확해야 한다

재발급이 실패했을 때는 다시 로그인해야 하는 상황인지, 일시적인 오류인지 구분해야 한다.

- 만료된 Refresh Token은 재로그인을 요구한다.
- 저장소에 없는 토큰은 탈취나 변조 가능성으로 본다.
- 이미 교체된 토큰은 재사용 공격으로 다룬다.

인증 흐름은 모호하면 디버깅하기 어렵다. 실패 이유를 내부 로그에 남기고, 사용자에게는 필요한 행동만 안내하는 편이 좋다.
