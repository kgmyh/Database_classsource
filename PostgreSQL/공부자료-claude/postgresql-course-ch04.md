# 4장. 데이터 조회 (SELECT)

## 학습 목표

- `SELECT` 문의 기본 구조를 이해하고 원하는 컬럼을 조회할 수 있다
- `WHERE` 절과 여러 조건 연산자를 사용해 원하는 행만 걸러낼 수 있다
- NULL이 일반적인 값과 어떻게 다른지 설명하고 올바르게 다룰 수 있다
- `ORDER BY`, `LIMIT`으로 결과를 정렬하고 개수를 제한할 수 있다
- SELECT 문의 논리적 실행 순서를 설명할 수 있다

---

## 4.1 SELECT 기본 구조

지금까지는 데이터베이스가 무엇인지, SQL이 어떤 언어인지를 살펴봤습니다. 이번 장부터는 실제로 데이터를 다룹니다.

데이터베이스에 저장된 데이터를 꺼내 보는 것을 **조회**(**Query**)라고 하며, 이때 사용하는 SQL 문장이 `SELECT`입니다. 실무에서 작성하는 SQL의 대부분이 `SELECT`이므로, 이 장부터 10장까지가 이 교재의 핵심입니다.

```
[문법]
SELECT 컬럼명 [, 컬럼명 ...]
FROM 테이블명;
```

- `SELECT` 뒤에는 **어떤 컬럼을 볼지**를 씁니다
- `FROM` 뒤에는 **어느 테이블에서 가져올지**를 씁니다

가장 단순한 조회부터 해 봅시다.

**예제 4-1.** 모든 상품의 이름과 가격을 조회합니다.

```sql
SELECT product_name, price
FROM products;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 스탠드 조명 | 32000.00 |
| 머그컵 | 12000.00 |
| 원두커피 1kg | 18000.00 |
| 견과류 세트 | 25000.00 |
| ... 외 4건 | |

`SELECT`에 나열한 컬럼만, 나열한 순서대로 결과에 나타납니다. 컬럼 순서를 바꿔 쓰면 결과 컬럼의 순서도 바뀝니다.

## 4.2 컬럼 선택과 `*`

모든 컬럼을 보고 싶다면 컬럼명을 일일이 쓰는 대신 별표(`*`)를 사용합니다.

**예제 4-2.** 카테고리 테이블의 모든 컬럼을 조회합니다.

```sql
SELECT *
FROM categories;
```

| category_id | category_name |
|---|---|
| 1 | 도서 |
| 2 | 전자제품 |
| 3 | 생활용품 |
| 4 | 식품 |
| 5 | 의류 |

`*`는 테이블 구조를 빠르게 확인할 때 편리합니다. 다만 실무에서는 **필요한 컬럼만 명시적으로 쓰는 것을 권장**합니다. 불필요한 데이터까지 서버에서 가져오면 느려지고, 나중에 테이블에 컬럼이 추가되면 결과 형태가 예고 없이 바뀌기 때문입니다.

## 4.3 별칭(alias)

조회 결과의 컬럼 이름을 원하는 이름으로 바꿔서 표시할 수 있습니다. 이것을 **별칭**(**alias**)이라고 하며 `AS` 키워드를 사용합니다.

```
[문법]
SELECT 컬럼명 [AS] 별칭 [, ...]
FROM 테이블명;
```

**예제 4-3.** 컬럼 이름을 한글로 바꿔 조회합니다.

```sql
SELECT customer_name AS 고객명, city AS 지역
FROM customers;
```

| 고객명 | 지역 |
|---|---|
| 김민준 | 서울 |
| 이서연 | 부산 |
| 박도윤 | 서울 |
| 최지우 | 대전 |
| 정하은 | 서울 |

`AS`는 생략할 수 있어서 `customer_name 고객명`이라고 써도 동일하게 동작합니다. 다만 읽는 사람이 헷갈리지 않도록 이 교재에서는 `AS`를 항상 씁니다.

> **자주 하는 실수**: 별칭에 띄어쓰기가 들어가거나 대문자를 유지하고 싶다면 큰따옴표로 감싸야 합니다. `AS "고객 이름"`처럼요. 3장에서 배운 대로 큰따옴표는 식별자를 감싸는 기호이며, 별칭도 식별자이기 때문입니다. 작은따옴표(`'고객 이름'`)를 쓰면 문자열로 해석되어 의도와 다르게 동작합니다.

## 4.4 연산자 — 산술 연산

조회할 때 컬럼 값을 그대로 보여주는 대신, 계산한 결과를 보여줄 수도 있습니다.

| 연산자 | 의미 | 예 |
|---|---|---|
| `+` | 더하기 | `price + 1000` |
| `-` | 빼기 | `price - 1000` |
| `*` | 곱하기 | `price * 2` |
| `/` | 나누기 | `price / 2` |
| `%` | 나머지 | `stock_quantity % 3` |

**예제 4-4.** 각 상품의 재고 금액(가격 × 재고 수량)을 함께 조회합니다.

```sql
SELECT product_name, price, stock_quantity, price * stock_quantity AS 재고금액
FROM products;
```

| product_name | price | stock_quantity | 재고금액 |
|---|---|---|---|
| 무선 이어폰 | 89000.00 | 45 | 4005000.00 |
| 블루투스 키보드 | 45000.00 | 20 | 900000.00 |
| 스탠드 조명 | 32000.00 | 15 | 480000.00 |
| 머그컵 | 12000.00 | 100 | 1200000.00 |
| 원두커피 1kg | 18000.00 | 60 | 1080000.00 |
| 견과류 세트 | 25000.00 | 0 | 0.00 |
| ... 외 4건 | | | |

계산 결과에는 원래 컬럼 이름이 없으므로 `?column?`처럼 알아보기 힘든 이름이 붙습니다. 이럴 때 별칭을 붙이면 결과를 훨씬 읽기 쉬워집니다.

> **참고**: 정수끼리 나누면 소수점 이하가 버려집니다. 예를 들어 `7 / 2`의 결과는 `3`입니다. 소수점까지 필요하다면 `7.0 / 2`처럼 한쪽을 소수로 쓰거나, 5장에서 배울 형변환을 사용합니다.

## 4.5 WHERE 절로 행 걸러내기

지금까지는 테이블의 모든 행을 가져왔습니다. 하지만 실무에서는 "서울에 사는 고객만", "3만 원 이상인 상품만"처럼 **조건에 맞는 행만** 필요한 경우가 훨씬 많습니다. 이때 사용하는 것이 `WHERE` 절입니다.

```
[문법]
SELECT 컬럼명 [, ...]
FROM 테이블명
WHERE 조건;
```

`WHERE`에 쓰는 조건은 각 행마다 참(true)인지 거짓(false)인지 판정되며, **참인 행만** 결과에 남습니다.

### 비교 연산자

| 연산자 | 의미 |
|---|---|
| `=` | 같다 |
| `<>` 또는 `!=` | 다르다 |
| `>` , `<` | 크다, 작다 |
| `>=` , `<=` | 크거나 같다, 작거나 같다 |

**예제 4-5.** 가격이 40,000원 이상인 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE price >= 40000;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 후드 집업 | 42000.00 |

> **자주 하는 실수**: 다른 프로그래밍 언어에서는 "같다"를 `==`로 쓰지만, SQL에서는 등호 하나(`=`)입니다. 그리고 "다르다"는 `<>`를 표준으로 사용합니다.

### 논리 연산자 — AND, OR, NOT

조건이 여러 개일 때는 논리 연산자로 묶습니다.

| 연산자 | 의미 |
|---|---|
| `AND` | 두 조건이 모두 참일 때 참 |
| `OR` | 두 조건 중 하나라도 참이면 참 |
| `NOT` | 조건의 결과를 뒤집음 |

**예제 4-6.** 가격이 30,000원 미만이면서 재고가 20개를 초과하는 상품을 조회합니다.

```sql
SELECT product_name, price, stock_quantity
FROM products
WHERE price < 30000 AND stock_quantity > 20;
```

| product_name | price | stock_quantity |
|---|---|---|
| 머그컵 | 12000.00 | 100 |
| 원두커피 1kg | 18000.00 | 60 |
| SQL 첫걸음 | 22000.00 | 30 |
| 면 티셔츠 | 19000.00 | 50 |

`AND`와 `OR`를 함께 쓸 때는 `AND`가 `OR`보다 먼저 계산됩니다. 의도한 대로 묶이도록 **괄호를 명시적으로 쓰는 습관**을 들이는 것이 좋습니다.

```sql
-- 의도: (도서 또는 식품) 중에서 재고가 20개를 넘는 상품
-- 괄호가 없으면 category_id = 1 OR (category_id = 4 AND stock_quantity > 20) 으로 해석됩니다
SELECT product_name
FROM products
WHERE (category_id = 1 OR category_id = 4) AND stock_quantity > 20;
```

| product_name |
|---|
| 원두커피 1kg |
| SQL 첫걸음 |

## 4.6 BETWEEN, IN, LIKE

자주 쓰는 조건 패턴에는 전용 연산자가 준비되어 있습니다.

### BETWEEN — 범위 조건

`BETWEEN A AND B`는 **A 이상 B 이하**를 의미합니다. 양쪽 끝 값을 포함한다는 점이 중요합니다.

**예제 4-7.** 가격이 20,000원 이상 30,000원 이하인 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE price BETWEEN 20000 AND 30000;
```

| product_name | price |
|---|---|
| 견과류 세트 | 25000.00 |
| SQL 첫걸음 | 22000.00 |
| 데이터베이스 개론 | 27000.00 |

`price >= 20000 AND price <= 30000`과 완전히 같은 의미이지만, `BETWEEN`을 쓰면 의도가 더 분명하게 드러납니다.

### IN — 목록 중 하나

`IN (값1, 값2, ...)`은 나열한 값 중 **하나라도 일치하면** 참입니다.

**예제 4-8.** 서울 또는 대전에 사는 고객을 조회합니다.

```sql
SELECT customer_name, city
FROM customers
WHERE city IN ('서울', '대전');
```

| customer_name | city |
|---|---|
| 김민준 | 서울 |
| 박도윤 | 서울 |
| 최지우 | 대전 |
| 정하은 | 서울 |

`city = '서울' OR city = '대전'`과 같은 뜻입니다. 비교할 값이 늘어날수록 `IN`이 훨씬 간결합니다. 반대 조건은 `NOT IN`을 사용합니다.

### LIKE — 문자열 패턴 검색

문자열의 일부만 알고 있을 때 사용합니다. 두 가지 **와일드카드**(**wildcard**) 기호를 씁니다.

| 기호 | 의미 |
|---|---|
| `%` | 임의의 문자 0개 이상 |
| `_` | 임의의 문자 정확히 1개 |

**예제 4-9.** 상품명에 "커피"가 들어간 상품을 조회합니다.

```sql
SELECT product_name, price
FROM products
WHERE product_name LIKE '%커피%';
```

| product_name | price |
|---|---|
| 원두커피 1kg | 18000.00 |

패턴을 어디에 두느냐에 따라 의미가 달라집니다.

| 패턴 | 의미 | 예 |
|---|---|---|
| `'무선%'` | "무선"으로 **시작** | 무선 이어폰 |
| `'%집업'` | "집업"으로 **끝남** | 후드 집업 |
| `'%커피%'` | "커피"를 **포함** | 원두커피 1kg |

PostgreSQL은 대소문자를 구분합니다. 대소문자를 무시하고 검색하려면 `ILIKE`를 사용합니다.

**예제 4-10.** 이메일이 `MINJUN`으로 시작하는 고객을 대소문자 구분 없이 찾습니다.

```sql
SELECT customer_name, email
FROM customers
WHERE email ILIKE 'MINJUN%';
```

| customer_name | email |
|---|---|
| 김민준 | minjun@example.com |

같은 조건을 `LIKE 'MINJUN%'`로 쓰면 결과가 한 건도 나오지 않습니다. 실제 저장된 값은 소문자 `minjun@example.com`이기 때문입니다.

## 4.7 NULL의 이해

### NULL은 값이 아니라 "값이 없는 상태"입니다

`shop_db`의 `customers` 테이블을 보면 박도윤 고객의 `phone`이 비어 있습니다. 이렇게 **값이 입력되지 않은 상태**를 NULL이라고 합니다.

여기서 반드시 구분해야 할 것이 있습니다. NULL은 **숫자 0도 아니고, 빈 문자열**(`''`)**도 아닙니다.** 0은 "수량이 0개"라는 확정된 값이고, 빈 문자열은 "빈 글자"라는 확정된 값입니다. 반면 NULL은 "무엇인지 알 수 없음"입니다.

`shop_db`에서 이 차이를 확인할 수 있습니다.

- `products` 테이블의 견과류 세트는 `stock_quantity`가 **0** → 재고가 0개라는 사실을 알고 있음
- `customers` 테이블의 박도윤은 `phone`이 **NULL** → 전화번호가 무엇인지 알 수 없음

### NULL은 `=`로 비교할 수 없습니다

NULL은 "알 수 없는 값"이므로, 알 수 없는 값과 무언가를 비교한 결과 역시 "알 수 없음"입니다. 참도 거짓도 아닙니다. 이것을 **3값 논리**(참 / 거짓 / 알 수 없음)라고 합니다.

그래서 아래 쿼리는 **오류는 나지 않지만 결과가 한 건도 나오지 않습니다.**

```sql
-- 잘못된 예: 결과가 나오지 않습니다
SELECT customer_name, phone
FROM customers
WHERE phone = NULL;
```

| customer_name | phone |
|---|---|
| (조회된 행 없음) | |

NULL 여부를 판정할 때는 반드시 `IS NULL` 또는 `IS NOT NULL`을 사용합니다.

**예제 4-11.** 전화번호가 등록되지 않은 고객을 조회합니다.

```sql
SELECT customer_name, phone
FROM customers
WHERE phone IS NULL;
```

| customer_name | phone |
|---|---|
| 박도윤 | *(NULL)* |

**예제 4-12.** 리뷰 내용을 남긴(별점만 준 것이 아닌) 리뷰를 조회합니다.

```sql
SELECT review_id, rating, review_text
FROM reviews
WHERE review_text IS NOT NULL;
```

| review_id | rating | review_text |
|---|---|---|
| 1 | 5 | 음질이 정말 좋아요 |
| 3 | 5 | 입문서로 최고입니다 |
| 4 | 3 | 무난해요 |
| 5 | 2 | 사이즈가 작게 나와요 |

### NULL이 만드는 함정

입문자가 가장 많이 놓치는 부분입니다. "김민준의 번호가 아닌 고객"을 찾으려고 아래처럼 작성하면, 전화번호가 NULL인 박도윤은 **결과에서 빠집니다.**

```sql
SELECT customer_name, phone
FROM customers
WHERE phone <> '010-1111-2222';
```

| customer_name | phone |
|---|---|
| 이서연 | 010-2222-3333 |
| 최지우 | 010-4444-5555 |
| 정하은 | 010-5555-6666 |

박도윤의 `phone`은 NULL이므로 `NULL <> '010-1111-2222'`의 결과는 참이 아니라 "알 수 없음"이고, `WHERE`는 참인 행만 남기기 때문입니다. NULL인 행까지 포함하려면 조건을 명시적으로 추가해야 합니다.

```sql
SELECT customer_name, phone
FROM customers
WHERE phone <> '010-1111-2222' OR phone IS NULL;
```

| customer_name | phone |
|---|---|
| 이서연 | 010-2222-3333 |
| 박도윤 | *(NULL)* |
| 최지우 | 010-4444-5555 |
| 정하은 | 010-5555-6666 |

> NULL을 다른 값으로 바꿔서 표시하는 방법(`COALESCE` 함수)은 5장에서 배웁니다.

## 4.8 DISTINCT — 중복 제거

같은 값이 여러 번 나올 때, 중복을 제거하고 서로 다른 값만 보고 싶다면 `DISTINCT`를 사용합니다.

```
[문법]
SELECT DISTINCT 컬럼명 [, ...]
FROM 테이블명;
```

**예제 4-13.** 고객들이 사는 지역의 종류를 조회합니다.

```sql
SELECT DISTINCT city
FROM customers;
```

| city |
|---|
| 서울 |
| 부산 |
| 대전 |

고객은 5명이지만 서울에 3명이 살고 있어 결과는 3건입니다.

`DISTINCT`는 `SELECT` 바로 뒤에 한 번만 쓸 수 있으며, **나열한 컬럼들의 조합**을 기준으로 중복을 판정합니다.

```sql
-- department와 manager_id의 "조합"이 중복되는 행을 제거합니다
SELECT DISTINCT department, manager_id
FROM employees;
```

| department | manager_id |
|---|---|
| 영업팀 | *(NULL)* |
| 영업팀 | 1 |
| 고객지원팀 | *(NULL)* |

영업팀이 두 번 나온 이유는 `manager_id`가 서로 다르기 때문입니다. `DISTINCT`가 첫 번째 컬럼에만 적용되는 것이 아니라는 점을 기억해 두세요.

## 4.9 ORDER BY — 정렬

지금까지의 결과가 특정 순서로 나온 것처럼 보였지만, **`ORDER BY`를 쓰지 않으면 행의 순서는 보장되지 않습니다.** 원하는 순서로 보려면 반드시 정렬을 지정해야 합니다.

```
[문법]
SELECT 컬럼명 [, ...]
FROM 테이블명
[WHERE 조건]
ORDER BY 컬럼명 [ASC|DESC] [, 컬럼명 [ASC|DESC] ...];
```

- `ASC` : 오름차순 (작은 값 → 큰 값). 생략하면 기본값
- `DESC` : 내림차순 (큰 값 → 작은 값)

**예제 4-14.** 상품을 가격이 비싼 순서로 조회합니다.

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 후드 집업 | 42000.00 |
| 스탠드 조명 | 32000.00 |
| 데이터베이스 개론 | 27000.00 |
| 견과류 세트 | 25000.00 |
| ... 외 4건 | |

### 여러 기준으로 정렬하기

컬럼을 쉼표로 나열하면, 앞 컬럼이 같을 때 뒤 컬럼으로 순서를 정합니다.

**예제 4-15.** 카테고리 순으로 묶되, 같은 카테고리 안에서는 비싼 상품이 먼저 오도록 정렬합니다.

```sql
SELECT category_id, product_name, price
FROM products
ORDER BY category_id ASC, price DESC;
```

| category_id | product_name | price |
|---|---|---|
| 1 | 데이터베이스 개론 | 27000.00 |
| 1 | SQL 첫걸음 | 22000.00 |
| 2 | 무선 이어폰 | 89000.00 |
| 2 | 블루투스 키보드 | 45000.00 |
| 3 | 스탠드 조명 | 32000.00 |
| 3 | 머그컵 | 12000.00 |
| ... 외 4건 | | |

### NULL의 정렬 순서

PostgreSQL은 오름차순으로 정렬할 때 NULL을 **가장 마지막**에 놓습니다(`NULLS LAST`가 기본). 이 동작은 `NULLS FIRST` / `NULLS LAST`로 직접 지정할 수 있습니다.

**예제 4-16.** 전화번호 순으로 정렬하되, 전화번호가 없는 고객을 맨 앞에 표시합니다.

```sql
SELECT customer_name, phone
FROM customers
ORDER BY phone ASC NULLS FIRST;
```

| customer_name | phone |
|---|---|
| 박도윤 | *(NULL)* |
| 김민준 | 010-1111-2222 |
| 이서연 | 010-2222-3333 |
| 최지우 | 010-4444-5555 |
| 정하은 | 010-5555-6666 |

> **참고**: 한글 문자열의 정렬 순서는 데이터베이스를 만들 때 설정한 **로케일**(**locale**)에 따라 달라질 수 있습니다. 한글 가나다순으로 정렬되지 않는다면 데이터베이스의 로케일 설정을 확인해 보세요.

## 4.10 LIMIT / OFFSET — 조회 개수 제한

"가장 비싼 상품 3개"처럼 결과의 일부만 필요할 때 사용합니다.

```
[문법]
SELECT 컬럼명 [, ...]
FROM 테이블명
[WHERE 조건]
[ORDER BY 컬럼명]
LIMIT 개수 [OFFSET 건너뛸_개수];
```

**예제 4-17.** 가장 비싼 상품 3개를 조회합니다.

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 3;
```

| product_name | price |
|---|---|
| 무선 이어폰 | 89000.00 |
| 블루투스 키보드 | 45000.00 |
| 후드 집업 | 42000.00 |

`OFFSET`은 앞에서부터 지정한 개수만큼 건너뛴 뒤 결과를 가져옵니다. 웹사이트의 페이지 넘김 기능이 이 방식으로 구현됩니다.

**예제 4-18.** 가격 순으로 4번째부터 3개를 조회합니다(2페이지에 해당).

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 3 OFFSET 3;
```

| product_name | price |
|---|---|
| 스탠드 조명 | 32000.00 |
| 데이터베이스 개론 | 27000.00 |
| 견과류 세트 | 25000.00 |

> **자주 하는 실수**: `LIMIT`은 `ORDER BY`와 함께 써야 의미가 있습니다. 정렬 없이 `LIMIT 3`만 쓰면 "아무 3건"이 나오며, 실행할 때마다 결과가 달라질 수 있습니다.

## 4.11 SELECT 문의 논리적 실행 순서

SQL을 **작성하는 순서**와 데이터베이스가 **처리하는 순서**는 다릅니다. 이 차이를 이해하면 이후 장에서 만나는 여러 규칙이 자연스럽게 설명됩니다.

| 작성 순서 | 처리 순서 |
|---|---|
| ① SELECT | ④ SELECT |
| ② FROM | ① FROM |
| ③ WHERE | ② WHERE |
| ④ ORDER BY | ⑤ ORDER BY |
| ⑤ LIMIT | ⑥ LIMIT |

즉 데이터베이스는 **어느 테이블에서**(FROM) → **어떤 행을 남기고**(WHERE) → **어떤 컬럼을 보여줄지**(SELECT) → **어떻게 정렬해서**(ORDER BY) → **몇 건만**(LIMIT) 순서로 처리합니다. (`DISTINCT`는 SELECT 직후, GROUP BY와 HAVING은 6장에서 이 순서에 추가됩니다.)

이 순서가 만들어내는 대표적인 결과가 **별칭의 사용 범위**입니다. 별칭은 `SELECT` 단계에서 만들어지므로, 그보다 **먼저** 처리되는 `WHERE`에서는 사용할 수 없습니다.

```sql
-- 오류: WHERE가 처리되는 시점에는 "재고금액"이라는 별칭이 아직 존재하지 않습니다
SELECT product_name, price * stock_quantity AS 재고금액
FROM products
WHERE 재고금액 > 1000000;
```

```
ERROR:  column "재고금액" does not exist
```

`WHERE`에서 쓰려면 계산식을 그대로 반복해서 씁니다.

```sql
SELECT product_name, price * stock_quantity AS 재고금액
FROM products
WHERE price * stock_quantity > 1000000;
```

| product_name | 재고금액 |
|---|---|
| 무선 이어폰 | 4005000.00 |
| 머그컵 | 1200000.00 |
| 원두커피 1kg | 1080000.00 |

반대로 `ORDER BY`는 `SELECT`보다 **나중에** 처리되므로 별칭을 그대로 사용할 수 있습니다.

```sql
SELECT product_name, price * stock_quantity AS 재고금액
FROM products
ORDER BY 재고금액 DESC;
```

| product_name | 재고금액 |
|---|---|
| 무선 이어폰 | 4005000.00 |
| 머그컵 | 1200000.00 |
| 원두커피 1kg | 1080000.00 |
| 면 티셔츠 | 950000.00 |
| 블루투스 키보드 | 900000.00 |
| SQL 첫걸음 | 660000.00 |
| ... 외 4건 | |

---

## 요약

- `SELECT 컬럼 FROM 테이블` 이 조회의 기본 구조이며, `*`는 모든 컬럼을 의미한다
- `AS`로 별칭을 붙여 결과 컬럼의 이름을 바꿀 수 있다
- `WHERE` 절과 비교·논리 연산자로 원하는 행만 걸러낸다. `BETWEEN`(범위), `IN`(목록), `LIKE`(패턴)는 자주 쓰는 조건을 간결하게 표현한다
- NULL은 값이 아니라 "알 수 없음"이므로 `=`가 아니라 `IS NULL` / `IS NOT NULL`로 판정한다. `<>` 조건은 NULL인 행을 걸러낸다는 점에 주의한다
- `DISTINCT`는 나열한 컬럼들의 조합을 기준으로 중복을 제거한다
- `ORDER BY` 없이는 행의 순서가 보장되지 않으며, `LIMIT`은 `ORDER BY`와 함께 써야 의미가 있다
- 처리 순서는 FROM → WHERE → SELECT → ORDER BY → LIMIT이며, 그래서 별칭은 `WHERE`에서는 못 쓰고 `ORDER BY`에서는 쓸 수 있다

---

## 연습문제

**문제 1** (난이도: 하)
`customers` 테이블에서 고객 이름과 이메일만 조회하세요.

**문제 2** (난이도: 하)
`products` 테이블의 모든 컬럼을 조회하세요.

**문제 3** (난이도: 하)
`products` 테이블에서 상품명을 "상품명", 가격을 "판매가"라는 별칭으로 바꿔 조회하세요.

**문제 4** (난이도: 하)
가격이 30,000원 이상인 상품의 이름과 가격을 조회하세요.

**문제 5** (난이도: 중)
재고가 완전히 소진된(재고 수량이 0인) 상품의 이름을 조회하세요.

**문제 6** (난이도: 중)
서울에 살지 않는 고객의 이름과 지역을 조회하세요.

**문제 7** (난이도: 중)
상품명에 "커피"가 포함된 상품을 조회하세요.

**문제 8** (난이도: 중)
전화번호가 등록되지 않은 고객의 이름을 조회하세요.

**문제 9** (난이도: 중)
`employees` 테이블에 어떤 부서들이 있는지 중복 없이 조회하세요.

**문제 10** (난이도: 중)
`orders` 테이블에서 취소되지 않은 주문을 최근 주문일 순서로 조회하세요. (주문번호, 주문일, 상태를 표시)

**문제 11** (난이도: 상)
가장 저렴한 상품 3개를 조회하세요. (상품명, 가격)

**문제 12** (난이도: 상)
`reviews` 테이블에서 별점이 4점 이상인 리뷰를 별점이 높은 순으로 조회하되, 별점이 같으면 최근 리뷰가 먼저 오도록 정렬하세요.

---

## 정답 및 해설

**문제 1**
```sql
SELECT customer_name, email
FROM customers;
```

**문제 2**
```sql
SELECT *
FROM products;
```
10건이 조회됩니다.

**문제 3**
```sql
SELECT product_name AS 상품명, price AS 판매가
FROM products;
```

**문제 4**
```sql
SELECT product_name, price
FROM products
WHERE price >= 30000;
```
무선 이어폰, 블루투스 키보드, 스탠드 조명, 후드 집업 4건이 조회됩니다.

**문제 5**
```sql
SELECT product_name
FROM products
WHERE stock_quantity = 0;
```
견과류 세트 1건입니다. 재고 0은 NULL이 아니라 확정된 값이므로 `= 0`으로 비교합니다.

**문제 6**
```sql
SELECT customer_name, city
FROM customers
WHERE city <> '서울';
```
이서연(부산), 최지우(대전) 2건입니다. 참고로 `city`에 NULL인 행이 있었다면 이 조건에서 빠졌을 것입니다.

**문제 7**
```sql
SELECT product_name, price
FROM products
WHERE product_name LIKE '%커피%';
```
원두커피 1kg 1건입니다. 앞뒤에 `%`를 모두 붙여야 "포함"을 의미합니다.

**문제 8**
```sql
SELECT customer_name
FROM customers
WHERE phone IS NULL;
```
박도윤 1건입니다. `WHERE phone = NULL`로 쓰면 결과가 나오지 않습니다.

**문제 9**
```sql
SELECT DISTINCT department
FROM employees;
```
영업팀, 고객지원팀 2건입니다.

**문제 10**
```sql
SELECT order_id, order_date, status
FROM orders
WHERE status <> '취소'
ORDER BY order_date DESC;
```

| order_id | order_date | status |
|---|---|---|
| 6 | 2025-07-01 | 배송완료 |
| 4 | 2025-06-12 | 결제완료 |
| 3 | 2025-06-10 | 배송중 |
| 2 | 2025-06-03 | 배송완료 |
| 1 | 2025-06-01 | 배송완료 |

**문제 11**
```sql
SELECT product_name, price
FROM products
ORDER BY price ASC
LIMIT 3;
```

| product_name | price |
|---|---|
| 머그컵 | 12000.00 |
| 원두커피 1kg | 18000.00 |
| 면 티셔츠 | 19000.00 |

`ASC`는 기본값이므로 생략해도 됩니다.

**문제 12**
```sql
SELECT review_id, rating, review_date
FROM reviews
WHERE rating >= 4
ORDER BY rating DESC, review_date DESC;
```

| review_id | rating | review_date |
|---|---|---|
| 3 | 5 | 2025-06-08 |
| 1 | 5 | 2025-06-05 |
| 2 | 4 | 2025-07-05 |

별점이 5점인 두 리뷰 중 더 최근인 3번이 먼저 나옵니다. 2번 리뷰는 날짜가 가장 최근이지만 별점이 낮으므로 마지막에 놓입니다 — 정렬 기준의 우선순위를 확인할 수 있는 문제입니다.
