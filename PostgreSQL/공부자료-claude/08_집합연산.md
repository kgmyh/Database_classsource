# 8장. 집합 연산

## 학습 목표

- 여러 조회 결과를 하나로 합치거나 비교할 수 있다
- `UNION`과 `UNION ALL`의 차이를 설명하고 상황에 맞게 선택할 수 있다
- `INTERSECT`, `EXCEPT`로 두 결과의 교집합과 차집합을 구할 수 있다
- 집합 연산과 JOIN이 각각 어떤 상황에 맞는지 구분할 수 있다

---

## 8.1 집합 연산이란

7장의 JOIN은 두 테이블을 **옆으로** 붙였습니다. 고객 테이블의 컬럼과 주문 테이블의 컬럼이 한 줄에 나란히 놓였죠.

이번 장에서 배우는 **집합 연산**(**Set Operation**)은 두 조회 결과를 **위아래로** 쌓거나, 서로 비교해서 공통된 것만 남기거나 빼는 연산입니다.

```
    JOIN (가로 결합)              집합 연산 (세로 결합)
  ┌─────┬─────┐                 ┌─────────┐
  │  A  │  B  │                 │    A    │
  └─────┴─────┘                 ├─────────┤
                                │    B    │
                                └─────────┘
```

| 연산자 | 의미 | 수학 기호 |
|---|---|---|
| `UNION` | 합집합 (중복 제거) | A ∪ B |
| `UNION ALL` | 합집합 (중복 유지) | — |
| `INTERSECT` | 교집합 | A ∩ B |
| `EXCEPT` | 차집합 | A − B |

```
[문법]
SELECT 컬럼 [, ...] FROM 테이블A
집합연산자
SELECT 컬럼 [, ...] FROM 테이블B
[ORDER BY 컬럼];
```

## 8.2 집합 연산의 조건

집합 연산을 쓰려면 위아래 두 `SELECT`가 **모양이 맞아야** 합니다. 조건은 두 가지입니다.

1. **컬럼의 개수가 같아야 합니다**
2. **서로 대응하는 컬럼의 데이터 타입이 호환되어야 합니다**

조건을 어기면 바로 오류가 납니다.

```sql
-- 오류: 위는 컬럼 2개, 아래는 1개
SELECT customer_id, customer_name FROM customers
UNION
SELECT product_id FROM products;
```

```
ERROR:  each UNION query must have the same number of columns
```

```sql
-- 오류: 문자열과 숫자는 짝지을 수 없습니다
SELECT customer_name FROM customers
UNION
SELECT price FROM products;
```

```
ERROR:  UNION types character varying and numeric cannot be matched
```

### 결과의 컬럼 이름은 첫 번째 SELECT를 따릅니다

두 번째 `SELECT`에 별칭을 붙여도 무시됩니다.

```sql
SELECT customer_name AS 이름 FROM customers WHERE customer_id = 1
UNION ALL
SELECT product_name AS 상품 FROM products WHERE product_id = 1;
```

| 이름 |
|---|
| 김민준 |
| 무선 이어폰 |

두 번째 별칭인 "상품"은 사라지고 "이름"만 남았습니다. 컬럼 이름을 정하고 싶다면 **첫 번째 SELECT에** 별칭을 붙이세요.

> **자주 하는 실수**: 컬럼 개수만 맞추고 **순서**를 신경 쓰지 않으면, 오류 없이 엉뚱한 데이터가 섞입니다. 위 예제처럼 이름 자리에 상품명이 들어가도 데이터베이스는 막아주지 않습니다. 두 SELECT의 컬럼을 같은 순서로 맞추는 것은 작성자의 책임입니다.

## 8.3 UNION과 UNION ALL

두 결과를 위아래로 합칩니다. 둘의 차이는 **중복 처리**입니다.

- `UNION ALL` : 중복을 그대로 둡니다
- `UNION` : 중복된 행을 하나로 합칩니다

**예제 8-1.** 주문한 고객과 리뷰를 쓴 고객의 ID를 모두 나열합니다.

```sql
SELECT customer_id FROM orders
UNION ALL
SELECT customer_id FROM reviews;
```

| customer_id |
|---|
| 1 |
| 2 |
| 1 |
| 3 |
| 4 |
| 5 |
| ... 외 5건 |

주문 6건과 리뷰 5건이 그대로 쌓여 **11건**이 나옵니다. 같은 고객이 여러 번 등장합니다.

**예제 8-2.** 같은 쿼리를 `UNION`으로 바꿉니다.

```sql
SELECT customer_id FROM orders
UNION
SELECT customer_id FROM reviews
ORDER BY customer_id;
```

| customer_id |
|---|
| 1 |
| 2 |
| 3 |
| 4 |
| 5 |

중복이 제거되어 **5건**이 되었습니다. "주문했거나 리뷰를 쓴 적이 있는 고객"의 목록입니다.

### 어느 것을 써야 할까

**중복이 생길 수 없다는 것을 알고 있다면 `UNION ALL`을 쓰세요.** `UNION`은 중복을 없애기 위해 내부적으로 정렬·비교 작업을 하므로 데이터가 많을수록 느려집니다. 중복 제거가 필요 없는데 습관적으로 `UNION`을 쓰는 것은 불필요한 낭비입니다.

**예제 8-3.** 고객과 직원을 하나의 연락처 목록으로 만듭니다.

```sql
SELECT '고객' AS 구분, customer_id AS 번호, customer_name AS 이름
FROM customers
UNION ALL
SELECT '직원', employee_id, employee_name
FROM employees
ORDER BY 구분, 번호;
```

| 구분 | 번호 | 이름 |
|---|---|---|
| 고객 | 1 | 김민준 |
| 고객 | 2 | 이서연 |
| 고객 | 3 | 박도윤 |
| 고객 | 4 | 최지우 |
| 고객 | 5 | 정하은 |
| 직원 | 1 | 강태호 |
| 직원 | 2 | 오유진 |
| 직원 | 3 | 한지민 |
| 직원 | 4 | 윤성민 |

고객과 직원은 서로 다른 사람이므로 중복이 있을 수 없습니다. 그래서 `UNION ALL`이 맞습니다.

`'고객'`, `'직원'`처럼 **고정된 값을 컬럼으로 만든** 점에도 주목하세요. 이렇게 하지 않으면 합쳐진 결과에서 어느 쪽 출신인지 구분할 수 없습니다. 집합 연산에서 자주 쓰는 기법입니다.

## 8.4 INTERSECT — 교집합

양쪽 결과에 **모두 있는** 행만 남깁니다.

**예제 8-4.** 주문도 하고 리뷰도 쓴 고객을 찾습니다.

```sql
SELECT customer_id FROM orders
INTERSECT
SELECT customer_id FROM reviews
ORDER BY customer_id;
```

| customer_id |
|---|
| 1 |
| 2 |
| 4 |
| 5 |

3번 고객(박도윤)은 주문은 했지만 리뷰를 쓰지 않아 빠졌습니다.

**예제 8-5.** 판매도 되고 리뷰도 달린 상품을 찾습니다.

```sql
SELECT product_id FROM order_items
INTERSECT
SELECT product_id FROM reviews
ORDER BY product_id;
```

| product_id |
|---|
| 1 |
| 4 |
| 7 |
| 9 |

`INTERSECT`도 결과에서 중복을 제거합니다. 무선 이어폰(1번)은 두 번 판매되고 리뷰도 두 건이지만 결과에는 한 번만 나옵니다.

## 8.5 EXCEPT — 차집합

앞쪽 결과에는 있고 **뒤쪽 결과에는 없는** 행만 남깁니다.

**예제 8-6.** 주문은 했지만 리뷰를 쓰지 않은 고객을 찾습니다.

```sql
SELECT customer_id FROM orders
EXCEPT
SELECT customer_id FROM reviews
ORDER BY customer_id;
```

| customer_id |
|---|
| 3 |

### 순서가 결과를 바꿉니다

`UNION`과 `INTERSECT`는 위아래를 바꿔도 결과가 같습니다. 하지만 `EXCEPT`는 **뺄셈이므로 순서가 중요합니다.**

**예제 8-7.** 예제 8-6의 위아래를 바꿔 봅니다.

```sql
SELECT customer_id FROM reviews
EXCEPT
SELECT customer_id FROM orders
ORDER BY customer_id;
```

| customer_id |
|---|
| (조회된 행 없음) |

"리뷰는 썼지만 주문한 적 없는 고객"을 찾는 쿼리이고, 그런 고객은 없으므로 결과가 비어 있습니다. 의미가 완전히 다른 질문이라는 점을 확인하세요.

**예제 8-8.** 한 번도 판매되지 않은 상품을 찾습니다.

```sql
SELECT product_id FROM products
EXCEPT
SELECT product_id FROM order_items
ORDER BY product_id;
```

| product_id |
|---|
| 6 |
| 10 |

7장의 예제 7-6과 **같은 결과**입니다. 그때는 `LEFT JOIN` + `IS NULL`로 풀었죠. 이 관계는 다음 절에서 정리합니다.

## 8.6 연산자 우선순위

집합 연산을 세 개 이상 이어 쓸 때는 계산 순서에 주의해야 합니다. **`INTERSECT`가 `UNION`, `EXCEPT`보다 먼저** 계산됩니다. 산술 연산에서 곱셈이 덧셈보다 먼저인 것과 같은 원리입니다.

**예제 8-9.** 괄호 유무에 따라 결과가 달라집니다.

```sql
-- 괄호 없음: INTERSECT가 먼저 계산됩니다
SELECT product_id FROM products WHERE category_id = 4
UNION
SELECT product_id FROM products WHERE category_id = 5
INTERSECT
SELECT product_id FROM order_items
ORDER BY product_id;
```

| product_id |
|---|
| 5 |
| 6 |
| 9 |

```sql
-- 괄호로 UNION을 먼저 계산
(SELECT product_id FROM products WHERE category_id = 4
 UNION
 SELECT product_id FROM products WHERE category_id = 5)
INTERSECT
SELECT product_id FROM order_items
ORDER BY product_id;
```

| product_id |
|---|
| 5 |
| 9 |

첫 번째 쿼리는 "식품 전체" + "(의류 중 판매된 것)"이라 6번(견과류 세트, 판매 안 됨)이 포함됩니다. 두 번째는 "(식품 + 의류) 중 판매된 것"이라 6번이 걸러집니다.

의도를 분명히 하고 읽는 사람의 오해를 막으려면 **괄호를 명시적으로 쓰는 습관**을 권장합니다.

## 8.7 ORDER BY와 LIMIT의 위치

`ORDER BY`는 개별 `SELECT`가 아니라 **합쳐진 전체 결과**에 적용됩니다. 그래서 **맨 마지막에 한 번만** 쓸 수 있습니다.

```sql
-- 오류: 중간에 ORDER BY를 쓸 수 없습니다
SELECT customer_id FROM orders ORDER BY customer_id
UNION
SELECT customer_id FROM reviews;
```

```
ERROR:  syntax error at or near "UNION"
```

`LIMIT`도 마찬가지로 전체 결과에 적용됩니다. 개별 `SELECT`에 `ORDER BY`나 `LIMIT`을 걸어야 한다면 그 `SELECT`를 괄호로 감싸야 합니다.

```sql
(SELECT product_id FROM products WHERE category_id = 1
 UNION
 SELECT product_id FROM products WHERE category_id = 2)
ORDER BY product_id
LIMIT 3;
```

| product_id |
|---|
| 1 |
| 2 |
| 7 |

## 8.8 집합 연산과 JOIN, 언제 무엇을 쓸까

예제 8-8에서 봤듯 같은 문제를 두 방법으로 풀 수 있는 경우가 있습니다. 정리하면 이렇습니다.

| | 집합 연산 | JOIN |
|---|---|---|
| 결합 방향 | 세로 (행을 쌓음) | 가로 (컬럼을 붙임) |
| 컬럼 구성 | 양쪽이 같아야 함 | 자유롭게 조합 가능 |
| 결과 컬럼 | 한쪽 분량 | 양쪽 컬럼 모두 |

**판단 기준은 "다른 테이블의 컬럼이 결과에 필요한가"입니다.**

- 상품 ID만 알면 충분하다 → `EXCEPT`가 간결합니다
- 상품 ID와 함께 **이름, 가격도** 보여줘야 한다 → JOIN이 필요합니다

```sql
-- 집합 연산: ID만 얻을 수 있습니다
SELECT product_id FROM products
EXCEPT
SELECT product_id FROM order_items;

-- JOIN: 다른 컬럼도 함께 가져올 수 있습니다
SELECT p.product_id, p.product_name, p.price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;
```

또 한 가지 실용적인 차이가 있습니다. `INTERSECT`와 `EXCEPT`는 **중복을 자동으로 제거**하므로 결과 건수가 깔끔합니다. 반면 JOIN은 1:N 관계에서 행이 늘어날 수 있어 `DISTINCT`가 필요해지기도 합니다.

> 실무에서는 서로 다른 테이블의 정보를 함께 봐야 하는 경우가 압도적으로 많아 JOIN을 훨씬 자주 씁니다. 집합 연산은 "같은 형태의 결과를 합치거나 비교할 때" 쓰는 보조 도구로 이해하면 좋습니다.

---

## 요약

- 집합 연산은 두 조회 결과를 세로로 합치거나 비교하며, 컬럼 개수와 타입이 맞아야 한다
- 결과의 컬럼 이름은 첫 번째 `SELECT`를 따른다
- `UNION`은 중복을 제거하고 `UNION ALL`은 유지한다. 중복이 없다면 더 빠른 `UNION ALL`을 쓴다
- `INTERSECT`는 교집합, `EXCEPT`는 차집합이며, `EXCEPT`는 순서에 따라 결과가 달라진다
- `INTERSECT`가 `UNION`, `EXCEPT`보다 먼저 계산되므로 괄호로 순서를 명시하는 것이 안전하다
- `ORDER BY`와 `LIMIT`은 합쳐진 전체 결과에 적용되며 맨 끝에 한 번만 쓴다
- 다른 테이블의 컬럼까지 필요하면 JOIN을, 같은 형태의 목록을 합치거나 비교하는 것이라면 집합 연산을 쓴다

---

## 연습문제

**문제 1** (난이도: 하)
모든 고객의 이름과 모든 직원의 이름을 하나의 목록으로 조회하세요.

**문제 2** (난이도: 하)
문제 1의 결과에 "고객" 또는 "직원"을 표시하는 구분 컬럼을 추가하세요.

**문제 3** (난이도: 중)
주문한 적이 있거나 리뷰를 쓴 적이 있는 고객의 ID를 중복 없이 조회하세요.

**문제 4** (난이도: 중)
주문도 하고 리뷰도 쓴 고객의 ID를 조회하세요.

**문제 5** (난이도: 중)
주문은 했지만 리뷰를 쓰지 않은 고객의 ID를 조회하세요.

**문제 6** (난이도: 중)
한 번도 판매되지 않은 상품의 ID를 조회하세요.

**문제 7** (난이도: 중)
판매는 되었지만 리뷰가 달리지 않은 상품의 ID를 조회하세요.

**문제 8** (난이도: 상)
가격이 30,000원 이상이거나 재고가 50개 이상인 상품의 ID를 집합 연산으로 조회하세요.

**문제 9** (난이도: 상)
리뷰가 달린 상품 중 실제로 판매된 적이 있는 상품의 ID를 조회하세요.

**문제 10** (난이도: 상)
문제 6을 JOIN으로 다시 작성하되, 상품 ID뿐 아니라 상품명과 가격도 함께 조회하세요.

---

## 정답 및 해설

**문제 1**
```sql
SELECT customer_name FROM customers
UNION ALL
SELECT employee_name FROM employees;
```
9건입니다. 고객과 직원이 겹칠 수 없으므로 `UNION ALL`이 적절합니다.

**문제 2**
```sql
SELECT '고객' AS 구분, customer_id AS 번호, customer_name AS 이름
FROM customers
UNION ALL
SELECT '직원', employee_id, employee_name
FROM employees
ORDER BY 구분, 번호;
```
고정 문자열을 컬럼으로 만들어 출처를 표시하는 방법입니다.

**문제 3**
```sql
SELECT customer_id FROM orders
UNION
SELECT customer_id FROM reviews
ORDER BY customer_id;
```
1부터 5까지 5건입니다. 여기서는 중복 제거가 목적이므로 `UNION ALL`이 아니라 `UNION`을 써야 합니다.

**문제 4**
```sql
SELECT customer_id FROM orders
INTERSECT
SELECT customer_id FROM reviews
ORDER BY customer_id;
```
1, 2, 4, 5번 고객입니다.

**문제 5**
```sql
SELECT customer_id FROM orders
EXCEPT
SELECT customer_id FROM reviews
ORDER BY customer_id;
```
3번 고객(박도윤)입니다. 순서를 바꾸면 "리뷰는 썼지만 주문 안 한 고객"이 되어 결과가 비게 됩니다.

**문제 6**
```sql
SELECT product_id FROM products
EXCEPT
SELECT product_id FROM order_items
ORDER BY product_id;
```
6번(견과류 세트), 10번(후드 집업)입니다.

**문제 7**
```sql
SELECT product_id FROM order_items
EXCEPT
SELECT product_id FROM reviews
ORDER BY product_id;
```

| product_id |
|---|
| 2 |
| 3 |
| 5 |
| 8 |

**문제 8**
```sql
SELECT product_id FROM products WHERE price >= 30000
UNION
SELECT product_id FROM products WHERE stock_quantity >= 50
ORDER BY product_id;
```

| product_id |
|---|
| 1 |
| 2 |
| 3 |
| 4 |
| 5 |
| 9 |
| 10 |

같은 테이블을 두 번 조회하고 있으므로, 사실 `WHERE price >= 30000 OR stock_quantity >= 50` 한 줄로도 같은 결과를 얻습니다. **같은 테이블에 대한 OR 조건이라면 `WHERE`가 더 간단합니다.** 집합 연산은 서로 다른 테이블이나 서로 다른 형태의 조회를 합칠 때 진가를 발휘합니다.

**문제 9**
```sql
SELECT product_id FROM reviews
INTERSECT
SELECT product_id FROM order_items
ORDER BY product_id;
```
1, 4, 7, 9번 상품입니다. `INTERSECT`는 순서를 바꿔도 결과가 같습니다.

**문제 10**
```sql
SELECT p.product_id, p.product_name, p.price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL
ORDER BY p.product_id;
```

| product_id | product_name | price |
|---|---|---|
| 6 | 견과류 세트 | 25000.00 |
| 10 | 후드 집업 | 42000.00 |

`EXCEPT`로는 `product_id`밖에 얻을 수 없습니다. 상품명과 가격처럼 다른 컬럼이 필요한 순간 JOIN으로 바꿔야 한다는 것이 8.8절의 판단 기준입니다.
