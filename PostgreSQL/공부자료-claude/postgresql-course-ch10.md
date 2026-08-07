# 10장. 윈도우 함수 (분석 함수)

## 학습 목표

- 윈도우 함수와 집계함수의 차이를 설명할 수 있다
- `OVER`, `PARTITION BY`, `ORDER BY`로 계산 범위를 지정할 수 있다
- 순위 함수로 전체 또는 그룹 내 순위를 매길 수 있다
- 누적합, 비율, 이전·다음 행 값을 조회할 수 있다

---

## 10.1 왜 윈도우 함수가 필요한가

6장에서 배운 집계함수에는 한 가지 아쉬운 점이 있었습니다. **행이 줄어든다**는 것입니다.

```sql
SELECT ROUND(AVG(price)) AS 전체평균 FROM products;
```

| 전체평균 |
|---|
| 33100 |

평균은 알 수 있지만, **각 상품이 평균과 얼마나 차이 나는지**는 이 결과만으로 알 수 없습니다. 상품 목록이 사라졌기 때문입니다.

9장에서는 이 문제를 스칼라 서브쿼리로 해결했습니다. 하지만 더 좋은 도구가 있습니다.

**윈도우 함수**(**Window Function**)는 **행을 유지한 채로** 집계 결과를 함께 보여줍니다.

**예제 10-1.** 각 상품과 전체 평균 가격을 함께 조회합니다.

```sql
SELECT product_name, price,
       ROUND(AVG(price) OVER ()) AS 전체평균
FROM products
ORDER BY product_id;
```

| product_name | price | 전체평균 |
|---|---|---|
| 무선 이어폰 | 89000.00 | 33100 |
| 블루투스 키보드 | 45000.00 | 33100 |
| 스탠드 조명 | 32000.00 | 33100 |
| 머그컵 | 12000.00 | 33100 |
| 원두커피 1kg | 18000.00 | 33100 |
| ... 외 5건 | | |

상품 10건이 그대로 남아 있고, 각 행마다 전체 평균이 붙었습니다. 차이는 `OVER ()` 하나뿐입니다.

| | 집계함수 | 윈도우 함수 |
|---|---|---|
| 표기 | `AVG(price)` | `AVG(price) OVER (...)` |
| 결과 행 수 | 줄어듦 | **그대로 유지** |
| `GROUP BY` | 필요 | 불필요 |

> **"윈도우"라는 이름의 유래**: 각 행에서 계산에 사용할 범위를 "창문"에 비유한 것입니다. `OVER` 괄호 안에 그 창문의 크기와 모양을 적습니다. 오라클 계열에서는 **분석 함수**라고 부르는데 같은 것을 가리킵니다.

## 10.2 기본 문법 — OVER, PARTITION BY, ORDER BY

```
[문법]
함수명(인자) OVER (
    [PARTITION BY 컬럼]   -- 어떤 기준으로 나눌지
    [ORDER BY 컬럼]        -- 나눈 안에서 어떤 순서로
    [프레임]               -- 어디부터 어디까지 (10.6절)
)
```

`OVER ()`처럼 괄호를 비우면 **전체 행**이 하나의 창문이 됩니다. 예제 10-1이 그 경우입니다.

### PARTITION BY — 그룹으로 나누기

`GROUP BY`와 비슷하지만 **행을 합치지 않는다**는 점이 다릅니다.

**예제 10-2.** 각 상품과 그 상품이 속한 카테고리의 평균 가격을 함께 조회합니다.

```sql
SELECT product_name, category_id, price,
       ROUND(AVG(price) OVER (PARTITION BY category_id)) AS 카테고리평균
FROM products
ORDER BY category_id, product_id;
```

| product_name | category_id | price | 카테고리평균 |
|---|---|---|---|
| SQL 첫걸음 | 1 | 22000.00 | 24500 |
| 데이터베이스 개론 | 1 | 27000.00 | 24500 |
| 무선 이어폰 | 2 | 89000.00 | 67000 |
| 블루투스 키보드 | 2 | 45000.00 | 67000 |
| 스탠드 조명 | 3 | 32000.00 | 22000 |
| 머그컵 | 3 | 12000.00 | 22000 |
| ... 외 4건 | | | |

같은 카테고리끼리는 같은 평균값을 갖되, **상품 10건이 모두 남아 있습니다.** `GROUP BY category_id`로 했다면 5행으로 줄어들어 개별 상품명을 볼 수 없었을 것입니다.

## 10.3 순위 함수

순위를 매기는 것은 윈도우 함수의 가장 흔한 용도입니다. 이 함수들은 인자를 받지 않고 빈 괄호를 씁니다.

| 함수 | 동점 처리 |
|---|---|
| `ROW_NUMBER()` | 동점이어도 무조건 다른 번호 |
| `RANK()` | 동점은 같은 순위, 다음은 **건너뜀** (1, 1, 3) |
| `DENSE_RANK()` | 동점은 같은 순위, 다음은 **이어짐** (1, 1, 2) |
| `NTILE(n)` | n개의 그룹으로 균등 분할 |

**예제 10-3.** 상품을 비싼 순으로 번호를 매깁니다.

```sql
SELECT ROW_NUMBER() OVER (ORDER BY price DESC) AS 순위,
       product_name, price
FROM products;
```

| 순위 | product_name | price |
|---|---|---|
| 1 | 무선 이어폰 | 89000.00 |
| 2 | 블루투스 키보드 | 45000.00 |
| 3 | 후드 집업 | 42000.00 |
| 4 | 스탠드 조명 | 32000.00 |
| 5 | 데이터베이스 개론 | 27000.00 |
| 6 | 견과류 세트 | 25000.00 |
| ... 외 4건 | | |

`OVER` 안의 `ORDER BY`는 **순위를 매기는 기준**이지, 결과의 출력 순서가 아닙니다. 출력 순서는 맨 끝의 `ORDER BY`가 결정합니다. 둘은 별개이므로 서로 다르게 쓸 수도 있습니다.

### 세 순위 함수의 차이

동점이 있어야 차이가 드러납니다. `reviews`의 별점에는 5점이 두 건 있습니다.

**예제 10-4.** 세 함수를 나란히 비교합니다.

```sql
SELECT review_id, rating,
       ROW_NUMBER() OVER (ORDER BY rating DESC, review_id) AS row_number,
       RANK()       OVER (ORDER BY rating DESC)            AS rank,
       DENSE_RANK() OVER (ORDER BY rating DESC)            AS dense_rank
FROM reviews
ORDER BY rating DESC, review_id;
```

| review_id | rating | row_number | rank | dense_rank |
|---|---|---|---|---|
| 1 | 5 | 1 | 1 | 1 |
| 3 | 5 | 2 | 1 | 1 |
| 2 | 4 | 3 | 3 | 2 |
| 4 | 3 | 4 | 4 | 3 |
| 5 | 2 | 5 | 5 | 4 |

- `ROW_NUMBER`: 동점인 1번과 3번에게 1, 2를 각각 부여
- `RANK`: 둘 다 1위, 다음은 2위를 건너뛰고 **3위** (올림픽 방식)
- `DENSE_RANK`: 둘 다 1위, 다음은 **2위** (순위 번호가 끊기지 않음)

> **선택 기준**: "공동 1위가 두 명이면 다음은 3위"라는 일상적 감각은 `RANK`입니다. 등급을 나눌 때처럼 번호가 연속이어야 하면 `DENSE_RANK`, 동점 없이 순번만 필요하면 `ROW_NUMBER`를 씁니다.

### PARTITION BY와 함께 쓰기 — 그룹 내 순위

**예제 10-5.** 카테고리별로 비싼 순위를 매깁니다.

```sql
SELECT category_id, product_name, price,
       ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS 카테고리내순위
FROM products
ORDER BY category_id, 카테고리내순위;
```

| category_id | product_name | price | 카테고리내순위 |
|---|---|---|---|
| 1 | 데이터베이스 개론 | 27000.00 | 1 |
| 1 | SQL 첫걸음 | 22000.00 | 2 |
| 2 | 무선 이어폰 | 89000.00 | 1 |
| 2 | 블루투스 키보드 | 45000.00 | 2 |
| 3 | 스탠드 조명 | 32000.00 | 1 |
| 3 | 머그컵 | 12000.00 | 2 |
| ... 외 4건 | | | |

카테고리가 바뀔 때마다 순위가 1부터 다시 시작합니다.

### NTILE — 등급 나누기

**예제 10-6.** 상품을 가격순 3개 등급으로 나눕니다.

```sql
SELECT product_name, price,
       NTILE(3) OVER (ORDER BY price DESC) AS 등급
FROM products
ORDER BY price DESC;
```

| product_name | price | 등급 |
|---|---|---|
| 무선 이어폰 | 89000.00 | 1 |
| 블루투스 키보드 | 45000.00 | 1 |
| 후드 집업 | 42000.00 | 1 |
| 스탠드 조명 | 32000.00 | 1 |
| 데이터베이스 개론 | 27000.00 | 2 |
| 견과류 세트 | 25000.00 | 2 |
| SQL 첫걸음 | 22000.00 | 2 |
| 면 티셔츠 | 19000.00 | 3 |
| 원두커피 1kg | 18000.00 | 3 |
| 머그컵 | 12000.00 | 3 |

10건을 3등분하면 나누어떨어지지 않으므로, 앞쪽 그룹부터 한 건씩 더 배정되어 4, 3, 3건이 되었습니다.

## 10.4 집계 윈도우 함수

`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`에 `OVER`를 붙이면 윈도우 함수가 됩니다. `OVER` 안에 `ORDER BY`를 넣으면 **누적 계산**이 됩니다.

**예제 10-7.** 상품 가격의 누적 합계를 구합니다.

```sql
SELECT product_id, product_name, price,
       SUM(price) OVER (ORDER BY product_id) AS 누적합
FROM products
ORDER BY product_id;
```

| product_id | product_name | price | 누적합 |
|---|---|---|---|
| 1 | 무선 이어폰 | 89000.00 | 89000.00 |
| 2 | 블루투스 키보드 | 45000.00 | 134000.00 |
| 3 | 스탠드 조명 | 32000.00 | 166000.00 |
| 4 | 머그컵 | 12000.00 | 178000.00 |
| 5 | 원두커피 1kg | 18000.00 | 196000.00 |
| ... 외 5건 | | | |

마지막 행의 누적합은 전체 합계인 331,000원이 됩니다.

**여기가 핵심입니다.** `OVER` 안에 `ORDER BY`가 있으면 "처음부터 **현재 행까지**"가 기본 계산 범위가 됩니다. `ORDER BY` 없이 `SUM(price) OVER ()`라고 쓰면 모든 행이 331,000원으로 같아집니다.

**예제 10-8.** 각 상품이 전체 매출에서 차지하는 비중을 계산합니다.

```sql
SELECT product_name, price,
       ROUND(price * 100.0 / SUM(price) OVER (), 1) AS 비중
FROM products
ORDER BY product_id;
```

| product_name | price | 비중 |
|---|---|---|
| 무선 이어폰 | 89000.00 | 26.9 |
| 블루투스 키보드 | 45000.00 | 13.6 |
| 스탠드 조명 | 32000.00 | 9.7 |
| 머그컵 | 12000.00 | 3.6 |
| 원두커피 1kg | 18000.00 | 5.4 |
| ... 외 5건 | | |

"개별 값 ÷ 전체 합계"는 윈도우 함수의 대표적인 활용 패턴입니다. 서브쿼리 없이 한 줄로 끝납니다.

**예제 10-9.** 각 상품이 속한 카테고리에 상품이 몇 개인지 함께 조회합니다.

```sql
SELECT category_id, product_name,
       COUNT(*) OVER (PARTITION BY category_id) AS 카테고리상품수
FROM products
ORDER BY category_id, product_id;
```

| category_id | product_name | 카테고리상품수 |
|---|---|---|
| 1 | SQL 첫걸음 | 2 |
| 1 | 데이터베이스 개론 | 2 |
| 2 | 무선 이어폰 | 2 |
| 2 | 블루투스 키보드 | 2 |
| ... 외 6건 | | |

## 10.5 위치 함수 — LAG, LEAD

**다른 행의 값**을 현재 행으로 끌어오는 함수입니다. 시간에 따른 변화를 볼 때 특히 유용합니다.

| 함수 | 가져오는 값 |
|---|---|
| `LAG(컬럼)` | **이전** 행의 값 |
| `LEAD(컬럼)` | **다음** 행의 값 |
| `FIRST_VALUE(컬럼)` | 창문의 **첫** 행 값 |
| `LAST_VALUE(컬럼)` | 창문의 **마지막** 행 값 |

**예제 10-10.** 주문 사이의 간격을 계산합니다.

```sql
SELECT order_id, order_date,
       LAG(order_date)  OVER (ORDER BY order_date) AS 이전주문일,
       LEAD(order_date) OVER (ORDER BY order_date) AS 다음주문일,
       order_date - LAG(order_date) OVER (ORDER BY order_date) AS 간격
FROM orders
ORDER BY order_date;
```

| order_id | order_date | 이전주문일 | 다음주문일 | 간격 |
|---|---|---|---|---|
| 1 | 2025-06-01 | *(NULL)* | 2025-06-03 | *(NULL)* |
| 2 | 2025-06-03 | 2025-06-01 | 2025-06-10 | 2 |
| 3 | 2025-06-10 | 2025-06-03 | 2025-06-12 | 7 |
| 4 | 2025-06-12 | 2025-06-10 | 2025-06-15 | 2 |
| 5 | 2025-06-15 | 2025-06-12 | 2025-07-01 | 3 |
| 6 | 2025-07-01 | 2025-06-15 | *(NULL)* | 16 |

첫 행은 이전 행이 없고 마지막 행은 다음 행이 없으므로 NULL이 됩니다. 5장의 `COALESCE`로 원하는 값을 채울 수 있습니다.

**예제 10-11.** 고객별로 직전 주문일을 조회합니다.

```sql
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS 직전주문일
FROM orders
ORDER BY customer_id, order_date;
```

| customer_id | order_id | order_date | 직전주문일 |
|---|---|---|---|
| 1 | 1 | 2025-06-01 | *(NULL)* |
| 1 | 3 | 2025-06-10 | 2025-06-01 |
| 2 | 2 | 2025-06-03 | *(NULL)* |
| 3 | 4 | 2025-06-12 | *(NULL)* |
| 4 | 5 | 2025-06-15 | *(NULL)* |
| 5 | 6 | 2025-07-01 | *(NULL)* |

`PARTITION BY customer_id`가 있으므로 **다른 고객의 주문은 넘겨다보지 않습니다.** 각 고객의 첫 주문은 이전 값이 없어 NULL입니다.

## 10.6 [참고] 윈도우 프레임

`OVER` 안의 세 번째 요소인 **프레임**은 "창문의 범위"를 세밀하게 지정합니다.

```
ROWS BETWEEN 시작 AND 끝
```

| 표현 | 의미 |
|---|---|
| `UNBOUNDED PRECEDING` | 창문의 맨 처음 |
| `n PRECEDING` | n개 앞 행 |
| `CURRENT ROW` | 현재 행 |
| `n FOLLOWING` | n개 뒤 행 |
| `UNBOUNDED FOLLOWING` | 창문의 맨 끝 |

**예제 10-12.** 앞뒤 한 건씩을 포함한 3건 이동평균을 구합니다.

```sql
SELECT product_id, price,
       ROUND(AVG(price) OVER (
           ORDER BY product_id
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       )) AS 이동평균3
FROM products
ORDER BY product_id;
```

| product_id | price | 이동평균3 |
|---|---|---|
| 1 | 89000.00 | 67000 |
| 2 | 45000.00 | 55333 |
| 3 | 32000.00 | 29667 |
| 4 | 12000.00 | 20667 |
| 5 | 18000.00 | 18333 |
| ... 외 5건 | | |

1번 상품은 앞 행이 없으므로 자기 자신과 2번의 평균인 67,000이 됩니다.

### LAST_VALUE의 함정

프레임을 알아야 하는 실질적인 이유가 여기 있습니다. `OVER`에 `ORDER BY`를 쓰면 기본 프레임이 **"처음부터 현재 행까지"**인데, 이 상태에서 `LAST_VALUE`를 쓰면 "마지막 행"이 곧 "현재 행"이 되어 버립니다.

**예제 10-13.** 카테고리별 최고가·최저가 상품명을 함께 표시합니다.

```sql
SELECT category_id, product_name, price,
       FIRST_VALUE(product_name) OVER (PARTITION BY category_id ORDER BY price DESC) AS 최고가상품,
       LAST_VALUE(product_name)  OVER (PARTITION BY category_id ORDER BY price DESC) AS 최저가상품_잘못,
       LAST_VALUE(product_name)  OVER (PARTITION BY category_id ORDER BY price DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 최저가상품_정상
FROM products
ORDER BY category_id, price DESC;
```

| category_id | product_name | 최고가상품 | 최저가상품_잘못 | 최저가상품_정상 |
|---|---|---|---|---|
| 1 | 데이터베이스 개론 | 데이터베이스 개론 | 데이터베이스 개론 | SQL 첫걸음 |
| 1 | SQL 첫걸음 | 데이터베이스 개론 | SQL 첫걸음 | SQL 첫걸음 |
| 2 | 무선 이어폰 | 무선 이어폰 | 무선 이어폰 | 블루투스 키보드 |
| 2 | 블루투스 키보드 | 무선 이어폰 | 블루투스 키보드 | 블루투스 키보드 |
| ... 외 6건 | | | | |

`최저가상품_잘못` 컬럼은 자기 자신의 이름을 그대로 보여주고 있습니다. `FIRST_VALUE`는 기본 프레임에서도 정상 동작하지만 `LAST_VALUE`는 그렇지 않으므로, **프레임을 명시해야** 합니다.

> **요령**: `LAST_VALUE`를 쓰려다 헷갈린다면, 정렬 방향을 반대로 바꿔 `FIRST_VALUE`를 쓰는 편이 간단합니다.

## 10.7 윈도우 함수는 WHERE에서 쓸 수 없습니다

6장의 실행 순서를 떠올려 봅시다. 윈도우 함수는 `SELECT` 단계에서 계산되므로, 그보다 먼저 실행되는 `WHERE`와 `HAVING`에서는 사용할 수 없습니다.

```sql
-- 오류: 상위 3건만 뽑으려는 시도
SELECT product_name, ROW_NUMBER() OVER (ORDER BY price DESC) AS 순위
FROM products
WHERE ROW_NUMBER() OVER (ORDER BY price DESC) <= 3;
```

```
ERROR:  window functions are not allowed in WHERE
```

해결책은 9장에서 배운 **CTE나 인라인 뷰로 한 단계 감싸는 것**입니다.

**예제 10-14.** 카테고리별로 가장 비싼 상품 하나씩만 조회합니다.

```sql
WITH 순위 AS (
    SELECT product_name, price, category_id,
           ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS 순번
    FROM products
)
SELECT category_id, product_name, price
FROM 순위
WHERE 순번 = 1
ORDER BY category_id;
```

| category_id | product_name | price |
|---|---|---|
| 1 | 데이터베이스 개론 | 27000.00 |
| 2 | 무선 이어폰 | 89000.00 |
| 3 | 스탠드 조명 | 32000.00 |
| 4 | 견과류 세트 | 25000.00 |
| 5 | 후드 집업 | 42000.00 |

**이 패턴은 반드시 익혀 두세요.** "그룹별 상위 N건"은 실무에서 가장 자주 마주치는 요구사항인데, 윈도우 함수와 CTE를 조합하지 않으면 풀기 까다롭습니다. `순번 <= 3`으로 바꾸면 카테고리별 상위 3건이 됩니다.

---

## 요약

- 윈도우 함수는 행을 유지한 채 집계 결과를 함께 보여주며, 집계함수에 `OVER (...)`를 붙여 만든다
- `PARTITION BY`는 `GROUP BY`와 달리 행을 합치지 않고 계산 범위만 나눈다
- `OVER` 안의 `ORDER BY`는 계산 기준이지 출력 순서가 아니다
- `ROW_NUMBER`는 동점에도 다른 번호, `RANK`는 동점 후 건너뜀, `DENSE_RANK`는 동점 후 이어짐
- `OVER`에 `ORDER BY`가 있으면 "처음부터 현재 행까지"가 기본 범위가 되어 누적 계산이 된다
- `LAG`, `LEAD`로 이전·다음 행의 값을 가져올 수 있으며 경계에서는 NULL이 된다
- 윈도우 함수는 `WHERE`에서 쓸 수 없으므로, 결과에 조건을 걸려면 CTE나 인라인 뷰로 감싼다

---

## 연습문제

**문제 1** (난이도: 하)
모든 상품의 이름, 가격과 함께 전체 평균 가격을 조회하세요.

**문제 2** (난이도: 하)
상품을 비싼 순으로 순위를 매겨 조회하세요. (`RANK` 사용)

**문제 3** (난이도: 중)
각 상품과 함께 그 상품이 속한 카테고리의 평균 가격을 조회하세요.

**문제 4** (난이도: 중)
카테고리별로 저렴한 순위를 매겨 조회하세요.

**문제 5** (난이도: 중)
`reviews` 테이블에서 별점이 높은 순으로 `RANK`와 `DENSE_RANK`를 함께 조회하고, 두 값이 달라지는 지점을 확인하세요.

**문제 6** (난이도: 중)
각 리뷰와 함께 해당 상품의 평균 별점을 조회하세요. (소수점 첫째 자리까지)

**문제 7** (난이도: 중)
고객별로 몇 번째 주문인지 번호를 매겨 조회하세요.

**문제 8** (난이도: 상)
주문별 금액을 구한 뒤, 주문 번호 순으로 누적 금액을 조회하세요. (CTE 사용)

**문제 9** (난이도: 상)
전체 주문을 날짜순으로 정렬하고, 직전 주문과의 날짜 간격을 조회하세요.

**문제 10** (난이도: 상)
카테고리별로 가장 비싼 상품을 하나씩만 조회하세요.

---

## 정답 및 해설

**문제 1**
```sql
SELECT product_name, price,
       ROUND(AVG(price) OVER ()) AS 전체평균
FROM products
ORDER BY product_id;
```
전체평균은 모든 행에서 33100입니다.

**문제 2**
```sql
SELECT product_name, price,
       RANK() OVER (ORDER BY price DESC) AS 순위
FROM products
ORDER BY 순위;
```
가격이 모두 다르므로 1위 무선 이어폰부터 10위 머그컵까지 순위가 겹치지 않습니다.

**문제 3**
```sql
SELECT product_name, category_id, price,
       ROUND(AVG(price) OVER (PARTITION BY category_id)) AS 카테고리평균
FROM products
ORDER BY category_id, product_id;
```

**문제 4**
```sql
SELECT category_id, product_name, price,
       ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price ASC) AS 순위
FROM products
ORDER BY category_id, 순위;
```
예제 10-5와 정렬 방향만 반대이므로, 각 카테고리에서 1위와 2위가 뒤바뀝니다.

**문제 5**
```sql
SELECT review_id, rating,
       RANK()       OVER (ORDER BY rating DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY rating DESC) AS dense_rank
FROM reviews
ORDER BY rating DESC, review_id;
```
5점짜리 두 건 다음인 4점 리뷰에서 `rank`는 3, `dense_rank`는 2가 되어 값이 갈립니다.

**문제 6**
```sql
SELECT product_id, rating,
       ROUND(AVG(rating) OVER (PARTITION BY product_id), 1) AS 상품평균
FROM reviews
ORDER BY product_id, review_id;
```

| product_id | rating | 상품평균 |
|---|---|---|
| 1 | 5 | 4.5 |
| 1 | 4 | 4.5 |
| 4 | 3 | 3.0 |
| 7 | 5 | 5.0 |
| 9 | 2 | 2.0 |

`ROUND`를 쓰지 않으면 `4.5000000000000000`처럼 소수점이 길게 나옵니다.

**문제 7**
```sql
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS 몇번째주문
FROM orders
ORDER BY customer_id, order_date;
```
1번 고객만 1, 2가 나오고 나머지 고객은 모두 1입니다.

**문제 8**
```sql
WITH 주문금액 AS (
    SELECT order_id, SUM(quantity * unit_price) AS 금액
    FROM order_items
    GROUP BY order_id
)
SELECT order_id, 금액,
       SUM(금액) OVER (ORDER BY order_id) AS 누적금액
FROM 주문금액
ORDER BY order_id;
```

| order_id | 금액 | 누적금액 |
|---|---|---|
| 1 | 113000.00 | 113000.00 |
| 2 | 49000.00 | 162000.00 |
| 3 | 45000.00 | 207000.00 |
| 4 | 54000.00 | 261000.00 |
| 5 | 38000.00 | 299000.00 |
| 6 | 121000.00 | 420000.00 |

집계함수와 윈도우 함수를 한 쿼리에서 동시에 쓸 수 없으므로, CTE로 먼저 `GROUP BY` 집계를 끝낸 뒤 그 결과에 윈도우 함수를 적용해야 합니다.

**문제 9**
```sql
SELECT order_id, order_date,
       LAG(order_date) OVER (ORDER BY order_date) AS 이전주문일,
       order_date - LAG(order_date) OVER (ORDER BY order_date) AS 간격
FROM orders
ORDER BY order_date;
```
가장 긴 간격은 5번 주문과 6번 주문 사이의 16일입니다. 첫 주문은 비교 대상이 없어 NULL입니다.

**문제 10**
```sql
WITH 순위 AS (
    SELECT category_id, product_name, price,
           ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS 순번
    FROM products
)
SELECT category_id, product_name, price
FROM 순위
WHERE 순번 = 1
ORDER BY category_id;
```
`WHERE 순번 = 1`을 원래 쿼리에 바로 쓰면 오류가 나므로 CTE로 감싸야 합니다. `WHERE 순번 <= 3`으로 바꾸면 카테고리별 상위 3건을 얻습니다.
