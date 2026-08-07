# MySQL View 수업 자료

> **대상:** SQL 입문자 · **수업 시간:** 3시간 · **구성:** 4개 파트

---

## 커리큘럼 개요

| 파트 | 주제 | 시간 |
|------|------|------|
| Part 1 | View란 무엇인가? | 40분 |
| Part 2 | View 활용 패턴 | 50분 |
| Part 3 | View의 특성 이해 | 50분 |
| Part 4 | 실전 활용 & 종합 실습 | 40분 |

---

## Part 1. View란 무엇인가?

### 1-1. View를 사용해야 하는 이유

View는 단순히 "편리한 기능"이 아니다. 실무에서 SQL을 작성하다 보면 반드시 마주치는 문제들을 해결하는 핵심 도구이다. 아래 5가지 관점에서 View가 왜 필요한지 이해한다.

---

#### ① 복잡한 쿼리의 반복 작성 문제

실무 데이터베이스는 수십 개의 테이블이 서로 연결되어 있다. 하나의 화면에 데이터를 보여주려면 여러 테이블을 JOIN하고, 집계하고, 조건을 거는 긴 쿼리가 필요하다.

**View 없이 매번 반복해야 하는 경우:**

```sql
-- 주문 현황 화면마다 이 쿼리를 반복해서 작성해야 한다
SELECT
    o.order_id,
    c.name        AS customer_name,
    c.email       AS customer_email,
    p.name        AS product_name,
    p.category,
    o.quantity,
    p.price,
    o.quantity * p.price  AS total_price,
    o.status,
    o.order_date
FROM orders o
    INNER JOIN customers c ON o.customer_id = c.id
    INNER JOIN products  p ON o.product_id  = p.id
WHERE o.status = 'completed';
```

**View로 한 번만 정의하면:**

```sql
-- 한 번만 View로 등록한다
CREATE VIEW vw_completed_orders AS
SELECT
    o.order_id,
    c.name        AS customer_name,
    c.email       AS customer_email,
    p.name        AS product_name,
    p.category,
    o.quantity,
    p.price,
    o.quantity * p.price  AS total_price,
    o.status,
    o.order_date
FROM orders o
    INNER JOIN customers c ON o.customer_id = c.id
    INNER JOIN products  p ON o.product_id  = p.id
WHERE o.status = 'completed';

-- 이후 어디서든 이렇게 사용한다
SELECT * FROM vw_completed_orders;
SELECT * FROM vw_completed_orders WHERE total_price > 50000;
SELECT customer_name, SUM(total_price) FROM vw_completed_orders GROUP BY customer_name;
```

> **핵심:** 같은 쿼리를 여러 곳에서 반복하면, 나중에 테이블 구조가 바뀔 때 모든 곳을 찾아서 수정해야 한다. View는 수정이 필요한 지점을 단 한 곳으로 줄여준다.

---

#### ② 유지보수 비용 문제

소프트웨어는 언제나 변한다. 테이블에 컬럼이 추가되거나, 테이블 이름이 바뀌거나, 비즈니스 로직이 달라질 수 있다.

**View 없이 직접 쿼리를 사용하는 경우:**

```
변경 발생
    ↓
소스코드 전체 검색 (100곳? 1000곳?)
    ↓
모든 쿼리를 하나씩 수정
    ↓
누락된 곳에서 버그 발생
```

**View를 사용하는 경우:**

```
변경 발생
    ↓
View 정의 1곳만 수정
    ↓
View를 사용하는 모든 쿼리에 자동 반영
```

```sql
-- 예시: orders 테이블에 discount 컬럼이 추가된 경우
-- View 정의 한 곳만 수정하면 된다
CREATE OR REPLACE VIEW vw_completed_orders AS
SELECT
    o.order_id,
    c.name   AS customer_name,
    p.name   AS product_name,
    o.quantity,
    p.price,
    o.discount,                                         -- 새로 추가된 컬럼
    o.quantity * p.price * (1 - o.discount) AS total_price  -- 계산식 수정
FROM orders o
    INNER JOIN customers c ON o.customer_id = c.id
    INNER JOIN products  p ON o.product_id  = p.id
WHERE o.status = 'completed';
-- 이 View를 사용하는 다른 쿼리는 전혀 수정하지 않아도 된다
```

---

#### ③ 보안 — 민감한 데이터 보호

데이터베이스에는 모든 사람이 볼 수 있어서는 안 되는 민감한 데이터가 있다. 급여, 개인정보, 원가 등이 대표적인 예이다.

```sql
-- employees 테이블에는 민감 컬럼이 포함되어 있다
-- employees (id, name, dept, salary, ssn, bank_account, hire_date)

-- HR 팀에게는 이름/부서/입사일만 보여주는 View를 만든다
CREATE VIEW vw_emp_for_hr AS
SELECT id, name, dept, hire_date   -- salary, ssn, bank_account 제외
FROM employees;

-- 개발팀 리더에게는 이름/부서/연봉 범위만 보여준다
CREATE VIEW vw_emp_for_dev AS
SELECT
    id,
    name,
    dept,
    CASE
        WHEN salary < 40000 THEN '3000만원 미만'
        WHEN salary < 60000 THEN '3000~5000만원'
        WHEN salary < 80000 THEN '5000~7000만원'
        ELSE '7000만원 이상'
    END AS salary_range   -- 실제 급여 대신 범위만 노출
FROM employees;

-- 계정별 권한 설정: HR 계정은 원본 테이블 접근을 차단하고 View만 허용
REVOKE ALL   ON mydb.employees    FROM 'hr_user'@'%';
GRANT SELECT ON mydb.vw_emp_for_hr TO  'hr_user'@'%';
```

> **핵심:** View + 권한 설정을 함께 사용하면, 같은 테이블에서 역할별로 서로 다른 데이터를 보여주는 세밀한 접근 제어가 가능하다.

---

#### ④ 쿼리 복잡도 감소 — 비개발자 친화적 환경

데이터 분석가, 기획자, 마케터도 SQL로 데이터를 조회하는 경우가 많다. 이들이 매번 복잡한 JOIN 쿼리를 작성하는 것은 비효율적이다.

```sql
-- 분석가가 보고싶은 것: "고객별 월별 구매 현황"
-- View 없이 직접 쿼리를 작성해야 한다면 매우 복잡하다

-- ✅ DBA가 미리 View를 준비해두면
CREATE VIEW vw_monthly_purchase AS
SELECT
    c.name                                    AS customer_name,
    c.grade,
    DATE_FORMAT(o.order_date, '%Y-%m')        AS month,
    COUNT(*)                                  AS order_count,
    SUM(o.quantity * p.price)                 AS total_spent
FROM orders o
    JOIN customers c ON o.customer_id = c.id
    JOIN products  p ON o.product_id  = p.id
GROUP BY c.name, c.grade, DATE_FORMAT(o.order_date, '%Y-%m');

-- 분석가는 이렇게만 쓰면 된다
SELECT * FROM vw_monthly_purchase
WHERE month = '2024-03'
ORDER BY total_spent DESC;
```

---

#### ⑤ 비즈니스 로직의 중앙화

애플리케이션 코드(Java, Python 등)에 SQL 로직이 흩어지면, 같은 로직이 서버마다 다르게 구현될 위험이 있다. View에 비즈니스 로직을 담으면 단일 진실 공급원(Single Source of Truth)이 된다.

```sql
-- "VIP 고객" 기준이 바뀌었을 때의 시나리오
-- 기존: 총 구매금액 100만원 이상
-- 변경: 총 구매금액 150만원 이상 AND 최근 6개월 이내 구매 이력 있음

-- View 없이 애플리케이션 코드 여러 곳에 조건이 흩어진 경우:
-- → Java 서버, Python 배치, 분석 대시보드 등 모든 곳을 수정해야 한다

-- View로 중앙 관리하는 경우:
CREATE OR REPLACE VIEW vw_vip_customers AS
SELECT c.id, c.name, c.email, SUM(o.quantity * p.price) AS total_spent
FROM customers c
    JOIN orders o ON c.id = o.customer_id
    JOIN products p ON o.product_id = p.id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)  -- 최근 6개월 조건 추가
GROUP BY c.id, c.name, c.email
HAVING total_spent >= 1500000;   -- 기준 150만원으로 변경
-- View 한 곳만 수정하면 모든 시스템에 즉시 반영된다
```

---

#### View 사용 이유 — 요약

| 이유 | 설명 |
|------|------|
| 쿼리 재사용 | 복잡한 JOIN/집계 쿼리를 한 번만 정의하고 어디서든 간단하게 재사용한다 |
| 유지보수 용이 | 변경이 필요할 때 View 정의 한 곳만 수정하면 전체에 반영된다 |
| 보안 강화 | 민감한 컬럼을 숨기고, 계정별로 다른 View에만 접근 권한을 부여한다 |
| 복잡도 감소 | 비개발자도 단순한 View 이름으로 복잡한 데이터를 조회할 수 있다 |
| 로직 중앙화 | 비즈니스 규칙을 View에 모아두면 일관성을 유지하기 쉽다 |

---

### 1-2. View의 기본 구조

View는 "저장된 SELECT 쿼리"이다. 실제 데이터를 복사해서 저장하는 것이 아니라, SELECT 문 자체를 저장한다. 호출할 때마다 저장된 쿼리를 실행해서 결과를 반환한다.

```
┌─────────────────────────────────────────────────┐
│  CREATE VIEW vw_example AS                      │
│    SELECT id, name FROM users WHERE active = 1; │
│                                                 │
│  저장되는 것: SELECT 문 (쿼리 정의)               │
│  저장 안 되는 것: 실제 데이터 행(Row)             │
└─────────────────────────────────────────────────┘
         ↓  SELECT * FROM vw_example 호출 시
┌─────────────────────────────────────────────────┐
│  내부적으로 원본 쿼리를 실행한다                  │
│  → 항상 최신 데이터를 반환한다                    │
└─────────────────────────────────────────────────┘
```

**테이블 vs View 비교:**

| 구분 | 테이블 (TABLE) | View (VIEW) |
|------|---------------|-------------|
| 데이터 저장 | 실제 디스크에 저장한다 | 쿼리 정의만 저장한다 (가상) |
| 데이터 최신화 | 직접 INSERT/UPDATE 필요 | 항상 최신 데이터를 반환한다 |
| 수정 가능 여부 | INSERT/UPDATE/DELETE 자유롭다 | 조건 충족 시에만 가능하다 |
| 성능 | 인덱스 활용 가능하다 | 실행 시마다 쿼리를 재실행한다 |
| 용도 | 실제 데이터 보관 | 복잡한 쿼리 단순화, 보안 처리 |

---

### 1-3. 기본 문법: CREATE VIEW

```sql
-- 기본 형태
CREATE VIEW 뷰_이름 AS
SELECT 컬럼1, 컬럼2, ...
FROM 테이블명
WHERE 조건;

-- 실제 예시: 활성 고객만 보여주는 View
CREATE VIEW vw_active_customers AS
SELECT id, name, email
FROM customers
WHERE is_active = 1;

-- 네이밍 관례: vw_ 접두어를 붙여 테이블과 구분한다
-- vw_order_detail, vw_monthly_sales, vw_emp_for_hr 등
```

---

### 1-4. View 조회 · 수정 · 삭제

```sql
-- View 목록 조회
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- View 정의 확인
SHOW CREATE VIEW vw_active_customers;

-- View 수정: CREATE OR REPLACE VIEW 사용
CREATE OR REPLACE VIEW vw_active_customers AS
SELECT id, name, email, phone    -- phone 컬럼 추가
FROM customers
WHERE is_active = 1;

-- View 삭제
DROP VIEW IF EXISTS vw_active_customers;

-- 여러 View 동시 삭제
DROP VIEW IF EXISTS vw_view1, vw_view2;
```

> **주의:** `ALTER VIEW` 문법도 존재하지만, `CREATE OR REPLACE VIEW`가 더 많이 쓰인다. 존재하지 않는 View에 `ALTER VIEW`를 실행하면 오류가 발생하지만, `CREATE OR REPLACE VIEW`는 없으면 새로 만들고 있으면 교체하기 때문이다.

---

### ✏️ 실습 1: 첫 번째 View 만들기

**샘플 테이블:** `employees(id, name, dept, salary, hire_date)`

1. 연봉(salary)이 50,000 이상인 직원만 보여주는 View `vw_senior_emp`를 생성한다
2. `SHOW CREATE VIEW`로 정의를 확인한다
3. `DROP VIEW`로 삭제 후 재생성을 연습한다
4. `SELECT * FROM vw_senior_emp`로 데이터를 조회한다

---

## Part 2. View 활용 패턴

### 2-1. 단순 View — 단일 테이블

한 테이블에서 특정 조건이나 컬럼만 노출하는 가장 기본적인 패턴이다.

```sql
-- 패턴 1: 특정 컬럼만 노출 (민감 정보 제외)
CREATE VIEW vw_emp_public AS
SELECT id, name, dept, hire_date   -- salary는 제외한다
FROM employees;

-- 패턴 2: 조건 필터링
CREATE VIEW vw_it_dept AS
SELECT id, name, salary
FROM employees
WHERE dept = 'IT';

-- 패턴 3: 계산 컬럼 추가
CREATE VIEW vw_emp_with_grade AS
SELECT
    id,
    name,
    salary,
    CASE
        WHEN salary >= 80000 THEN 'A'
        WHEN salary >= 60000 THEN 'B'
        ELSE                      'C'
    END AS grade
FROM employees;
```

---

### 2-2. JOIN View — 여러 테이블 결합

실무에서 가장 많이 쓰이는 패턴이다. JOIN 쿼리를 View로 저장해 반복 작성을 없앤다.

```sql
-- orders + customers + products 3개 테이블 JOIN View
CREATE VIEW vw_order_detail AS
SELECT
    o.order_id,
    c.name    AS customer_name,
    p.name    AS product_name,
    o.quantity,
    p.price,
    o.quantity * p.price  AS total_price,
    o.order_date
FROM orders o
    INNER JOIN customers c ON o.customer_id = c.id
    INNER JOIN products  p ON o.product_id  = p.id;

-- 사용할 때는 단순하게 쓴다
SELECT * FROM vw_order_detail
WHERE order_date >= '2024-01-01'
ORDER BY total_price DESC;
```

**JOIN View 네이밍 팁:**
- `vw_` 접두어를 붙여 테이블과 구분한다
- 동사보다 명사로 — 무엇을 보여주는지 이름에 담는다
- JOIN한 테이블이 많으면 주 테이블 이름 기준으로 작성한다 (예: `vw_order_xxx`)

---

### 2-3. 집계 View — GROUP BY

통계나 요약 데이터를 자주 조회할 때 유용하다.

```sql
-- 부서별 통계 View
CREATE VIEW vw_dept_stats AS
SELECT
    dept,
    COUNT(*)     AS emp_count,
    AVG(salary)  AS avg_salary,
    MAX(salary)  AS max_salary,
    MIN(salary)  AS min_salary
FROM employees
GROUP BY dept;

-- 사용 예시
SELECT * FROM vw_dept_stats WHERE avg_salary > 60000;

-- 월별 매출 현황 View (vw_order_detail을 기반으로 사용)
CREATE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m')  AS month,
    COUNT(*)                          AS order_count,
    SUM(total_price)                  AS revenue
FROM vw_order_detail   -- View를 FROM에 사용하는 것도 가능하다
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

> **주의:** GROUP BY가 포함된 집계 View는 UPDATE/INSERT/DELETE가 불가능한 읽기 전용 View가 된다. 이 특성은 Part 3에서 자세히 다룬다.

---

### 2-4. WITH CHECK OPTION

View를 통해 데이터를 INSERT/UPDATE할 때, View의 WHERE 조건을 위반하는 행을 막아주는 옵션이다.

```sql
-- IT 부서 직원만 다루는 View (CHECK OPTION 포함)
CREATE VIEW vw_it_dept AS
SELECT id, name, dept, salary
FROM employees
WHERE dept = 'IT'
WITH CHECK OPTION;   -- ← 이 줄이 핵심이다

-- ✅ 성공: dept = 'IT'이므로 View 조건을 통과한다
INSERT INTO vw_it_dept (name, dept, salary)
VALUES ('김개발', 'IT', 55000);

-- ❌ 오류 발생: dept = 'HR'은 View의 WHERE 조건 위반
INSERT INTO vw_it_dept (name, dept, salary)
VALUES ('이인사', 'HR', 48000);
-- ERROR 1369 (HY000): CHECK OPTION failed 'mydb.vw_it_dept'
```

**WITH CHECK OPTION이 없으면 어떻게 되는가?**

```sql
-- CHECK OPTION 없이 만든 View
CREATE VIEW vw_it_dept_no_check AS
SELECT id, name, dept, salary
FROM employees
WHERE dept = 'IT';

-- HR 직원을 INSERT해도 오류가 발생하지 않는다
INSERT INTO vw_it_dept_no_check (name, dept, salary)
VALUES ('이인사', 'HR', 48000);   -- 성공하지만...

-- 이 행은 View에서 보이지 않는다 (dept = 'IT'가 아니므로)
-- 원본 테이블 employees에는 들어가 있지만 View로는 확인 불가능하다
-- 이런 "유령 데이터" 상황을 WITH CHECK OPTION으로 방지한다
```

---

### ✏️ 실습 2: JOIN View와 집계 View 작성

1. `customers + orders`를 JOIN하는 `vw_customer_orders` View를 작성한다
2. 위 View를 기반으로 고객별 총 주문금액 집계 View를 작성한다
3. `WITH CHECK OPTION` 동작을 직접 확인한다 (성공/실패 케이스 모두 실행한다)

---

## Part 3. View의 특성 이해

### 3-1. Updatable View vs Read-only View

모든 View가 UPDATE/INSERT/DELETE를 지원하지는 않는다. 수정 가능 여부를 결정하는 조건을 이해한다.

| 조건 | 수정 가능 여부 | 이유 |
|------|---------------|------|
| 단일 테이블, 단순 SELECT | ✅ 수정 가능 | 원본 행과 1:1 매핑이 명확하다 |
| GROUP BY / HAVING 포함 | ❌ 읽기 전용 | 집계 결과는 단일 행이 아니다 |
| DISTINCT 포함 | ❌ 읽기 전용 | 원본 행을 특정할 수 없다 |
| UNION / UNION ALL 포함 | ❌ 읽기 전용 | 여러 쿼리의 합산 결과이다 |
| 서브쿼리 포함 | ❌ 읽기 전용 | 연산 결과라 원본 특정이 불가하다 |
| JOIN 포함 (단순) | △ 조건부 가능 | 주 테이블 1개만 수정 가능하다 |

```sql
-- ✅ Updatable View 예시
CREATE VIEW vw_it_emp AS
SELECT id, name, salary
FROM employees
WHERE dept = 'IT';

UPDATE vw_it_emp SET salary = 70000 WHERE id = 5;   -- 가능하다

-- ❌ Read-only View 예시 (GROUP BY 포함)
CREATE VIEW vw_dept_avg AS
SELECT dept, AVG(salary) AS avg_sal
FROM employees
GROUP BY dept;

UPDATE vw_dept_avg SET avg_sal = 80000 WHERE dept = 'IT';
-- ERROR 1288: The target table vw_dept_avg is not updatable

-- View가 Updatable인지 확인하는 방법
SELECT TABLE_NAME, IS_UPDATABLE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = DATABASE();
```

---

### 3-2. View의 장점과 주의사항

**장점:**

| 장점 | 내용 |
|------|------|
| 쿼리 재사용 | 복잡한 JOIN, 집계 쿼리를 한 번만 정의하고 여러 곳에서 활용한다 |
| 보안 강화 | 급여, 주민번호 같은 민감 컬럼을 숨기고 필요한 부분만 노출한다 |
| 유지보수 용이 | 테이블 구조 변경 시 View 한 곳만 수정하면 된다 |
| 복잡성 감소 | 비개발자도 단순한 View 이름으로 데이터를 조회할 수 있다 |

**주의해야 할 상황:**

- **중첩 View 남용:** View 위에 View를 여러 번 쌓으면 쿼리 최적화가 어려워진다
- **성능 착각:** View는 실행 시마다 내부 쿼리를 재실행한다. 캐시가 아니다
- **로직 과도 의존:** 모든 로직이 View에만 있으면 관리 추적이 어려워진다
- **테이블 변경 시 오류:** 컬럼 삭제 후 View가 오류를 낼 수 있다. 테이블 변경 시 관련 View를 함께 점검한다

---

### 3-3. ALGORITHM 옵션 (개념 이해)

MySQL은 View를 실행할 때 두 가지 방식 중 하나를 선택한다. 명시적으로 지정할 수도 있다.

```sql
-- ALGORITHM 명시 형태
CREATE ALGORITHM = MERGE VIEW vw_example AS
SELECT ...;
```

| ALGORITHM | 동작 방식 | 언제 사용되는가? |
|-----------|----------|----------------|
| MERGE | View 정의를 원본 쿼리에 직접 합쳐서 실행한다 | 단순 SELECT, 조건/컬럼 필터링 |
| TEMPTABLE | 임시 테이블을 만들어 그 결과를 조회한다 | GROUP BY, DISTINCT, UNION 등 |
| UNDEFINED | MySQL이 자동으로 MERGE 또는 TEMPTABLE을 선택한다 | 기본값 (권장한다) |

> **입문자 핵심 요약:** 일반적으로 ALGORITHM은 신경 쓰지 않아도 된다. MySQL이 알아서 최적 방식을 선택하기 때문이다. GROUP BY나 집계가 포함된 View는 TEMPTABLE로 동작하며, 이 경우 Updatable이 불가하다. 성능 문제가 생겼을 때 ALGORITHM을 점검하는 수준으로 이해하면 충분하다.

---

### 3-4. 보안 관점에서의 View

View는 데이터베이스 접근 제어를 세밀하게 할 수 있는 강력한 보안 도구이다.

```sql
-- 시나리오: HR 팀은 employees 테이블 전체에 접근하면 안 된다

-- 1. 이름/부서만 노출하는 View를 생성한다
CREATE VIEW vw_emp_for_hr AS
SELECT id, name, dept, hire_date   -- salary, ssn 제외한다
FROM employees;

-- 2. HR 계정에 테이블 직접 접근을 차단하고 View만 허용한다
REVOKE ALL   ON mydb.employees    FROM 'hr_user'@'%';
GRANT SELECT ON mydb.vw_emp_for_hr TO  'hr_user'@'%';

-- 이제 hr_user는 employees 테이블을 직접 볼 수 없다
-- vw_emp_for_hr을 통해서만 데이터를 조회할 수 있다
```

---

### ✏️ 실습 3: Updatable View 확인 및 보안 View 설계

1. 단순 View와 GROUP BY View 각각에 UPDATE를 시도하고 결과를 비교한다
2. 민감 컬럼을 제외한 보안 View를 직접 설계한다
3. `WITH CHECK OPTION`이 있을 때와 없을 때 INSERT 동작 차이를 확인한다

---

## Part 4. 실전 활용 & 종합 실습

### 4-1. 실무 View 설계 패턴

#### 패턴 1: 최신 상태 조회 View

```sql
-- 각 고객의 가장 최근 주문만 보여주는 View
CREATE VIEW vw_latest_order AS
SELECT
    c.name  AS customer_name,
    o.order_id,
    o.order_date,
    o.status
FROM customers c
    JOIN orders o ON c.id = o.customer_id
    JOIN (
        SELECT customer_id, MAX(order_date) AS max_date
        FROM orders
        GROUP BY customer_id
    ) latest ON  o.customer_id = latest.customer_id
             AND o.order_date  = latest.max_date;
```

#### 패턴 2: 날짜 기반 동적 필터 View

```sql
-- 이번 달 주문 View (실행 시점 기준으로 동적으로 필터된다)
CREATE VIEW vw_this_month_orders AS
SELECT *
FROM orders
WHERE YEAR(order_date)  = YEAR(CURDATE())
  AND MONTH(order_date) = MONTH(CURDATE());

-- 호출할 때마다 "현재 날짜" 기준으로 동작한다
-- 1월에 실행하면 1월 데이터, 3월에 실행하면 3월 데이터를 반환한다
```

#### 패턴 3: 다단계 View (View 위의 View)

```sql
-- Step 1: 기본 JOIN View
CREATE VIEW vw_order_detail AS
SELECT
    o.order_id,
    c.name  AS cust_name,
    p.price,
    o.quantity,
    o.quantity * p.price AS total
FROM orders o
    JOIN customers c ON o.customer_id = c.id
    JOIN products  p ON o.product_id  = p.id;

-- Step 2: 위 View를 기반으로 집계 View를 만든다
CREATE VIEW vw_customer_revenue AS
SELECT
    cust_name,
    COUNT(*)   AS order_count,
    SUM(total) AS total_revenue
FROM vw_order_detail    -- ← View를 FROM에 사용한다
GROUP BY cust_name;

-- Step 3: 최종 사용
SELECT * FROM vw_customer_revenue
ORDER BY total_revenue DESC
LIMIT 10;
```

> **다단계 View 주의사항:** View를 여러 단계로 쌓으면 관리는 편하지만, 단계가 많아질수록 실행 시 쿼리가 복잡해져 성능이 저하될 수 있다. 3단계 이상은 신중하게 사용한다.

---

### 4-2. View 관련 유용한 시스템 쿼리

```sql
-- 현재 DB의 모든 View 목록 + 수정 가능 여부 확인
SELECT TABLE_NAME, IS_UPDATABLE, DEFINER
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = DATABASE();

-- 특정 View가 어떤 테이블을 참조하는지 확인
SELECT DISTINCT REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE
WHERE VIEW_NAME = 'vw_order_detail';

-- 특정 View의 컬럼 정보 조회
DESCRIBE vw_order_detail;
```

---

### 4-3. 종합 실습 — 미니 쇼핑몰 View 설계

**샘플 테이블 구조:**

```sql
customers (id, name, email, phone, grade)
products  (id, name, category, price, stock)
orders    (id, customer_id, product_id, quantity, status, order_date)
```

**5단계 실습 과제:**

| 단계 | 과제 | 필요한 개념 |
|------|------|------------|
| 1단계 | `vw_product_info`: 재고 10개 미만 상품만 노출하는 View를 만든다 | 단순 필터 View |
| 2단계 | `vw_order_summary`: orders + customers + products JOIN View를 만든다 | JOIN View |
| 3단계 | `vw_customer_stat`: 고객별 주문 횟수, 총 결제금액을 집계한다 | 집계 View |
| 4단계 | `vw_vip_customers`: vw_customer_stat 기반 VIP(총액 100만원↑) View를 만든다 | 다단계 View |
| 5단계 | WITH CHECK OPTION을 추가하고, 각 View의 수정 가능 여부를 점검한다 | CHECK OPTION |

**힌트:**

```sql
-- 1단계 힌트
CREATE VIEW vw_product_info AS
SELECT id, name, category, price, stock
FROM products
WHERE stock < 10;

-- 3단계 힌트 (vw_order_summary를 먼저 만들어야 한다)
CREATE VIEW vw_customer_stat AS
SELECT
    customer_name,
    COUNT(*)   AS order_count,
    SUM(???)   AS total_paid   -- 어떤 컬럼을 더해야 하는가?
FROM vw_order_summary
GROUP BY customer_name;
```

---

### 4-4. 핵심 정리

| 항목 | 핵심 내용 |
|------|----------|
| View란? | 저장된 SELECT 쿼리이다. 실제 데이터는 없는 가상 테이블이다 |
| CREATE | `CREATE [OR REPLACE] VIEW 이름 AS SELECT ...` |
| 수정/삭제 | `CREATE OR REPLACE VIEW` / `DROP VIEW IF EXISTS` |
| JOIN View | 복잡한 JOIN을 한 번 정의하고 어디서나 단순하게 재사용한다 |
| 집계 View | GROUP BY 포함 → Read-only이다. 수정이 불가능하다 |
| CHECK OPTION | INSERT/UPDATE 시 View 조건 위반을 자동으로 차단한다 |
| 보안 활용 | 민감 컬럼을 제외하고, 계정별로 View에만 권한을 부여한다 |
| 다단계 View | View의 FROM 절에 다른 View를 사용할 수 있다. 남용은 주의한다 |

---

### 다음 단계로 나아가기

- **Stored Procedure와 View 조합:** 프로시저 안에서 View를 활용한다
- **Materialized View 개념:** MySQL에는 없지만 PostgreSQL 등에서 지원한다. 성능 최적화 목적으로 사용한다
- **INFORMATION_SCHEMA 탐색:** View 메타데이터를 관리하는 방법을 익힌다
- **파티션 테이블 + View:** 대용량 데이터를 효율적으로 조회하는 패턴을 학습한다

---

*MySQL View 수업 자료 · SQL 입문자 과정*
