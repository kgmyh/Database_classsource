# 6장. 집계함수와 GROUP BY

## 학습 목표

- 집계함수로 여러 행을 하나의 값으로 요약할 수 있다
- `COUNT(*)`와 `COUNT(컬럼)`의 차이를 NULL과 연관지어 설명할 수 있다
- `GROUP BY`로 데이터를 그룹으로 나누어 집계할 수 있다
- `HAVING`으로 집계 결과에 조건을 걸 수 있고, `WHERE`와의 차이를 설명할 수 있다

---

## 6.1 집계함수란

5장에서 다룬 스칼라 함수는 **행 하나마다** 결과를 하나씩 만들었습니다. 상품 10건을 조회하면 결과도 10건이었죠.

하지만 "상품이 전부 몇 개인가", "평균 가격은 얼마인가"처럼 **여러 행을 하나의 값으로 요약**해야 할 때가 있습니다. 이때 사용하는 것이 **집계함수**(**Aggregate Function**)입니다.

```
10개의 행  →  [ 집계함수 ]  →  1개의 결과
```

| 함수 | 설명 |
|---|---|
| `COUNT(*)` | 행의 개수 |
| `SUM(컬럼)` | 합계 |
| `AVG(컬럼)` | 평균 |
| `MIN(컬럼)` | 최솟값 |
| `MAX(컬럼)` | 최댓값 |

**예제 6-1.** 등록된 상품이 몇 개인지 셉니다.

```sql
SELECT COUNT(*) AS 상품수
FROM products;
```

| 상품수 |
|---|
| 10 |

10개의 행이 하나의 행으로 요약되었습니다. 이것이 스칼라 함수와의 결정적인 차이입니다.

**예제 6-2.** 상품 가격의 합계, 평균, 최저가, 최고가를 한 번에 구합니다.

```sql
SELECT SUM(price)            AS 합계,
       ROUND(AVG(price), 1)  AS 평균,
       MIN(price)            AS 최저,
       MAX(price)            AS 최고
FROM products;
```

| 합계 | 평균 | 최저 | 최고 |
|---|---|---|---|
| 331000.00 | 33100.0 | 12000.00 | 89000.00 |

`AVG`의 결과는 소수점이 길게 나오는 경우가 많으므로, 5장에서 배운 `ROUND`로 감싸 정리하면 읽기 좋습니다.

> `MIN`과 `MAX`는 숫자뿐 아니라 문자열과 날짜에도 사용할 수 있습니다. `MIN(order_date)`는 가장 오래된 주문일을 돌려줍니다.

## 6.2 COUNT(*)와 COUNT(컬럼)의 차이

집계함수에서 입문자가 가장 많이 실수하는 부분입니다. 결론부터 말하면 이렇습니다.

- `COUNT(*)` : **행의 개수**를 셉니다. NULL이 있든 없든 상관없습니다
- `COUNT(컬럼)` : 그 컬럼이 **NULL이 아닌 행의 개수**를 셉니다

**예제 6-3.** 고객 수와 전화번호가 등록된 고객 수를 비교합니다.

```sql
SELECT COUNT(*)     AS 전체행,
       COUNT(phone) AS 전화번호있는행
FROM customers;
```

| 전체행 | 전화번호있는행 |
|---|---|
| 5 | 4 |

고객은 5명이지만 박도윤 고객의 `phone`이 NULL이므로 `COUNT(phone)`은 4입니다. 4장에서 배운 "NULL은 값이 아니라 알 수 없는 상태"라는 원칙이 여기서도 그대로 적용됩니다.

**예제 6-4.** 주문 중 담당 직원이 배정되지 않은 건이 있는지 확인합니다.

```sql
SELECT COUNT(*)           AS 전체주문,
       COUNT(employee_id) AS 담당자있는주문
FROM orders;
```

| 전체주문 | 담당자있는주문 |
|---|---|
| 6 | 5 |

두 값의 차이인 1건이 담당자가 배정되지 않은 주문입니다.

> **자주 하는 실수**: "전체 건수를 세려고" `COUNT(어떤컬럼)`을 썼는데 실제보다 적게 나온다면, 그 컬럼에 NULL이 섞여 있는 것입니다. 행의 개수를 세려는 의도라면 항상 `COUNT(*)`를 쓰세요.

### 다른 집계함수도 NULL을 무시합니다

`SUM`, `AVG`, `MIN`, `MAX`도 NULL인 행을 계산에서 제외합니다. 특히 `AVG`에서 주의가 필요합니다.

`AVG(rating)`은 **NULL을 0으로 치는 것이 아니라 아예 빼고** 평균을 냅니다. 즉 분모가 달라집니다. NULL을 0으로 취급해서 평균을 내고 싶다면 5장의 `COALESCE`로 먼저 값을 채워야 합니다.

```sql
-- NULL을 제외하고 평균을 냄
SELECT AVG(rating) FROM reviews;

-- NULL을 0으로 채운 뒤 평균을 냄 (분모가 달라짐)
SELECT AVG(COALESCE(rating, 0)) FROM reviews;
```

### COUNT(DISTINCT 컬럼) — 중복 없이 세기

집계함수 안에 `DISTINCT`를 넣으면 중복을 제거한 뒤 집계합니다.

**예제 6-5.** 주문 건수와 실제로 주문한 고객 수를 비교합니다.

```sql
SELECT COUNT(*)                    AS 주문수,
       COUNT(DISTINCT customer_id) AS 주문한고객수
FROM orders;
```

| 주문수 | 주문한고객수 |
|---|---|
| 6 | 5 |

주문은 6건이지만 고객은 5명입니다. 한 고객이 두 번 주문했기 때문입니다.

## 6.3 GROUP BY — 그룹으로 나누어 집계하기

지금까지는 테이블 **전체**를 하나로 요약했습니다. 하지만 실무에서는 "카테고리별 평균 가격", "부서별 인원수"처럼 **그룹마다 따로** 집계해야 하는 경우가 훨씬 많습니다.

이때 사용하는 것이 `GROUP BY`입니다.

```
[문법]
SELECT 그룹기준컬럼, 집계함수(...)
FROM 테이블명
[WHERE 조건]
GROUP BY 그룹기준컬럼 [, ...];
```

`GROUP BY category_id`라고 쓰면 같은 `category_id`를 가진 행들이 하나의 묶음이 되고, 집계함수는 **묶음마다 한 번씩** 계산됩니다.

**예제 6-6.** 카테고리별 상품 수와 평균 가격을 구합니다.

```sql
SELECT category_id,
       COUNT(*)          AS 상품수,
       ROUND(AVG(price)) AS 평균가격
FROM products
GROUP BY category_id
ORDER BY category_id;
```

| category_id | 상품수 | 평균가격 |
|---|---|---|
| 1 | 2 | 24500 |
| 2 | 2 | 67000 |
| 3 | 2 | 22000 |
| 4 | 2 | 21500 |
| 5 | 2 | 30500 |

10개의 행이 5개의 그룹으로 묶여 결과가 5행이 되었습니다. **결과의 행 수는 그룹의 개수와 같습니다.**

**예제 6-7.** 부서별 인원수와 평균 급여를 구합니다.

```sql
SELECT department,
       COUNT(*)           AS 인원수,
       ROUND(AVG(salary)) AS 평균급여
FROM employees
GROUP BY department;
```

| department | 인원수 | 평균급여 |
|---|---|---|
| 고객지원팀 | 1 | 4900000 |
| 영업팀 | 3 | 4200000 |

**예제 6-8.** 주문 상태별 건수를 구합니다.

```sql
SELECT status, COUNT(*) AS 주문건수
FROM orders
GROUP BY status;
```

| status | 주문건수 |
|---|---|
| 결제완료 | 1 |
| 배송완료 | 3 |
| 배송중 | 1 |
| 취소 | 1 |

**예제 6-9.** 주문별 품목 수와 총 주문금액을 구합니다.

```sql
SELECT order_id,
       COUNT(*)                     AS 품목수,
       SUM(quantity * unit_price)   AS 주문금액
FROM order_items
GROUP BY order_id
ORDER BY order_id;
```

| order_id | 품목수 | 주문금액 |
|---|---|---|
| 1 | 2 | 113000.00 |
| 2 | 2 | 49000.00 |
| 3 | 1 | 45000.00 |
| 4 | 1 | 54000.00 |
| 5 | 1 | 38000.00 |
| 6 | 2 | 121000.00 |

집계함수 안에 계산식을 그대로 넣을 수 있다는 점에 주목하세요. `SUM(quantity * unit_price)`는 각 행에서 먼저 `quantity * unit_price`를 계산한 뒤, 그 결과들을 합칩니다.

### 반드시 지켜야 할 규칙

`GROUP BY`를 쓸 때 `SELECT` 절에 올 수 있는 것은 **두 가지뿐**입니다.

1. `GROUP BY`에 나열한 컬럼
2. 집계함수

이 규칙을 어기면 오류가 납니다.

```sql
-- 오류: product_name은 그룹 기준도 아니고 집계함수도 아닙니다
SELECT product_name, COUNT(*)
FROM products;
```

```
ERROR:  column "products.product_name" must appear in the GROUP BY clause
        or be used in an aggregate function
```

왜 오류일까요? `COUNT(*)`는 10개 행을 하나로 요약해서 **결과가 한 줄**인데, `product_name`은 10개의 서로 다른 값을 가지고 있습니다. 그 한 줄에 어느 상품명을 넣어야 할지 데이터베이스가 결정할 수 없기 때문입니다.

### 여러 컬럼으로 그룹 나누기

컬럼을 쉼표로 나열하면 **값의 조합**을 기준으로 그룹이 만들어집니다. 4장의 `DISTINCT`와 같은 원리입니다.

**예제 6-10.** 주문 상태와 담당 직원의 조합별 건수를 구합니다.

```sql
SELECT status, employee_id, COUNT(*) AS 건수
FROM orders
GROUP BY status, employee_id
ORDER BY status;
```

| status | employee_id | 건수 |
|---|---|---|
| 결제완료 | *(NULL)* | 1 |
| 배송완료 | 2 | 3 |
| 배송중 | 3 | 1 |
| 취소 | 3 | 1 |

`GROUP BY`는 NULL도 하나의 그룹으로 취급합니다. NULL끼리는 같은 그룹으로 묶인다는 점을 기억해 두세요.

### 함수 결과로 그룹 나누기

`GROUP BY`에는 컬럼뿐 아니라 계산식이나 함수의 결과도 쓸 수 있습니다. 5장에서 배운 `DATE_TRUNC`가 여기서 진가를 발휘합니다.

**예제 6-11.** 월별 주문 건수를 구합니다.

```sql
SELECT DATE_TRUNC('month', order_date)::DATE AS 월,
       COUNT(*)                              AS 주문건수
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY 월;
```

| 월 | 주문건수 |
|---|---|
| 2025-06-01 | 5 |
| 2025-07-01 | 1 |

주문일이 모두 다르기 때문에 `GROUP BY order_date`로 묶으면 그룹이 6개가 되어 의미가 없습니다. `DATE_TRUNC`로 "같은 달"이라는 기준을 만들어야 월별 집계가 가능해집니다.

## 6.4 HAVING — 집계 결과에 조건 걸기

"상품이 2개 이상인 카테고리만 보고 싶다"처럼 **집계한 결과에 조건**을 걸고 싶을 때가 있습니다. 이때는 `WHERE`가 아니라 `HAVING`을 씁니다.

```
[문법]
SELECT 그룹기준컬럼, 집계함수(...)
FROM 테이블명
[WHERE 조건]
GROUP BY 그룹기준컬럼
HAVING 집계함수에 대한 조건;
```

**예제 6-12.** 평균 가격이 30,000원 이상인 카테고리만 조회합니다.

```sql
SELECT category_id, ROUND(AVG(price)) AS 평균가격
FROM products
GROUP BY category_id
HAVING AVG(price) >= 30000
ORDER BY category_id;
```

| category_id | 평균가격 |
|---|---|
| 2 | 67000 |
| 5 | 30500 |

**예제 6-13.** 두 번 이상 주문한 고객을 찾습니다.

```sql
SELECT customer_id, COUNT(*) AS 주문수
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

| customer_id | 주문수 |
|---|---|
| 1 | 2 |

**예제 6-14.** 리뷰가 2건 이상 달린 상품을 찾습니다.

```sql
SELECT product_id, COUNT(*) AS 리뷰수
FROM reviews
GROUP BY product_id
HAVING COUNT(*) >= 2;
```

| product_id | 리뷰수 |
|---|---|
| 1 | 2 |

## 6.5 WHERE와 HAVING은 무엇이 다른가

두 절 모두 "조건에 맞는 것만 남긴다"는 점은 같지만, **거르는 대상과 시점**이 다릅니다.

| | WHERE | HAVING |
|---|---|---|
| 거르는 대상 | **행** | **그룹** |
| 실행 시점 | 그룹으로 묶기 **전** | 그룹으로 묶은 **후** |
| 집계함수 사용 | **불가능** | 가능 |

`WHERE`에 집계함수를 쓰면 오류가 납니다.

```sql
-- 오류: WHERE는 그룹이 만들어지기 전에 실행되므로 COUNT를 알 수 없습니다
SELECT category_id, COUNT(*)
FROM products
WHERE COUNT(*) >= 2
GROUP BY category_id;
```

```
ERROR:  aggregate functions are not allowed in WHERE
```

`WHERE`가 실행되는 시점에는 아직 그룹이 만들어지지 않았기 때문에, 각 그룹의 개수를 셀 수가 없습니다.

### 둘을 함께 쓰기

`WHERE`와 `HAVING`은 배타적인 관계가 아니라 **역할이 다른 도구**이므로 함께 쓰는 경우가 많습니다.

**예제 6-15.** 15,000원 이상인 상품만 대상으로, 그런 상품이 2개 이상인 카테고리의 평균 가격을 비싼 순으로 조회합니다.

```sql
SELECT category_id,
       COUNT(*)          AS 상품수,
       ROUND(AVG(price)) AS 평균가격
FROM products
WHERE price >= 15000
GROUP BY category_id
HAVING COUNT(*) >= 2
ORDER BY 평균가격 DESC;
```

| category_id | 상품수 | 평균가격 |
|---|---|---|
| 2 | 2 | 67000 |
| 5 | 2 | 30500 |
| 1 | 2 | 24500 |
| 4 | 2 | 21500 |

3번 카테고리가 빠진 이유를 따라가 봅시다.

1. `WHERE price >= 15000` → 머그컵(12,000원)이 먼저 제외됩니다
2. 3번 카테고리에는 스탠드 조명 하나만 남습니다
3. `HAVING COUNT(*) >= 2` → 상품이 1개뿐이므로 그룹 전체가 제외됩니다

**처리 순서를 바꾸면 결과도 달라진다**는 점이 핵심입니다.

### 갱신된 논리적 실행 순서

4장에서 배운 실행 순서에 `GROUP BY`와 `HAVING`이 추가됩니다.

| 처리 순서 | 절 | 하는 일 |
|---|---|---|
| ① | FROM | 어느 테이블에서 |
| ② | WHERE | 어떤 **행**을 남길지 |
| ③ | GROUP BY | 어떻게 **묶을지** |
| ④ | HAVING | 어떤 **그룹**을 남길지 |
| ⑤ | SELECT | 어떤 값을 보여줄지 |
| ⑥ | ORDER BY | 어떻게 정렬할지 |
| ⑦ | LIMIT | 몇 건만 |

이 순서에서 두 가지가 자연스럽게 설명됩니다.

- `WHERE`(②)가 `GROUP BY`(③)보다 먼저이므로 집계함수를 쓸 수 없습니다
- `HAVING`(④)이 `SELECT`(⑤)보다 먼저이므로 **별칭을 쓸 수 없습니다**

```sql
-- 오류: HAVING 시점에는 "상품수"라는 별칭이 아직 존재하지 않습니다
SELECT category_id, COUNT(*) AS 상품수
FROM products
GROUP BY category_id
HAVING 상품수 >= 2;
```

```
ERROR:  column "상품수" does not exist
```

`HAVING`에서는 `HAVING COUNT(*) >= 2`처럼 집계함수를 그대로 반복해서 써야 합니다. 반면 `ORDER BY`(⑥)는 `SELECT` 뒤에 실행되므로 예제 6-15처럼 별칭을 그대로 쓸 수 있습니다.

> **참고**: PostgreSQL에서 `GROUP BY`는 예외적으로 별칭을 허용합니다. 다만 다른 DBMS에서는 통하지 않는 경우가 많고 표준도 아니므로, 이 교재에서는 `GROUP BY`에 원래 컬럼명을 쓰는 방식으로 통일합니다.

## 6.6 [심화] 문자열로 묶기와 소계 구하기

여기부터는 입문 단계에서 반드시 알아야 하는 내용은 아닙니다. 필요할 때 다시 찾아보는 정도로 읽어도 좋습니다.

### STRING_AGG — 그룹의 값들을 한 줄로 이어 붙이기

숫자를 합치는 `SUM`처럼, 문자열을 이어 붙이는 집계함수도 있습니다.

**예제 6-16.** 카테고리별로 어떤 상품이 있는지 한 줄로 정리합니다.

```sql
SELECT category_id,
       STRING_AGG(product_name, ', ' ORDER BY product_id) AS 상품목록
FROM products
GROUP BY category_id
ORDER BY category_id;
```

| category_id | 상품목록 |
|---|---|
| 1 | SQL 첫걸음, 데이터베이스 개론 |
| 2 | 무선 이어폰, 블루투스 키보드 |
| 3 | 스탠드 조명, 머그컵 |
| 4 | 원두커피 1kg, 견과류 세트 |
| 5 | 면 티셔츠, 후드 집업 |

### ROLLUP — 소계와 총계 함께 구하기

`GROUP BY ROLLUP(컬럼)`을 쓰면 각 그룹의 집계와 함께 **전체 합계 행**이 추가됩니다.

**예제 6-17.** 카테고리별 집계에 전체 합계를 함께 표시합니다.

```sql
SELECT category_id,
       COUNT(*)   AS 상품수,
       SUM(price) AS 가격합계
FROM products
GROUP BY ROLLUP(category_id)
ORDER BY category_id;
```

| category_id | 상품수 | 가격합계 |
|---|---|---|
| 1 | 2 | 49000.00 |
| 2 | 2 | 134000.00 |
| 3 | 2 | 44000.00 |
| 4 | 2 | 43000.00 |
| 5 | 2 | 61000.00 |
| *(NULL)* | 10 | 331000.00 |

마지막 행의 `category_id`가 NULL인 것이 **전체 합계 행**입니다. 상품 10개, 가격 합계 331,000원으로 예제 6-2의 결과와 일치합니다.

> **주의**: 합계 행의 NULL은 "값이 없다"는 뜻이 아니라 "이 컬럼으로 구분하지 않았다"는 표시입니다. 원래 데이터에도 NULL이 있다면 둘을 구분하기 어려워지는데, 이때는 `GROUPING()` 함수로 구분할 수 있습니다.

이 밖에 모든 조합의 소계를 구하는 `CUBE`, 원하는 조합만 지정하는 `GROUPING SETS`도 있습니다. 보고서용 집계를 만들 때 유용하니 필요해지면 찾아보세요.

---

## 요약

- 집계함수는 여러 행을 하나의 값으로 요약하며, 결과의 행 수가 줄어든다
- `COUNT(*)`는 행 개수를, `COUNT(컬럼)`은 NULL이 아닌 값의 개수를 센다. `SUM`, `AVG` 등 다른 집계함수도 NULL을 계산에서 제외한다
- `GROUP BY`는 같은 값을 가진 행을 묶으며, 결과의 행 수는 그룹의 개수와 같다
- `GROUP BY`를 쓸 때 `SELECT`에는 그룹 기준 컬럼과 집계함수만 올 수 있다
- `WHERE`는 묶기 전에 **행**을 거르고, `HAVING`은 묶은 후에 **그룹**을 거른다. `WHERE`에는 집계함수를 쓸 수 없다
- 실행 순서는 FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT이며, 그래서 `HAVING`에서는 별칭을 쓸 수 없다

---

## 연습문제

**문제 1** (난이도: 하)
등록된 전체 고객 수를 조회하세요.

**문제 2** (난이도: 하)
상품의 평균 가격, 최고가, 최저가를 한 번에 조회하세요.

**문제 3** (난이도: 하)
전체 리뷰 개수와 평균 별점을 조회하세요. (평균은 소수점 둘째 자리까지)

**문제 4** (난이도: 중)
카테고리별 상품 개수를 조회하세요.

**문제 5** (난이도: 중)
부서별 인원수와 평균 급여를 조회하세요.

**문제 6** (난이도: 중)
주문 상태별로 몇 건씩 있는지 조회하세요.

**문제 7** (난이도: 중)
고객별 주문 건수를 조회하세요.

**문제 8** (난이도: 중)
주문별 총 주문금액을 조회하세요. (`order_items` 테이블 사용)

**문제 9** (난이도: 상)
상품별 총 판매 수량을 구하되, 2개 이상 팔린 상품만 조회하세요.

**문제 10** (난이도: 상)
재고가 있는 상품만 대상으로 카테고리별 평균 가격을 구하되, 평균이 25,000원 이상인 카테고리만 비싼 순으로 조회하세요.

---

## 정답 및 해설

**문제 1**
```sql
SELECT COUNT(*) AS 고객수
FROM customers;
```
5명입니다. `COUNT(phone)`으로 쓰면 4가 나온다는 점에 주의하세요.

**문제 2**
```sql
SELECT ROUND(AVG(price)) AS 평균가격,
       MAX(price)        AS 최고가,
       MIN(price)        AS 최저가
FROM products;
```

| 평균가격 | 최고가 | 최저가 |
|---|---|---|
| 33100 | 89000.00 | 12000.00 |

**문제 3**
```sql
SELECT COUNT(*)               AS 리뷰수,
       ROUND(AVG(rating), 2)  AS 평균별점
FROM reviews;
```
리뷰 5건, 평균 별점 3.80입니다.

**문제 4**
```sql
SELECT category_id, COUNT(*) AS 상품수
FROM products
GROUP BY category_id
ORDER BY category_id;
```
각 카테고리에 2건씩 있습니다.

**문제 5**
```sql
SELECT department,
       COUNT(*)           AS 인원수,
       ROUND(AVG(salary)) AS 평균급여
FROM employees
GROUP BY department;
```
영업팀 3명(평균 4,200,000), 고객지원팀 1명(4,900,000)입니다.

**문제 6**
```sql
SELECT status, COUNT(*) AS 주문건수
FROM orders
GROUP BY status;
```
배송완료 3건, 나머지 상태는 각 1건입니다.

**문제 7**
```sql
SELECT customer_id, COUNT(*) AS 주문수
FROM orders
GROUP BY customer_id
ORDER BY customer_id;
```
1번 고객만 2건이고 나머지는 1건씩입니다.

**문제 8**
```sql
SELECT order_id, SUM(quantity * unit_price) AS 주문금액
FROM order_items
GROUP BY order_id
ORDER BY order_id;
```
1번 주문이 113,000원, 6번 주문이 121,000원으로 가장 큽니다.

**문제 9**
```sql
SELECT product_id, SUM(quantity) AS 판매수량
FROM order_items
GROUP BY product_id
HAVING SUM(quantity) >= 2
ORDER BY product_id;
```

| product_id | 판매수량 |
|---|---|
| 1 | 2 |
| 4 | 2 |
| 5 | 3 |
| 9 | 2 |

`HAVING`에 `COUNT(*)`가 아니라 `SUM(quantity)`를 쓴 점에 주의하세요. "몇 번 주문에 포함되었는가"가 아니라 "몇 개가 팔렸는가"를 묻는 문제입니다.

**문제 10**
```sql
SELECT category_id, ROUND(AVG(price)) AS 평균가격
FROM products
WHERE stock_quantity > 0
GROUP BY category_id
HAVING AVG(price) >= 25000
ORDER BY 평균가격 DESC;
```

| category_id | 평균가격 |
|---|---|
| 2 | 67000 |
| 5 | 30500 |

"재고가 있는 상품만"은 개별 행에 대한 조건이므로 `WHERE`에, "평균이 25,000원 이상"은 그룹에 대한 조건이므로 `HAVING`에 씁니다. 4번 카테고리는 재고가 0인 견과류 세트가 `WHERE`에서 빠지면서 원두커피 1kg(18,000원)만 남아 평균이 낮아졌고, 그 결과 `HAVING` 조건에서 제외되었습니다.
