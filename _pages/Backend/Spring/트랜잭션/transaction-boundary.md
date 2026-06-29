---
title: "트랜잭션 경계는 서비스 유스케이스에 둔다"
date: "2026-06-29"
description: "트랜잭션을 Repository가 아니라 서비스 유스케이스 단위에서 잡아야 하는 이유를 정리합니다."
tags:
    - Backend
    - Spring
    - Transaction
thumbnail: /assets/img/thumbnail/backend-notes.png
bookmark: true
---

## 트랜잭션은 작업의 의미를 감싼다

트랜잭션은 단순히 쿼리 여러 개를 묶는 기능이 아니다. 하나의 비즈니스 작업이 성공하거나 실패해야 하는 범위를 표현한다.

예를 들어 주문 생성은 주문 저장, 결제 요청, 재고 차감이 함께 움직인다. 이 흐름 중 하나가 실패하면 전체 결과를 다시 생각해야 한다.

## Repository보다 Service가 경계를 알기 쉽다

Repository는 데이터를 어떻게 저장하고 조회하는지 안다. 하지만 어떤 저장 작업들이 하나의 유스케이스인지까지 알 필요는 없다.

```java
@Transactional
public Long createOrder(CreateOrderCommand command) {
    Order order = orderFactory.create(command);
    inventory.decrease(command.items());
    payment.reserve(order);
    return orderRepository.save(order).getId();
}
```

서비스 메서드에 트랜잭션을 두면 코드만 읽어도 실패 시 되돌려야 하는 범위가 보인다.

## 외부 API는 조심해서 섞는다

트랜잭션 안에서 외부 API를 오래 기다리면 DB 연결을 불필요하게 점유할 수 있다. 가능하면 상태를 먼저 저장하고, 외부 시스템과의 통신은 보상 처리나 이벤트 흐름으로 분리한다.

모든 작업을 하나의 트랜잭션에 넣는 것이 안정적인 설계는 아니다. 되돌릴 수 있는 것과 다시 시도해야 하는 것을 나누는 기준이 필요하다.
