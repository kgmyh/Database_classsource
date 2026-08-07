# 3장. SQL 개요

## 학습 목표

- SQL이 무엇이고, 왜 "선언형" 언어라고 부르는지 설명할 수 있다
- SQL 문장을 DDL, DML, DQL, DCL, TCL로 분류할 수 있다
- SQL을 작성할 때 지켜야 할 기본 규칙을 설명할 수 있다

---

## 3.1 SQL이란 무엇인가

**SQL**(**Structured Query Language**)은 관계형 데이터베이스에게 "데이터를 어떻게 다뤄 달라"고 요청하기 위한 언어입니다. 테이블을 만들고, 데이터를 넣고, 조회하고, 수정하고, 지우는 모든 작업을 SQL 문장으로 표현합니다.

앞으로 이 교재에서 배우는 내용은 전부 "SQL 문장을 어떻게 작성하는가"에 관한 것입니다. 예를 들어 아래 문장은 `customers` 테이블에서 서울에 사는 고객을 찾는 SQL입니다. (자세한 문법은 4장에서 다룹니다.)

```sql
SELECT customer_name FROM customers WHERE city = '서울';
```

## 3.2 "어떻게"가 아니라 "무엇을" — 선언형 언어

파이썬이나 자바 같은 프로그래밍 언어로 "서울에 사는 고객을 찾아라"라는 작업을 하려면, 목록을 처음부터 끝까지 반복문으로 훑으면서 조건에 맞는지 하나씩 비교하는 **절차**를 직접 작성해야 합니다.

반면 SQL은 **"무엇을"**(what) 원하는지만 **선언**하면 됩니다. "city가 서울인 고객의 이름을 달라"고 말하면, 실제로 데이터를 어떤 순서로 탐색하고 어떻게 찾을지는 PostgreSQL 내부의 **쿼리 최적화 엔진**이 알아서 결정합니다. 그래서 SQL을 **선언형 언어**(**Declarative Language**)라고 부릅니다.

이 특징 덕분에 SQL은 "어떻게 찾을지"를 몰라도 "무엇이 필요한지"만 정확히 표현하면 결과를 얻을 수 있습니다. 이 교재도 이후 내내 "어떻게 찾을지"보다는 "원하는 결과를 어떻게 선언하는지"에 초점을 맞춥니다.

## 3.3 SQL의 분류 — DDL, DML, DQL, DCL, TCL

SQL 문장은 하는 역할에 따라 다섯 가지로 분류합니다. 각 분류는 이후 별도의 장에서 자세히 다룹니다.

| 분류 | 이름 | 역할 | 예시 명령 | 다루는 장 |
|---|---|---|---|---|
| **DDL** | Data Definition Language (데이터 정의어) | 테이블 등 데이터 구조를 정의 | `CREATE`, `ALTER`, `DROP` | 11장 |
| **DML** | Data Manipulation Language (데이터 조작어) | 데이터를 입력·수정·삭제 | `INSERT`, `UPDATE`, `DELETE` | 12장 |
| **DQL** | Data Query Language (데이터 질의어) | 데이터를 조회 | `SELECT` | 4~10장 |
| **DCL** | Data Control Language (데이터 제어어) | 사용자 권한을 관리 | `GRANT`, `REVOKE` | 부록 C |
| **TCL** | Transaction Control Language (트랜잭션 제어어) | 트랜잭션을 제어 | `COMMIT`, `ROLLBACK` | 12장 |

> DQL을 DML의 일부로 분류하는 책도 있습니다. 어느 쪽이 "정답"이라기보다는 분류 기준의 차이이니, 이 교재에서는 조회(SELECT)의 비중이 크므로 DQL을 별도로 구분합니다.

각 분류가 실제로 어떤 모습인지 `shop_db`를 기준으로 미리 살펴봅시다. (문법은 아직 배우지 않았으니 "이런 형태구나" 정도로만 확인합니다.)

```sql
-- DDL: products 테이블을 만든다
CREATE TABLE products (product_id SERIAL PRIMARY KEY, product_name VARCHAR(100));

-- DML: 새 주문을 입력한다
INSERT INTO orders (customer_id, order_date) VALUES (1, '2025-06-01');

-- DQL: 상품 목록을 조회한다
SELECT product_name, price FROM products;

-- DCL: analyst 사용자에게 조회 권한을 준다
GRANT SELECT ON products TO analyst;

-- TCL: 지금까지의 변경 사항을 확정한다
COMMIT;
```

## 3.4 SQL 작성 규칙

SQL을 작성할 때 지켜야 할 기본 규칙은 다음과 같습니다.

- **대소문자**: PostgreSQL의 키워드(`SELECT`, `FROM` 등)는 대문자든 소문자든 동작에 차이가 없습니다. 다만 이 교재에서는 가독성을 위해 **키워드는 대문자**로 통일합니다
- **세미콜론**: 하나의 SQL 문장은 세미콜론(`;`)으로 끝납니다. psql에서 세미콜론을 입력하지 않으면 문장이 끝나지 않은 것으로 보고 다음 줄 입력을 계속 기다립니다
- **문자열은 작은따옴표**: `'서울'`처럼 문자·날짜 값은 작은따옴표로 감쌉니다. 큰따옴표(`"서울"`)를 사용하면 PostgreSQL은 이를 문자열이 아니라 **테이블·컬럼 이름**(식별자)으로 해석하므로 오류가 납니다
- **주석**: 한 줄 주석은 `--`, 여러 줄 주석은 `/* ... */`을 사용합니다
- **공백과 줄바꿈**: SQL은 절(clause) 단위로 줄바꿈해서 작성하면 읽기 쉽습니다. 이 교재의 모든 예제는 `SELECT`, `FROM`, `WHERE`를 각각 새 줄에 씁니다

```sql
-- 올바른 예
SELECT customer_name
FROM customers
WHERE city = '서울';

-- 오류가 나는 예 (큰따옴표를 문자열에 사용)
SELECT customer_name
FROM customers
WHERE city = "서울";   -- city라는 컬럼을 찾으려 시도하다 오류 발생
```

> **자주 하는 실수**: 다른 언어(파이썬, 자바스크립트 등)에서는 문자열에 작은따옴표와 큰따옴표를 섞어 써도 무방하지만, SQL에서는 의미가 완전히 다릅니다. **작은따옴표 = 값, 큰따옴표 = 식별자**라는 점을 꼭 기억해 둡니다.

---

## 요약

- SQL은 데이터베이스에 원하는 작업을 요청하는 언어이며, "어떻게"가 아니라 "무엇을" 원하는지 선언한다
- SQL은 역할에 따라 DDL(정의), DML(조작), DQL(조회), DCL(제어), TCL(트랜잭션 제어)로 분류된다
- 키워드는 대문자로 통일해서 작성하며, 모든 문장은 세미콜론으로 끝난다
- 문자열 값은 작은따옴표, 테이블·컬럼 이름은 큰따옴표로 구분한다

---

## 연습문제

다음 SQL 문장을 보고 DDL, DML, DQL, DCL, TCL 중 어디에 해당하는지 쓰세요. (난이도: 하~중)

**문제 1**: `CREATE TABLE reviews (review_id SERIAL PRIMARY KEY);`

**문제 2**: `SELECT * FROM orders;`

**문제 3**: `INSERT INTO customers (customer_name, email) VALUES ('홍길동', 'hong@example.com');`

**문제 4**: `GRANT SELECT ON products TO analyst;`

**문제 5**: `DELETE FROM reviews WHERE rating IS NULL;`

**문제 6**: `ALTER TABLE employees ADD COLUMN bonus NUMERIC;`

**문제 7**: `COMMIT;`

**문제 8**: `UPDATE customers SET city = '인천' WHERE customer_id = 3;`

**문제 9**: `DROP TABLE order_items;`

**문제 10** (난이도: 상): 아래 두 문장 중 오류가 나는 것을 고르고, 왜 오류가 나는지 설명하세요.
```sql
(A) SELECT product_name FROM products WHERE product_name = '머그컵';
(B) SELECT product_name FROM products WHERE product_name = "머그컵";
```

---

## 정답 및 해설

| 문제 | 정답 | 분류 이유 |
|---|---|---|
| 1 | DDL | `CREATE TABLE`로 구조를 정의 |
| 2 | DQL | `SELECT`로 데이터 조회 |
| 3 | DML | `INSERT`로 데이터 입력 |
| 4 | DCL | `GRANT`로 권한 부여 |
| 5 | DML | `DELETE`로 데이터 삭제 |
| 6 | DDL | `ALTER TABLE`로 구조 변경 |
| 7 | TCL | `COMMIT`으로 트랜잭션 확정 |
| 8 | DML | `UPDATE`로 데이터 수정 |
| 9 | DDL | `DROP TABLE`로 구조 삭제 |

**문제 10**
`(B)`가 오류입니다. 큰따옴표는 문자열이 아니라 테이블·컬럼 이름(식별자)으로 해석되기 때문에, PostgreSQL은 `"머그컵"`을 `머그컵`이라는 이름의 컬럼으로 찾으려다 실패합니다. 문자열 값은 반드시 작은따옴표로 감싸야 합니다.
