# 13장. View

## 학습 목표

- View가 무엇이고 언제 사용하는지 설명할 수 있다
- View를 생성, 수정, 삭제할 수 있다
- View를 통해 데이터를 수정할 수 있는 조건을 이해한다
- 일반 View와 Materialized View의 차이를 설명할 수 있다

---

## 13.1 View란 무엇인가

7장에서 상품 목록에 카테고리 이름을 붙이려면 매번 이렇게 써야 했습니다.

```sql
SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```

이 조회를 하루에 열 번 한다면 열 번 다 이 JOIN을 써야 합니다. 조인 조건을 실수하기도 쉽고, 팀원마다 조금씩 다르게 쓸 수도 있습니다.

**View**(**뷰**)는 이런 `SELECT` 문에 **이름을 붙여 저장**해 두는 기능입니다. 한 번 만들어 두면 이후에는 테이블처럼 사용할 수 있습니다.

### View는 데이터를 저장하지 않습니다

가장 중요한 개념입니다. View는 **쿼리 자체를 저장**할 뿐, 결과 데이터를 복사해 두지 않습니다. View를 조회하면 그 순간 저장된 `SELECT`가 실행되어 **원본 테이블의 현재 데이터**를 가져옵니다.

```
[사용자]  →  SELECT * FROM 뷰   →  [뷰: 저장된 SELECT 실행]  →  [원본 테이블]
```

그래서 원본 테이블이 바뀌면 View의 조회 결과도 **자동으로** 바뀝니다. 이런 성질 때문에 View를 **가상 테이블**이라고 부르기도 합니다.

### 언제 사용하는가

| 목적 | 설명 |
|---|---|
| **재사용** | 복잡한 JOIN이나 집계를 한 번만 작성해 두고 계속 사용 |
| **단순화** | 사용하는 쪽에서는 테이블 하나를 조회하듯 쓸 수 있음 |
| **일관성** | 팀원 모두가 같은 정의의 "주문 금액"을 사용하게 됨 |
| **보안** | 급여 같은 민감한 컬럼을 뺀 View만 열어 줄 수 있음 |

## 13.2 View 생성

```
[문법]
CREATE VIEW 뷰이름 AS
SELECT ...;
```

**예제 13-1.** 상품 카탈로그 View를 만듭니다.

```sql
CREATE VIEW v_product_catalog AS
SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```

이제 테이블처럼 조회할 수 있습니다.

```sql
SELECT * FROM v_product_catalog ORDER BY product_id;
```

| product_id | product_name | category_name | price | stock_quantity |
|---|---|---|---|---|
| 1 | 무선 이어폰 | 전자제품 | 89000.00 | 45 |
| 2 | 블루투스 키보드 | 전자제품 | 45000.00 | 20 |
| 3 | 스탠드 조명 | 생활용품 | 32000.00 | 15 |
| 4 | 머그컵 | 생활용품 | 12000.00 | 100 |
| 5 | 원두커피 1kg | 식품 | 18000.00 | 60 |
| ... 외 5건 | | | | |

> **이름 규칙**: View 이름 앞에 `v_`를 붙이는 것은 널리 쓰이는 관례입니다. 조회할 때 이것이 테이블인지 View인지 한눈에 알 수 있어 편리합니다. 이 교재도 이 관례를 따릅니다.

### View에 WHERE, GROUP BY, JOIN을 걸 수 있습니다

View는 테이블처럼 취급되므로, 4~10장에서 배운 모든 것을 적용할 수 있습니다.

**예제 13-2.** View에 조건과 정렬을 겁니다.

```sql
SELECT product_name, price
FROM v_product_catalog
WHERE category_name = '전자제품'
ORDER BY price DESC;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |

**중요한 점은 `category_name`으로 조건을 걸었다는 것입니다.** 원래 이 컬럼은 `categories` 테이블에 있어서 JOIN 없이는 쓸 수 없었는데, View 덕분에 JOIN을 신경 쓰지 않고 조건에 사용할 수 있게 되었습니다.

**예제 13-3.** View를 집계합니다.

```sql
SELECT category_name, COUNT(*) AS 상품수, ROUND(AVG(price)) AS 평균가
FROM v_product_catalog
GROUP BY category_name
ORDER BY 평균가 DESC;
```

| category_name | 상품수 | 평균가 |
|---|---|---|
| 전자제품 | 2 | 67000 |
| 의류 | 2 | 30500 |
| 도서 | 2 | 24500 |
| 생활용품 | 2 | 22000 |
| 식품 | 2 | 21500 |

7장 예제와 같은 결과를 훨씬 짧게 얻었습니다.

### 복잡한 쿼리일수록 효과가 큽니다

**예제 13-4.** 주문 요약 View를 만듭니다.

```sql
CREATE VIEW v_order_summary AS
SELECT o.order_id, o.order_date, o.status, c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS 주문금액
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY o.order_id, o.order_date, o.status, c.customer_name;
```

```sql
SELECT * FROM v_order_summary ORDER BY order_id;
```

| order_id | order_date | status | customer_name | 주문금액 |
|---|---|---|---|---|
| 1 | 2025-06-01 | 배송완료 | 김민준 | 113000.00 |
| 2 | 2025-06-03 | 배송완료 | 이서연 | 49000.00 |
| 3 | 2025-06-10 | 배송중 | 김민준 | 45000.00 |
| 4 | 2025-06-12 | 결제완료 | 박도윤 | 54000.00 |
| 5 | 2025-06-15 | 취소 | 최지우 | 38000.00 |
| 6 | 2025-07-01 | 배송완료 | 정하은 | 121000.00 |

세 테이블 JOIN에 집계까지 들어간 쿼리인데, 사용하는 쪽에서는 이렇게 쓰면 끝입니다.

```sql
SELECT * FROM v_order_summary WHERE 주문금액 >= 100000;
```

| order_id | order_date | status | customer_name | 주문금액 |
|---|---|---|---|---|
| 1 | 2025-06-01 | 배송완료 | 김민준 | 113000.00 |
| 6 | 2025-07-01 | 배송완료 | 정하은 | 121000.00 |

> **9장의 CTE와 무엇이 다른가**: CTE는 그 쿼리 안에서만 유효하지만, View는 **데이터베이스에 저장되어** 다른 쿼리에서도 계속 쓸 수 있습니다. 한 번만 쓸 것은 CTE, 반복해서 쓸 것은 View라고 구분하면 됩니다.

### 컬럼 이름 직접 지정하기

View 이름 뒤에 괄호로 컬럼 이름을 나열할 수 있습니다.

```sql
CREATE VIEW v_member_short (번호, 이름, 지역) AS
SELECT customer_id, customer_name, city FROM customers;

SELECT * FROM v_member_short ORDER BY 번호;
```

| 번호 | 이름 | 지역 |
|---|---|---|
| 1 | 김민준 | 서울 |
| 2 | 이서연 | 부산 |
| 3 | 박도윤 | 서울 |
| ... 외 2건 | | |

`SELECT` 절에 `AS`로 별칭을 붙이는 것과 결과는 같습니다. 컬럼이 많을 때는 앞쪽에 모아 두는 편이 읽기 좋습니다.

### View 목록 확인하기

| 명령 | 확인 대상 |
|---|---|
| `\dv` | View 목록 |
| `\d 뷰이름` | View의 컬럼 구조와 정의 |
| `\dm` | Materialized View 목록 |

2장에서 배운 `\dt`는 테이블만 보여주므로, View를 확인하려면 `\dv`를 써야 합니다.

## 13.3 View 수정과 삭제

### CREATE OR REPLACE VIEW — 정의 바꾸기

```sql
CREATE OR REPLACE VIEW v_product_catalog AS
SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock_quantity,
       CASE WHEN p.stock_quantity = 0 THEN '품절' ELSE '판매중' END AS 재고상태
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```

| product_id | product_name | category_name | price | stock_quantity | 재고상태 |
|---|---|---|---|---|---|
| 1 | 무선 이어폰 | 전자제품 | 89000.00 | 45 | 판매중 |
| 2 | 블루투스 키보드 | 전자제품 | 45000.00 | 20 | 판매중 |
| 3 | 스탠드 조명 | 생활용품 | 32000.00 | 15 | 판매중 |
| ... 외 7건 | | | | | |

`재고상태` 컬럼이 추가되었습니다.

> **자주 하는 실수**: `CREATE OR REPLACE`는 **기존 컬럼을 그대로 두고 뒤에 추가**하는 것만 허용합니다. 컬럼을 빼거나 순서를 바꾸려 하면 오류가 납니다.
> ```sql
> CREATE OR REPLACE VIEW v_product_catalog AS
> SELECT product_id, product_name FROM products;
> ```
> ```
> ERROR:  cannot drop columns from view
> ```
> 이럴 때는 `DROP VIEW`로 지운 뒤 다시 만들어야 합니다.

### DROP VIEW — 삭제

```sql
DROP VIEW v_member_short;
DROP VIEW IF EXISTS v_member_short;   -- 없어도 오류가 나지 않음
```

**View를 지워도 원본 테이블의 데이터는 그대로입니다.** View는 쿼리 정의일 뿐이기 때문입니다.

11장의 테이블 삭제와 마찬가지로, 다른 View가 이 View를 사용하고 있으면 삭제가 거부됩니다.

```sql
CREATE VIEW v_expensive AS SELECT * FROM v_product_catalog WHERE price >= 40000;
DROP VIEW v_product_catalog;
```
```
ERROR:  cannot drop view v_product_catalog because other objects depend on it
DETAIL:  view v_expensive depends on view v_product_catalog
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
```

View 위에 View를 만들 수 있다는 점도 여기서 확인할 수 있습니다. 다만 몇 단계씩 쌓으면 어디서 무엇이 계산되는지 추적하기 어려워지므로 적당히 쓰는 것이 좋습니다.

## 13.4 [참고] 갱신 가능한 View

View를 통해 원본 테이블의 데이터를 수정할 수도 있습니다. 단, **조건이 맞을 때만** 가능합니다.

조건은 대략 이렇습니다. 하나의 테이블만 사용하고, `GROUP BY`·집계함수·`DISTINCT`·`UNION` 등이 없어야 합니다. 즉 **원본 행과 View의 행이 일대일로 대응**되어야 합니다.

**예제 13-5.** 갱신 가능한 View를 만들어 수정해 봅니다.

```sql
CREATE TABLE study_staff (
    staff_id   SERIAL PRIMARY KEY,
    staff_name VARCHAR(50),
    dept       VARCHAR(30),
    salary     INT
);
INSERT INTO study_staff (staff_name, dept, salary) VALUES
('강태호','영업',5200000), ('오유진','영업',3800000), ('윤성민','지원',4900000);

CREATE VIEW v_sales_staff AS
SELECT staff_id, staff_name, salary
FROM study_staff
WHERE dept = '영업';

UPDATE v_sales_staff SET salary = salary + 100000 WHERE staff_id = 2;
```

원본 테이블을 확인하면 실제로 바뀌어 있습니다.

| staff_id | staff_name | dept | salary |
|---|---|---|---|
| 1 | 강태호 | 영업 | 5200000 |
| 2 | 오유진 | 영업 | **3900000** |
| 3 | 윤성민 | 지원 | 4900000 |

이 View는 `dept` 컬럼을 보여주지 않으므로, 영업팀 담당자에게 급여 수정 권한을 주되 부서 정보는 노출하지 않는 식의 활용이 가능합니다.

### 집계가 들어간 View는 수정할 수 없습니다

```sql
UPDATE v_order_summary SET status = '배송중' WHERE order_id = 1;
```
```
ERROR:  cannot update view "v_order_summary"
DETAIL:  Views containing GROUP BY are not automatically updatable.
```

당연한 결과입니다. 합계 한 줄은 여러 원본 행에서 만들어진 것이라, 어느 행을 어떻게 바꿔야 할지 정할 수 없기 때문입니다.

### WITH CHECK OPTION — View의 조건을 벗어나는 입력 막기

갱신 가능한 View에는 함정이 하나 있습니다. `WHERE dept = '영업'`인 View에 지원팀 직원을 넣어도 **그냥 들어가 버립니다.** 입력 직후 View를 조회하면 방금 넣은 행이 보이지 않는 이상한 상황이 됩니다.

`WITH CHECK OPTION`을 붙이면 이를 막을 수 있습니다.

```sql
CREATE VIEW v_sales_staff_checked AS
SELECT staff_id, staff_name, dept, salary
FROM study_staff
WHERE dept = '영업'
WITH CHECK OPTION;

INSERT INTO v_sales_staff_checked (staff_name, dept, salary) VALUES ('외부','지원',3000000);
```
```
ERROR:  new row violates check option for view "v_sales_staff_checked"
```

영업팀으로 넣는 것은 정상 동작합니다.

```sql
INSERT INTO v_sales_staff_checked (staff_name, dept, salary) VALUES ('신입','영업',3000000);
```
```
INSERT 0 1
```

## 13.5 [참고] Materialized View

일반 View는 조회할 때마다 원본 쿼리를 실행합니다. 무거운 집계 쿼리를 자주 조회한다면 매번 계산 비용이 듭니다.

**Materialized View**(**구체화 뷰**)는 **결과를 실제로 저장**해 둡니다. 조회가 빠른 대신, 원본이 바뀌어도 **자동으로 갱신되지 않습니다.**

```sql
CREATE MATERIALIZED VIEW mv_category_stats AS
SELECT c.category_name, COUNT(*) AS 상품수, ROUND(AVG(p.price)) AS 평균가
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name;
```

**예제 13-6.** 원본을 바꾸고 결과를 비교합니다.

```sql
UPDATE products SET price = 99000 WHERE product_id = 1;

-- Materialized View: 예전 값 그대로
SELECT category_name, 평균가 FROM mv_category_stats WHERE category_name = '전자제품';
```

| category_name | 평균가 |
|---|---|
| 전자제품 | 67000 |

```sql
-- 실제 데이터로 다시 계산하면
SELECT c.category_name, ROUND(AVG(p.price)) AS 실제평균
FROM products p JOIN categories c ON p.category_id = c.category_id
WHERE c.category_name = '전자제품'
GROUP BY c.category_name;
```

| category_name | 실제평균 |
|---|---|
| 전자제품 | 72000 |

값이 다릅니다. `REFRESH`로 갱신해야 최신 상태가 됩니다.

```sql
REFRESH MATERIALIZED VIEW mv_category_stats;
SELECT category_name, 평균가 FROM mv_category_stats WHERE category_name = '전자제품';
```

| category_name | 평균가 |
|---|---|
| 전자제품 | 72000 |

### 둘의 비교

| | View | Materialized View |
|---|---|---|
| 데이터 저장 | 저장하지 않음 | **저장함** |
| 최신성 | 항상 최신 | `REFRESH` 전까지 과거 데이터 |
| 조회 속도 | 매번 계산 | 빠름 |
| 저장 공간 | 거의 없음 | 결과만큼 차지 |

**실시간성이 중요하면 View, 무거운 집계를 자주 조회하고 약간의 시차를 허용할 수 있으면 Materialized View**를 씁니다. 일 단위 통계 대시보드처럼 "어제까지의 집계"면 충분한 경우가 대표적입니다.

---

## 요약

- View는 `SELECT` 문에 이름을 붙여 저장한 것이며, 데이터가 아니라 쿼리를 저장한다
- 원본 테이블이 바뀌면 View의 조회 결과도 자동으로 바뀐다
- View는 테이블처럼 조회할 수 있어 `WHERE`, `GROUP BY`, JOIN을 모두 적용할 수 있다
- 복잡한 JOIN과 집계를 View로 감싸면 재사용성, 일관성, 보안이 함께 좋아진다
- `CREATE OR REPLACE`는 컬럼 추가만 가능하며, 컬럼을 빼려면 `DROP` 후 다시 만들어야 한다
- 단일 테이블에 집계가 없는 View는 수정이 가능하며, `WITH CHECK OPTION`으로 조건을 벗어나는 입력을 막을 수 있다
- Materialized View는 결과를 저장해 조회가 빠르지만 `REFRESH` 전까지는 과거 데이터를 보여준다

---

## 연습문제

**문제 1** (난이도: 하)
상품 번호, 상품명, 카테고리 이름, 가격을 보여주는 `v_products` View를 만드세요.

**문제 2** (난이도: 하)
문제 1의 View를 사용해 가격이 30,000원 이상인 상품을 조회하세요.

**문제 3** (난이도: 중)
고객 이름과 지역, 가입일만 보여주는 `v_customer_public` View를 만드세요. 이메일과 전화번호는 제외합니다.

**문제 4** (난이도: 중)
문제 1의 View에 "재고상태" 컬럼을 추가하세요. 재고가 0이면 '품절', 아니면 '판매중'입니다.

**문제 5** (난이도: 중)
상품별 평균 별점과 리뷰 수를 보여주는 `v_product_reviews` View를 만드세요.

**문제 6** (난이도: 중)
현재 데이터베이스에 어떤 View가 있는지 확인하세요.

**문제 7** (난이도: 상)
카테고리별 총 판매 수량을 보여주는 `v_category_sales` View를 만드세요.

**문제 8** (난이도: 상)
문제 7의 View를 통해 데이터를 수정하려고 하면 왜 실패하는지 설명하세요.

**문제 9** (난이도: 상)
View와 Materialized View 중 어느 것을 써야 할지 판단해야 하는 상황을 하나씩 제시하고 이유를 설명하세요.

**문제 10** (난이도: 상)
실습에서 만든 View를 모두 삭제하세요.

---

## 정답 및 해설

**문제 1**
```sql
CREATE VIEW v_products AS
SELECT p.product_id, p.product_name, c.category_name, p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```

**문제 2**
```sql
SELECT * FROM v_products WHERE price >= 30000 ORDER BY price DESC;
```
무선 이어폰, 블루투스 키보드, 후드 집업, 스탠드 조명 4건입니다. View 덕분에 JOIN을 다시 쓰지 않아도 됩니다.

**문제 3**
```sql
CREATE VIEW v_customer_public AS
SELECT customer_id, customer_name, city, join_date
FROM customers;
```
민감한 컬럼을 제외한 View만 열어 주는 것이 View의 대표적인 보안 활용입니다.

**문제 4**
```sql
CREATE OR REPLACE VIEW v_products AS
SELECT p.product_id, p.product_name, c.category_name, p.price,
       CASE WHEN p.stock_quantity = 0 THEN '품절' ELSE '판매중' END AS 재고상태
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```
기존 컬럼 뒤에 **추가**하는 것이므로 `CREATE OR REPLACE`가 통합니다. 컬럼 순서를 바꾸거나 빼려 했다면 오류가 났을 것입니다.

**문제 5**
```sql
CREATE VIEW v_product_reviews AS
SELECT p.product_id, p.product_name,
       ROUND(AVG(r.rating), 1) AS 평균별점,
       COUNT(*)                AS 리뷰수
FROM reviews r
JOIN products p ON r.product_id = p.product_id
GROUP BY p.product_id, p.product_name;
```

| product_id | product_name | 평균별점 | 리뷰수 |
|---|---|---|---|
| 1 | 무선 이어폰 | 4.5 | 2 |
| 4 | 머그컵 | 3.0 | 1 |
| 7 | SQL 첫걸음 | 5.0 | 1 |
| 9 | 면 티셔츠 | 2.0 | 1 |

**문제 6**
```
\dv
```

**문제 7**
```sql
CREATE VIEW v_category_sales AS
SELECT c.category_name, SUM(oi.quantity) AS 판매수량
FROM order_items oi
JOIN products   p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name;
```

**문제 8**

`GROUP BY`와 집계함수가 들어 있어 **갱신 가능한 View의 조건을 만족하지 않기** 때문입니다.

```sql
UPDATE v_category_sales SET 판매수량 = 100 WHERE category_name = '전자제품';
```
```
ERROR:  cannot update view "v_category_sales"
DETAIL:  Views containing GROUP BY are not automatically updatable.
```

"전자제품 판매수량 3"이라는 한 줄은 여러 `order_items` 행을 합쳐 만든 값이므로, 이 값을 100으로 바꾸라고 해도 원본의 어느 행을 어떻게 고쳐야 할지 정할 수 없습니다.

**문제 9**

예시 답안입니다.

- **View가 적합한 경우**: 주문 처리 화면에서 오늘 들어온 주문 목록을 보여줄 때. 방금 들어온 주문이 즉시 보여야 하므로 항상 최신 데이터를 반환하는 View가 맞습니다
- **Materialized View가 적합한 경우**: 월별 매출 통계 대시보드. 수백만 건을 집계해야 해서 매번 계산하면 느리고, "어제까지의 집계"로도 충분하므로 밤에 한 번 `REFRESH`하는 방식이 적합합니다

**문제 10**
```sql
DROP VIEW IF EXISTS v_category_sales;
DROP VIEW IF EXISTS v_product_reviews;
DROP VIEW IF EXISTS v_customer_public;
DROP VIEW IF EXISTS v_products;
```
다른 View가 참조하고 있다면 참조하는 쪽부터 삭제해야 합니다. `\dv`로 남은 View가 없는지 확인하세요. View를 지워도 `shop_db`의 원본 테이블과 데이터는 그대로 남아 있습니다.
