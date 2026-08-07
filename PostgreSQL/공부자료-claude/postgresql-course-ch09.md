# 9장. 서브쿼리와 CTE

## 학습 목표

- 서브쿼리가 무엇이고 어디에 쓸 수 있는지 설명할 수 있다
- 단일행·다중행 서브쿼리를 구분해 사용할 수 있다
- `EXISTS`로 상관 서브쿼리를 작성할 수 있고, `NOT IN`의 NULL 함정을 피할 수 있다
- 인라인 뷰와 CTE로 복잡한 쿼리를 단계로 나눌 수 있다
- 서브쿼리와 JOIN 중 어느 쪽이 적절한지 판단할 수 있다

---

## 9.1 서브쿼리란 무엇인가

"평균 가격보다 비싼 상품"을 찾으려면 어떻게 해야 할까요? 지금까지 배운 것만으로는 두 번에 나눠 실행해야 합니다.

```sql
-- 1단계: 평균을 구한다
SELECT ROUND(AVG(price)) FROM products;   -- 결과: 33100

-- 2단계: 그 값을 손으로 옮겨 적는다
SELECT product_name, price FROM products WHERE price > 33100;
```

이 방법에는 문제가 있습니다. 상품이 하나만 추가되어도 평균이 바뀌므로 **매번 1단계를 다시 실행해서 숫자를 갈아 끼워야** 합니다.

**서브쿼리**(**Subquery**)는 이 두 단계를 하나의 쿼리로 합칩니다. SQL 문 안에 들어간 또 다른 `SELECT` 문이며, 하위 쿼리라고도 부릅니다.

**예제 9-1.** 평균 가격보다 비싼 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 후드 집업 | 42000.00 |

괄호 안의 `SELECT`가 먼저 실행되어 평균값을 구하고, 그 결과가 바깥 쿼리의 조건으로 쓰입니다. 데이터가 바뀌어도 쿼리를 고칠 필요가 없습니다.

> 서브쿼리는 **반드시 괄호로 감싸야** 합니다. 안쪽을 **서브쿼리** 또는 내부 쿼리, 바깥쪽을 **메인 쿼리** 또는 외부 쿼리라고 부릅니다.

## 9.2 서브쿼리의 종류

서브쿼리는 두 가지 기준으로 나눠 보면 정리하기 쉽습니다.

**첫째, 어디에 쓰이는가**

| 위치 | 이름 | 용도 |
|---|---|---|
| `WHERE` 절 | 일반 서브쿼리 | 조건에 쓸 값을 구함 |
| `FROM` 절 | 인라인 뷰 | 조회 결과를 테이블처럼 사용 |
| `SELECT` 절 | 스칼라 서브쿼리 | 컬럼 하나를 만들어 냄 |

**둘째, 메인 쿼리와 연결되어 있는가**

| 종류 | 설명 |
|---|---|
| **비상관 서브쿼리** | 서브쿼리 혼자서도 실행됨. 한 번만 계산됨 |
| **상관 서브쿼리** | 메인 쿼리의 값을 참조함. 행마다 다시 계산됨 |

예제 9-1의 `SELECT AVG(price) FROM products`는 따로 떼어 실행해도 잘 동작하므로 **비상관 서브쿼리**입니다. 상관 서브쿼리는 9.5절에서 다룹니다.

## 9.3 비상관 서브쿼리 — 단일행

서브쿼리가 **값 하나**를 돌려주는 경우입니다. 비교 연산자(`=`, `>`, `<`, `>=`, `<=`, `<>`)와 함께 씁니다.

**예제 9-2.** 가장 비싼 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |

`MAX(price)`가 89000이라는 값 하나를 돌려주므로 `=`로 비교할 수 있습니다.

> **자주 하는 실수**: 서브쿼리가 여러 행을 돌려주는데 `=`를 쓰면 오류가 납니다.
> ```sql
> SELECT product_name FROM products
> WHERE price = (SELECT price FROM products WHERE category_id = 1);
> ```
> ```
> ERROR:  more than one row returned by a subquery used as an expression
> ```
> 1번 카테고리에 상품이 2개라 값이 두 개 나왔기 때문입니다. 이럴 때는 다음 절의 `IN`을 써야 합니다.

## 9.4 비상관 서브쿼리 — 다중행

서브쿼리가 **여러 행**을 돌려주는 경우입니다. 전용 연산자를 써야 합니다.

| 연산자 | 의미 |
|---|---|
| `IN` | 목록 중 하나와 일치 |
| `NOT IN` | 목록 어디에도 없음 |
| `> ANY` | 목록 중 **최솟값**보다 크면 참 |
| `> ALL` | 목록 중 **최댓값**보다 크면 참 |

### IN

4장에서 배운 `IN`의 목록 자리에 서브쿼리를 넣는 것입니다.

**예제 9-3.** 전자제품과 도서 카테고리의 상품을 조회합니다.

```sql
SELECT product_name, category_id
FROM products
WHERE category_id IN (
    SELECT category_id FROM categories
    WHERE category_name IN ('전자제품', '도서')
)
ORDER BY product_id;
```

| product_name | category_id |
|---|---|
| 무선 이어폰 | 2 |
| 블루투스 키보드 | 2 |
| SQL 첫걸음 | 1 |
| 데이터베이스 개론 | 1 |

카테고리 번호가 몇 번인지 미리 알지 못해도, **이름만으로** 조회할 수 있다는 점이 핵심입니다.

### NOT IN의 NULL 함정

입문자가 반드시 알아야 할 함정입니다. 실무에서도 자주 사고가 나는 지점입니다.

**예제 9-4.** 주문을 담당한 적 없는 직원을 찾아봅니다.

```sql
SELECT employee_name
FROM employees
WHERE employee_id NOT IN (SELECT employee_id FROM orders);
```

| employee_name |
|---|
| (조회된 행 없음) |

**결과가 하나도 나오지 않습니다.** 7장에서 우리는 강태호와 윤성민이 주문을 담당한 적 없다는 것을 이미 확인했는데도요.

원인은 서브쿼리의 결과에 섞인 NULL입니다.

```sql
SELECT employee_id FROM orders;
```

| employee_id |
|---|
| 2 |
| 2 |
| 3 |
| *(NULL)* |
| 3 |
| 2 |

`NOT IN (2, 2, 3, NULL, 3, 2)`는 내부적으로 이렇게 풀립니다.

```
employee_id <> 2 AND employee_id <> 3 AND employee_id <> NULL
```

4장에서 배웠듯 `<> NULL`의 결과는 참도 거짓도 아닌 **"알 수 없음"**입니다. `AND`로 연결된 조건에 "알 수 없음"이 하나라도 있으면 전체가 참이 될 수 없으므로, **어떤 행도 조건을 통과하지 못합니다.**

해결 방법은 두 가지입니다.

```sql
-- 방법 1: 서브쿼리에서 NULL을 미리 제거
SELECT employee_name
FROM employees
WHERE employee_id NOT IN (
    SELECT employee_id FROM orders WHERE employee_id IS NOT NULL
)
ORDER BY employee_id;
```

| employee_name |
|---|
| 강태호 |
| 윤성민 |

```sql
-- 방법 2: NOT EXISTS를 사용 (9.5절)
```

> **권장**: `NOT IN`은 서브쿼리에 NULL이 있을 가능성이 조금이라도 있다면 피하는 것이 안전합니다. 뒤에서 배울 `NOT EXISTS`는 이 문제가 없습니다.

### ANY와 ALL

`ANY`는 "하나라도 만족하면", `ALL`은 "전부 만족해야" 참입니다.

1번 카테고리(도서)의 가격은 22,000원과 27,000원입니다.

**예제 9-5.** 모든 도서보다 비싼 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE price > ALL (SELECT price FROM products WHERE category_id = 1)
ORDER BY product_id;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 스탠드 조명 | 32000.00 |
| 후드 집업 | 42000.00 |

`> ALL`은 목록의 **최댓값**(27,000)**보다 큰** 것을 의미하므로, 결국 `price > 27000`과 같습니다.

**예제 9-6.** 도서 중 어느 하나보다라도 비싼 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE price > ANY (SELECT price FROM products WHERE category_id = 1)
ORDER BY product_id;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 스탠드 조명 | 32000.00 |
| 견과류 세트 | 25000.00 |
| 데이터베이스 개론 | 27000.00 |
| 후드 집업 | 42000.00 |

`> ANY`는 **최솟값**(22,000)**보다 크면** 되므로 결과가 더 많습니다. 25,000원짜리 견과류 세트가 여기서는 포함됩니다.

> **기억하는 요령**: `> ALL`은 최댓값 기준, `> ANY`는 최솟값 기준입니다. 부등호 방향이 `<`로 바뀌면 반대가 됩니다. 헷갈린다면 `MAX`나 `MIN`을 쓴 단일행 서브쿼리로 바꿔 쓰는 편이 읽기 쉽습니다.

## 9.5 상관 서브쿼리와 EXISTS

**상관 서브쿼리**(**Correlated Subquery**)는 서브쿼리 안에서 **메인 쿼리의 컬럼을 참조**합니다. 그래서 서브쿼리만 떼어내면 실행되지 않고, 메인 쿼리의 행마다 한 번씩 다시 계산됩니다.

### EXISTS — 존재하는지만 확인

`EXISTS`는 서브쿼리의 결과가 **한 건이라도 있으면** 참입니다. 값이 무엇인지는 상관하지 않고 존재 여부만 봅니다.

**예제 9-7.** 리뷰가 달린 상품을 조회합니다.

```sql
SELECT p.product_id, p.product_name
FROM products p
WHERE EXISTS (
    SELECT 1 FROM reviews r
    WHERE r.product_id = p.product_id
)
ORDER BY p.product_id;
```

| product_id | product_name |
|---|---|
| 1 | 무선 이어폰 |
| 4 | 머그컵 |
| 7 | SQL 첫걸음 |
| 9 | 면 티셔츠 |

서브쿼리 안의 `p.product_id`가 메인 쿼리의 컬럼을 참조하고 있습니다. 상품 한 건씩 넘겨가며 "이 상품에 리뷰가 있나?"를 확인하는 방식입니다.

`SELECT 1`이라고 쓴 이유는, `EXISTS`가 **행의 존재만** 확인하므로 어떤 값을 조회하든 결과가 같기 때문입니다. `SELECT *`나 `SELECT product_id`라고 써도 동일하게 동작하지만, "값은 중요하지 않다"는 의도를 드러내기 위해 관례적으로 `1`을 씁니다.

### NOT EXISTS

**예제 9-8.** 리뷰가 하나도 없는 상품을 조회합니다.

```sql
SELECT p.product_id, p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM reviews r
    WHERE r.product_id = p.product_id
)
ORDER BY p.product_id;
```

| product_id | product_name |
|---|---|
| 2 | 블루투스 키보드 |
| 3 | 스탠드 조명 |
| 5 | 원두커피 1kg |
| 6 | 견과류 세트 |
| 8 | 데이터베이스 개론 |
| 10 | 후드 집업 |

**`NOT EXISTS`는 NULL 함정이 없습니다.** 예제 9-4의 `NOT IN`과 달리, 존재 여부만 판정하므로 NULL이 섞여 있어도 정상 동작합니다. "~한 적 없는 대상"을 찾을 때는 `NOT IN`보다 `NOT EXISTS`를 우선 고려하세요.

**예제 9-9.** 리뷰를 쓴 적 없는 고객을 찾습니다.

```sql
SELECT c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM reviews r
    WHERE r.customer_id = c.customer_id
);
```

| customer_name |
|---|
| 박도윤 |

7장 예제(LEFT JOIN + IS NULL), 8장 예제(EXCEPT)와 **같은 문제를 세 번째 방법으로** 푼 것입니다. 세 방법 모두 정답이며, 9.8절에서 선택 기준을 정리합니다.

## 9.6 스칼라 서브쿼리 — SELECT 절의 서브쿼리

`SELECT` 절에 서브쿼리를 넣으면 **컬럼 하나를 만들어** 낼 수 있습니다. 반드시 값 하나만 돌려줘야 합니다.

**예제 9-10.** 각 상품의 가격이 전체 평균과 얼마나 차이 나는지 조회합니다.

```sql
SELECT p.product_name,
       p.price,
       (SELECT ROUND(AVG(price)) FROM products) AS 전체평균,
       p.price - (SELECT ROUND(AVG(price)) FROM products) AS 차이
FROM products p
ORDER BY p.product_id;
```

| product_name | price | 전체평균 | 차이 |
|---|---|---|---|
| 무선 이어폰 | 89000.00 | 33100 | 55900.00 |
| 블루투스 키보드 | 45000.00 | 33100 | 11900.00 |
| 스탠드 조명 | 32000.00 | 33100 | -1100.00 |
| 머그컵 | 12000.00 | 33100 | -21100.00 |
| 원두커피 1kg | 18000.00 | 33100 | -15100.00 |
| ... 외 5건 | | | |

**예제 9-11.** 고객별 주문 건수를 상관 서브쿼리로 구합니다.

```sql
SELECT c.customer_name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS 주문수
FROM customers c
ORDER BY c.customer_id;
```

| customer_name | 주문수 |
|---|---|
| 김민준 | 2 |
| 이서연 | 1 |
| 박도윤 | 1 |
| 최지우 | 1 |
| 정하은 | 1 |

7장에서 `LEFT JOIN` + `GROUP BY`로 풀었던 문제입니다. 이 방식은 `GROUP BY`가 필요 없어 짧지만, 행마다 서브쿼리가 실행되므로 데이터가 많으면 느려질 수 있습니다.

## 9.7 인라인 뷰 — FROM 절의 서브쿼리

`FROM` 절에 서브쿼리를 넣으면, 그 **조회 결과를 하나의 테이블처럼** 쓸 수 있습니다. 이것을 **인라인 뷰**(**Inline View**)라고 합니다.

집계 결과에 다시 조건을 걸어야 할 때 특히 유용합니다.

**예제 9-12.** 총 금액이 100,000원 이상인 주문을 조회합니다.

```sql
SELECT *
FROM (
    SELECT order_id, SUM(quantity * unit_price) AS 주문금액
    FROM order_items
    GROUP BY order_id
) t
WHERE t.주문금액 >= 100000
ORDER BY t.order_id;
```

| order_id | 주문금액 |
|---|---|
| 1 | 113000.00 |
| 6 | 121000.00 |

여기서 `t`는 인라인 뷰에 붙인 별칭입니다. 서브쿼리 결과를 테이블처럼 다루므로 이름이 필요합니다.

> 이 예제는 `HAVING SUM(...) >= 100000`으로도 풀 수 있습니다. 하지만 **집계 결과를 다시 집계**해야 할 때는 인라인 뷰가 반드시 필요합니다.

**예제 9-13.** 주문 한 건당 평균 금액을 구합니다.

```sql
SELECT ROUND(AVG(주문금액)) AS 평균주문금액
FROM (
    SELECT order_id, SUM(quantity * unit_price) AS 주문금액
    FROM order_items
    GROUP BY order_id
) t;
```

| 평균주문금액 |
|---|
| 70000 |

"주문별로 합계를 낸 뒤, 그 합계들의 평균"이라는 **2단계 집계**입니다. `AVG(SUM(...))`처럼 집계함수를 겹쳐 쓸 수는 없으므로 인라인 뷰가 필요합니다.

> **참고**: PostgreSQL 16부터는 `FROM` 절 서브쿼리의 별칭을 생략할 수 있습니다. 하지만 이전 버전이나 다른 DBMS에서는 오류가 나고, 컬럼을 참조할 때도 별칭이 있는 편이 명확하므로 이 교재에서는 항상 별칭을 붙입니다.

## 9.8 CTE — WITH 절

인라인 뷰가 두세 개 겹치면 쿼리가 급격히 읽기 어려워집니다. 괄호 안에 괄호가 들어가고, 무엇이 먼저 실행되는지 눈으로 따라가기 힘들어지죠.

**CTE**(**Common Table Expression**)는 이 문제를 해결합니다. 서브쿼리에 **이름을 붙여 쿼리 앞쪽에 미리 정의**해 두고, 본문에서는 테이블처럼 갖다 쓰는 방식입니다.

```
[문법]
WITH 이름 AS (
    SELECT ...
)
SELECT ... FROM 이름 ...;
```

**예제 9-14.** 예제 9-12를 CTE로 다시 작성하고, 고객 이름까지 붙입니다.

```sql
WITH 주문금액 AS (
    SELECT order_id, SUM(quantity * unit_price) AS 금액
    FROM order_items
    GROUP BY order_id
)
SELECT o.order_id, c.customer_name, a.금액
FROM 주문금액 a
JOIN orders    o ON a.order_id    = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE a.금액 >= 100000
ORDER BY o.order_id;
```

| order_id | customer_name | 금액 |
|---|---|---|
| 1 | 김민준 | 113000.00 |
| 6 | 정하은 | 121000.00 |

"먼저 주문별 금액을 구하고, 그 다음 고객 정보를 붙인다"는 **작업 순서가 위에서 아래로 그대로 읽힙니다.** 인라인 뷰로 쓰면 같은 내용이 `FROM` 절 안쪽에 파묻혀 읽기 어려워집니다.

### CTE는 여러 개를 정의할 수 있습니다

쉼표로 이어서 정의하며, **앞에서 정의한 CTE를 뒤에서 참조**할 수 있습니다.

**예제 9-15.** 평균 주문금액보다 큰 주문을 찾습니다.

```sql
WITH 주문금액 AS (
    SELECT order_id, SUM(quantity * unit_price) AS 금액
    FROM order_items
    GROUP BY order_id
),
평균 AS (
    SELECT AVG(금액) AS 평균금액 FROM 주문금액
)
SELECT a.order_id, a.금액, ROUND((SELECT 평균금액 FROM 평균)) AS 평균금액
FROM 주문금액 a
WHERE a.금액 > (SELECT 평균금액 FROM 평균)
ORDER BY a.order_id;
```

| order_id | 금액 | 평균금액 |
|---|---|---|
| 1 | 113000.00 | 70000 |
| 6 | 121000.00 | 70000 |

`평균` CTE가 `주문금액` CTE를 참조하고 있습니다. 계산을 여러 단계로 쪼개도 각 단계가 명확히 드러납니다.

### CTE와 인라인 뷰, 무엇을 쓸까

기능은 거의 같습니다. 판단 기준은 **가독성**입니다.

| 상황 | 권장 |
|---|---|
| 단계가 하나뿐이고 짧다 | 인라인 뷰 |
| 단계가 둘 이상이다 | CTE |
| 같은 결과를 여러 번 참조한다 | CTE |
| 처리 순서를 문서처럼 보이게 하고 싶다 | CTE |

요즘 실무에서는 CTE를 선호하는 경향이 뚜렷합니다. 쿼리가 길어질수록 차이가 커지기 때문입니다.

### [심화] 재귀 CTE

`WITH RECURSIVE`를 쓰면 **자기 자신을 참조**하는 CTE를 만들 수 있습니다. 조직도처럼 계층이 몇 단계인지 미리 알 수 없는 구조를 다룰 때 사용합니다.

**예제 9-16.** 직원 조직도를 단계별로 펼칩니다.

```sql
WITH RECURSIVE 조직도 AS (
    -- 시작점: 상사가 없는 최상위 직원
    SELECT employee_id, employee_name, manager_id, 1 AS 단계
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- 반복: 앞 단계 직원을 상사로 둔 직원을 찾아 붙임
    SELECT e.employee_id, e.employee_name, e.manager_id, o.단계 + 1
    FROM employees e
    JOIN 조직도 o ON e.manager_id = o.employee_id
)
SELECT 단계, employee_id, employee_name
FROM 조직도
ORDER BY 단계, employee_id;
```

| 단계 | employee_id | employee_name |
|---|---|---|
| 1 | 1 | 강태호 |
| 1 | 4 | 윤성민 |
| 2 | 2 | 오유진 |
| 2 | 3 | 한지민 |

시작점을 찾은 뒤, 더 이상 붙일 행이 없을 때까지 `UNION ALL` 아래쪽을 반복합니다. 조직도, 카테고리 계층, 게시판 답글처럼 깊이가 정해지지 않은 구조에서 유용하니 필요해질 때 다시 찾아보세요.

## 9.9 서브쿼리와 JOIN, 무엇을 쓸까

우리는 이제 "리뷰를 쓴 적 없는 고객"을 **세 가지 방법**으로 풀 수 있습니다.

```sql
-- 1. LEFT JOIN + IS NULL (7장)
SELECT c.customer_name FROM customers c
LEFT JOIN reviews r ON c.customer_id = r.customer_id
WHERE r.review_id IS NULL;

-- 2. EXCEPT (8장)
SELECT customer_id FROM customers
EXCEPT
SELECT customer_id FROM reviews;

-- 3. NOT EXISTS (9장)
SELECT c.customer_name FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM reviews r WHERE r.customer_id = c.customer_id);
```

선택 기준을 정리하면 이렇습니다.

| 상황 | 권장 |
|---|---|
| 양쪽 테이블의 **컬럼을 함께** 봐야 함 | JOIN |
| 존재 여부만 확인하면 됨 | `EXISTS` / `NOT EXISTS` |
| 조건에 쓸 **값**을 다른 테이블에서 구함 | `WHERE` 절 서브쿼리 |
| 집계 결과에 다시 조건을 검 | 인라인 뷰 / CTE |
| 여러 단계로 나눠 계산해야 함 | CTE |

**"결과에 어떤 컬럼이 필요한가"가 1차 기준입니다.** 상대 테이블의 컬럼이 결과에 나와야 한다면 JOIN이 필요하고, 걸러내는 데만 쓴다면 서브쿼리가 의도를 더 분명히 드러냅니다.

또 하나 실용적인 차이가 있습니다. JOIN은 1:N 관계에서 행이 늘어나 `DISTINCT`가 필요해지는 경우가 있지만, `EXISTS`는 존재 여부만 보므로 **행이 늘어나지 않습니다.** 리뷰가 여러 개인 상품을 `EXISTS`로 찾으면 상품이 한 번만 나오지만, JOIN으로 찾으면 리뷰 수만큼 중복됩니다.

---

## 요약

- 서브쿼리는 SQL 문 안에 들어간 `SELECT`이며, 괄호로 감싸 `WHERE`, `FROM`, `SELECT` 절에 쓸 수 있다
- 값 하나를 돌려주면 비교 연산자와, 여러 행을 돌려주면 `IN`, `ANY`, `ALL`과 함께 쓴다
- `NOT IN`은 서브쿼리 결과에 NULL이 섞이면 결과가 하나도 나오지 않는다. `NOT EXISTS`를 쓰거나 NULL을 먼저 제거해야 한다
- 상관 서브쿼리는 메인 쿼리의 컬럼을 참조하며 행마다 실행된다. `EXISTS`가 대표적이다
- 인라인 뷰는 `FROM` 절 서브쿼리로, 집계 결과에 다시 조건을 걸거나 2단계 집계를 할 때 쓴다
- CTE는 `WITH`로 서브쿼리에 이름을 붙이는 방식이며, 단계가 둘 이상이면 인라인 뷰보다 읽기 쉽다
- 상대 테이블의 컬럼이 결과에 필요하면 JOIN, 존재 여부만 확인하면 `EXISTS`를 쓴다

---

## 연습문제

**문제 1** (난이도: 하)
평균 가격보다 저렴한 상품의 이름과 가격을 조회하세요.

**문제 2** (난이도: 하)
가장 저렴한 상품의 이름과 가격을 서브쿼리로 조회하세요.

**문제 3** (난이도: 중)
주문을 취소한 적이 있는 고객의 이름을 조회하세요.

**문제 4** (난이도: 중)
한 번도 판매되지 않은 상품의 이름을 서브쿼리로 조회하세요.

**문제 5** (난이도: 중)
리뷰가 달린 적이 있는 상품의 이름을 `EXISTS`로 조회하세요.

**문제 6** (난이도: 중)
각 고객의 이름과 그 고객이 쓴 리뷰 수를 스칼라 서브쿼리로 조회하세요.

**문제 7** (난이도: 상)
상품별 총 판매 수량을 구하되, 2개 이상 팔린 상품만 상품명과 함께 조회하세요. CTE를 사용하세요.

**문제 8** (난이도: 상)
카테고리별 평균 가격이 25,000원 이상인 카테고리의 이름과 평균 가격을 인라인 뷰로 조회하세요.

**문제 9** (난이도: 상)
예제 9-4에서 `NOT IN`이 왜 결과를 내지 못했는지 설명하고, `NOT EXISTS`로 다시 작성하세요.

**문제 10** (난이도: 상)
주문 한 건당 평균 금액보다 큰 주문의 번호와 금액을 CTE로 조회하세요.

---

## 정답 및 해설

**문제 1**
```sql
SELECT product_name, price
FROM products
WHERE price < (SELECT AVG(price) FROM products)
ORDER BY product_id;
```
평균 33,100원 미만인 7건이 조회됩니다. 스탠드 조명(32,000원)이 포함된다는 점에 주의하세요.

**문제 2**
```sql
SELECT product_name, price
FROM products
WHERE price = (SELECT MIN(price) FROM products);
```
머그컵(12,000원)입니다.

**문제 3**
```sql
SELECT customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM orders WHERE status = '취소'
);
```
최지우 1건입니다.

**문제 4**
```sql
SELECT product_name
FROM products
WHERE product_id NOT IN (SELECT product_id FROM order_items)
ORDER BY product_id;
```
견과류 세트, 후드 집업 2건입니다.

여기서 `NOT IN`이 정상 동작하는 이유는 `order_items.product_id`가 `NOT NULL` 컬럼이라 NULL이 섞일 수 없기 때문입니다. NULL 가능성이 있는 컬럼이었다면 `NOT EXISTS`를 써야 합니다.

**문제 5**
```sql
SELECT p.product_name
FROM products p
WHERE EXISTS (
    SELECT 1 FROM reviews r WHERE r.product_id = p.product_id
)
ORDER BY p.product_id;
```
무선 이어폰, 머그컵, SQL 첫걸음, 면 티셔츠 4건입니다.

**문제 6**
```sql
SELECT c.customer_name,
       (SELECT COUNT(*) FROM reviews r WHERE r.customer_id = c.customer_id) AS 리뷰수
FROM customers c
ORDER BY c.customer_id;
```

| customer_name | 리뷰수 |
|---|---|
| 김민준 | 2 |
| 이서연 | 1 |
| 박도윤 | 0 |
| 최지우 | 1 |
| 정하은 | 1 |

박도윤이 0으로 나옵니다. 상관 서브쿼리 안의 `COUNT(*)`는 조회된 행이 없으면 0을 돌려주므로, LEFT JOIN에서처럼 `COUNT(컬럼)`을 쓸 필요가 없습니다.

**문제 7**
```sql
WITH 상품별판매 AS (
    SELECT product_id, SUM(quantity) AS 판매수량
    FROM order_items
    GROUP BY product_id
)
SELECT p.product_name, s.판매수량
FROM 상품별판매 s
JOIN products p ON s.product_id = p.product_id
WHERE s.판매수량 >= 2
ORDER BY s.판매수량 DESC, p.product_id;
```

| product_name | 판매수량 |
|---|---|
| 원두커피 1kg | 3 |
| 무선 이어폰 | 2 |
| 머그컵 | 2 |
| 면 티셔츠 | 2 |

**문제 8**
```sql
SELECT c.category_name, t.평균가격
FROM (
    SELECT category_id, ROUND(AVG(price)) AS 평균가격
    FROM products
    GROUP BY category_id
) t
JOIN categories c ON t.category_id = c.category_id
WHERE t.평균가격 >= 25000
ORDER BY t.평균가격 DESC;
```

| category_name | 평균가격 |
|---|---|
| 전자제품 | 67000 |
| 의류 | 30500 |

**문제 9**

`orders.employee_id`에 NULL이 포함되어 있기 때문입니다. `NOT IN` 목록에 NULL이 있으면 모든 비교가 "알 수 없음"이 되어 어떤 행도 조건을 통과하지 못합니다.

```sql
SELECT e.employee_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.employee_id = e.employee_id
)
ORDER BY e.employee_id;
```
강태호, 윤성민 2건이 정상적으로 조회됩니다.

**문제 10**
```sql
WITH 주문금액 AS (
    SELECT order_id, SUM(quantity * unit_price) AS 금액
    FROM order_items
    GROUP BY order_id
)
SELECT order_id, 금액
FROM 주문금액
WHERE 금액 > (SELECT AVG(금액) FROM 주문금액)
ORDER BY order_id;
```

| order_id | 금액 |
|---|---|
| 1 | 113000.00 |
| 6 | 121000.00 |

평균이 70,000원이므로 두 건이 조건을 만족합니다. 같은 CTE를 본문과 서브쿼리에서 **두 번 참조**하고 있다는 점에 주목하세요. 인라인 뷰로 작성하려면 같은 서브쿼리를 두 번 써야 합니다.
