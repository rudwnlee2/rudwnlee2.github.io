---
title: "Stream 파이프라인은 읽는 순서대로 둔다"
date: "2026-06-29"
description: "Java Stream을 사용할 때 필터, 변환, 수집 단계를 읽기 쉬운 순서로 배치하는 기준입니다."
tags:
    - Backend
    - Java
    - Stream
thumbnail: /assets/img/thumbnail/backend-notes.png
bookmark: true
---

## Stream은 데이터 흐름을 보여준다

Stream을 쓰는 이유는 반복문을 줄이기 위해서만은 아니다. 데이터가 어떤 조건을 통과하고, 어떤 형태로 바뀌며, 어떤 결과로 모이는지 한 줄의 흐름으로 보여줄 수 있다.

하지만 체인이 길어지면 오히려 읽기 어려워진다. 각 단계가 자연스럽게 이어지는지가 더 중요하다.

## 조건은 먼저, 변환은 나중에 둔다

불필요한 데이터를 먼저 걸러내면 뒤의 변환 로직이 단순해진다.

```java
List<MemberSummary> summaries = members.stream()
    .filter(Member::isActive)
    .filter(member -> member.hasRole(Role.BACKEND))
    .map(MemberSummary::from)
    .toList();
```

이 코드는 활성 사용자 중 Backend 역할을 가진 사람만 요약 객체로 바꾼다. 읽는 순서가 요구사항의 순서와 같으면 리뷰하기 쉽다.

## 중간 값에 이름이 필요하면 나눈다

Stream 체인이 길어져서 중간 결과의 의미를 설명해야 한다면 변수로 나누는 편이 낫다. 한 줄에 다 담는 것보다 이름 있는 두 단계가 더 읽기 쉬울 때가 많다.

좋은 Stream 코드는 짧은 코드가 아니라 다시 읽었을 때 의도가 바로 보이는 코드다.
