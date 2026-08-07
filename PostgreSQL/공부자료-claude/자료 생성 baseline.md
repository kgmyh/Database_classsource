# PostgreSQL 교재 기준 문서

이 문서는 전체 13개 챕터를 작성할 때 공통으로 사용할 **샘플 데이터베이스**와 **챕터 작성 포맷**을 정의합니다. 각 챕터를 요청할 때 "이 기준 문서 형식대로 N장을 작성해줘"라고 참조하면 됩니다.

---

## 1. 샘플 데이터베이스 — 온라인 쇼핑몰 (`shop_db`)

### 1.1 선택 이유

- 고객 → 주문 → 주문상세 → 상품 → 카테고리로 이어지는 **다단계 JOIN**이 자연스럽게 나옴
- 직원 테이블은 **자기참조(SELF JOIN, 상사-부하 관계)** 실습에 사용
- 가격·수량·평점 등 **숫자 데이터**가 많아 집계함수·윈도우함수 실습에 적합
- 리뷰 텍스트는 **NULL이 자연스럽게 존재**하는 컬럼이라 NULL 처리 실습에 적합
- 실무에서 가장 흔한 도메인이라 학생들이 직관적으로 이해함

### 1.2 ERD 요약

```
categories (1) ──< products (N)
customers  (1) ──< orders (N)
employees  (1) ──< orders (N)          -- 담당 직원 (nullable)
employees  (1) ──< employees (N)       -- manager_id 자기참조
orders     (1) ──< order_items (N)
products   (1) ──< order_items (N)
products   (1) ──< reviews (N)
customers  (1) ──< reviews (N)
```

### 1.3 DDL

```sql
CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category_id     INT REFERENCES categories(category_id),
    price           NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity  INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at      DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    city            VARCHAR(30),
    join_date       DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    employee_name   VARCHAR(50) NOT NULL,
    department      VARCHAR(30),
    manager_id      INT REFERENCES employees(employee_id),
    hire_date       DATE NOT NULL,
    salary          NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    employee_id     INT REFERENCES employees(employee_id),
    order_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    status          VARCHAR(20) NOT NULL DEFAULT '결제완료'
                    CHECK (status IN ('결제완료','배송중','배송완료','취소'))
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL   -- 주문 시점 가격 스냅샷
);

CREATE TABLE reviews (
    review_id       SERIAL PRIMARY KEY,
    product_id      INT NOT NULL REFERENCES products(product_id),
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    rating          SMALLINT CHECK (rating BETWEEN 1 AND 5),
    review_text     TEXT,                     -- NULL 허용 (평점만 남기는 경우)
    review_date     DATE NOT NULL DEFAULT CURRENT_DATE
);
```

### 1.4 샘플 데이터 (대표 행)

챕터 예제에서 결과가 일관되게 나오도록, 아래 데이터를 기준으로 예제를 작성합니다. (전체 시드 스크립트는 2장 작성 시 별도 파일로 확장)

```sql
INSERT INTO categories (category_name) VALUES
('도서'), ('전자제품'), ('생활용품'), ('식품'), ('의류');

INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('무선 이어폰', 2, 89000, 45),
('블루투스 키보드', 2, 45000, 20),
('스탠드 조명', 3, 32000, 15),
('머그컵', 3, 12000, 100),
('원두커피 1kg', 4, 18000, 60),
('견과류 세트', 4, 25000, 0),
('SQL 첫걸음', 1, 22000, 30),
('데이터베이스 개론', 1, 27000, 12),
('면 티셔츠', 5, 19000, 50),
('후드 집업', 5, 42000, 8);

INSERT INTO customers (customer_name, email, phone, city, join_date) VALUES
('김민준', 'minjun@example.com', '010-1111-2222', '서울', '2024-01-15'),
('이서연', 'seoyeon@example.com', '010-2222-3333', '부산', '2024-02-20'),
('박도윤', 'doyoon@example.com', NULL, '서울', '2024-03-05'),
('최지우', 'jiwoo@example.com', '010-4444-5555', '대전', '2024-05-11'),
('정하은', 'haeun@example.com', '010-5555-6666', '서울', '2025-01-02');

INSERT INTO employees (employee_name, department, manager_id, hire_date, salary) VALUES
('강태호', '영업팀', NULL, '2020-03-01', 5200000),
('오유진', '영업팀', 1, '2021-07-15', 3800000),
('한지민', '영업팀', 1, '2022-02-10', 3600000),
('윤성민', '고객지원팀', NULL, '2020-11-01', 4900000);

INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
(1, 2, '2025-06-01', '배송완료'),
(2, 2, '2025-06-03', '배송완료'),
(1, 3, '2025-06-10', '배송중'),
(3, NULL, '2025-06-12', '결제완료'),
(4, 3, '2025-06-15', '취소'),
(5, 2, '2025-07-01', '배송완료');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 89000), (1, 4, 2, 12000),
(2, 7, 1, 22000), (2, 8, 1, 27000),
(3, 2, 1, 45000),
(4, 5, 3, 18000),
(5, 9, 2, 19000),
(6, 1, 1, 89000), (6, 3, 1, 32000);

INSERT INTO reviews (product_id, customer_id, rating, review_text, review_date) VALUES
(1, 1, 5, '음질이 정말 좋아요', '2025-06-05'),
(1, 5, 4, NULL, '2025-07-05'),
(7, 2, 5, '입문서로 최고입니다', '2025-06-08'),
(4, 1, 3, '무난해요', '2025-06-06'),
(9, 4, 2, '사이즈가 작게 나와요', '2025-06-20');
```

> 의도적으로 넣어둔 학습 포인트: `phone`이 NULL인 고객, `stock_quantity`가 0인 상품(품절), `status = '취소'`인 주문, `review_text`가 NULL인 리뷰, `employee_id`가 NULL인 주문(담당자 미배정), 자기참조 `manager_id`. 각 챕터에서 이 지점들을 실습에 활용하면 좋습니다.

---

## 2. 챕터 작성 포맷 가이드

### 2.1 문체

- **"~합니다" 체**로 통일 (해요체·반말 금지)
- 전문 용어는 처음 등장할 때 한글 용어 + 영문 병기: 예) "제약조건(Constraint)"
- 2인칭 지칭("여러분") 대신 "~해 봅시다", "~할 수 있습니다" 식 표현 사용
- 오라클 등 타 DBMS 용어보다 **PostgreSQL 공식 문서 기준 용어** 우선 (예: "분석함수" 대신 "윈도우 함수", 필요 시 괄호 병기)

### 2.2 챕터 내부 구성 순서

각 챕터는 아래 순서를 기본 골격으로 합니다. 소단원 성격에 따라 일부 생략 가능합니다.

1. **학습 목표** — 2~4개, "~할 수 있다" 형식의 불릿
2. **도입 (왜 필요한가)** — 실무 상황이나 비유로 시작. 문법 설명 전에 "이게 왜 필요한지"부터
3. **개념 설명 + 구문(Syntax) 박스**
4. **예제** — 기준 스키마(`shop_db`) 사용, 챕터당 5~8개. 쿼리와 실행 결과를 세트로 제시
5. **요약** — 핵심 내용 5줄 이내 정리 박스
6. **연습문제** — 챕터당 5~10문항, 난이도 표기(하/중/상). 정답은 챕터 맨 끝 "정답 및 해설" 절에 분리
7. **(해당 시) 자주 하는 실수** — 입문자가 흔히 틀리는 부분 짧게 언급

### 2.3 구문(Syntax) 박스 표기 형식

```
[문법]
SELECT 컬럼명 [, 컬럼명 ...]
FROM 테이블명
[WHERE 조건]
[ORDER BY 컬럼명 [ASC|DESC]];
```

- 대괄호 `[ ]`는 생략 가능한 부분
- 필수 키워드는 대문자, 사용자가 채우는 부분은 한글로 표기

### 2.4 SQL 코드 블록 규칙

- SQL 키워드(SELECT, FROM, WHERE 등)는 **대문자**
- 테이블명·컬럼명은 **소문자**
- 절(clause) 단위로 줄바꿈 (한 줄에 하나의 절)
- 세미콜론(`;`)으로 문장 종료
- 예제 쿼리 위에는 "무엇을 하는 쿼리인지" 한 줄 주석 또는 설명 문장 선행

예:
```sql
-- 서울 지역 고객의 이름과 이메일 조회
SELECT customer_name, email
FROM customers
WHERE city = '서울';
```

### 2.5 실행 결과 표시

쿼리 바로 아래에 마크다운 표로 결과를 제시합니다. 결과가 6행을 넘으면 대표 행만 보여주고 `... 외 N건`으로 표기합니다.

```sql
SELECT customer_name, city FROM customers WHERE city = '서울';
```

| customer_name | city |
|---|---|
| 김민준 | 서울 |
| 박도윤 | 서울 |
| 정하은 | 서울 |

### 2.6 연습문제 형식

```
문제 1 (난이도: 하)
'전자제품' 카테고리에 속한 상품의 이름과 가격을 조회하세요.
```

정답은 챕터 마지막 "정답 및 해설" 절에 문제 번호 순서대로 배치하고, 정답 쿼리 + 한 줄 해설을 함께 제공합니다.

### 2.7 분량 가이드 (챕터당 기준)

| 항목 | 분량 |
|---|---|
| 개념 설명 | A4 1.5~3페이지 |
| 예제 | 5~8개 |
| 연습문제 | 5~10문항 |
| 스칼라 함수 등 레퍼런스성 챕터 | 본문은 핵심 함수 위주로 간결하게, 전체 목록은 부록으로 |

### 2.8 용어 통일표

| 사용할 용어 | 지양할 표현 |
|---|---|
| 행(Row) | 레코드, 로우 |
| 열 / 컬럼(Column) | 필드 |
| 제약조건(Constraint) | 컨스트레인트 |
| 기본키(Primary Key) | PK 단독 표기 (첫 등장 시 병기 후 이후엔 PK 허용) |
| 윈도우 함수(Window Function) | 분석함수 단독 표기 (괄호 병기는 허용) |
| 하위 쿼리 대신 **서브쿼리(Subquery)** | 하위쿼리 |

### 2.9 마크다운 강조(볼드) 표기 규칙

굵게(볼드) 강조할 대상에 괄호나 특수문자가 포함되는 경우, `**` 기호 안에 괄호까지 통째로 넣지 않고 분리해서 작성합니다.

- 올바른 표기: `**관계**(**Relation**)`
- 지양할 표기: `**관계(Relation)**`

괄호 안의 영문 병기까지 강조할 필요가 없다면, 괄호 안은 강조 없이 일반 텍스트로 둡니다.

- 예: `**테이블**(Table)`

한글 용어 + 영문 병기 패턴(예: "데이터베이스(Database)")뿐 아니라, 강조 대상 뒤에 쉼표·콜론 등 다른 특수문자가 붙는 경우에도 같은 원칙을 적용합니다 — 특수문자는 강조 기호 밖으로 뺍니다.

---

## 3. 챕터 작성 체크리스트

새 챕터를 완성할 때마다 아래를 확인합니다.

- [ ] 학습 목표가 챕터 도입부에 있는가
- [ ] 모든 예제가 `shop_db` 스키마의 실제 테이블/컬럼명을 사용하는가
- [ ] 예제 쿼리 실행 결과가 위 샘플 데이터 기준으로 실제로 맞는 값인가
- [ ] SQL 키워드 대문자 규칙을 지켰는가
- [ ] 연습문제 난이도가 하/중/상으로 표기되어 있는가
- [ ] 정답 및 해설이 챕터 끝에 분리되어 있는가
- [ ] 이전 챕터에서 다루지 않은 개념을 미리 사용하지 않았는가 (예: 3장에서 GROUP BY를 미리 쓰지 않기)
- [ ] 굵게(볼드) 강조에 괄호·특수문자를 함께 넣지 않고 `**관계**(**Relation**)` 형식으로 분리했는가
