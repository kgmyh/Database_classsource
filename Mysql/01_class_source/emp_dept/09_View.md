# View란 무엇인가?
View는 일반적으로 SELECT 문을 저장해 두고, 조회 시 그 정의를 바탕으로 결과를 만들어 보여주는 가상 테이블이다. 
즉, 일반 테이블처럼 데이터를 별도로 저장하는 객체라기보다, 원본 테이블을 특정 방식으로 조회하기 위한 논리적 객체에 가깝다.
 
## View를 사용해야 하는 이유

### 1. 복잡한 쿼리의 반복 작성 문제

- 실무 데이터베이스는 수십 개의 테이블이 서로 연결되어 있다. 하나의 화면에 데이터를 보여주려면 여러 테이블을 JOIN하고, 집계하고, 조건을 거는 긴 쿼리가 필요하다. View를 사용하면 이런 복잡한 쿼리를 한 번만 정의해두고, 이후에는 간단한 SELECT 문으로 재사용할 수 있다.

**View 없이 매번 반복해야 하는 경우:**

```sql
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

**View로 한 번만 정의하여 재사용하는 경우:**

```sql
-- View 정의
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

-- View 조회
SELECT * FROM vw_completed_orders;
SELECT * FROM vw_completed_orders WHERE total_price > 50000;
SELECT customer_name, SUM(total_price) FROM vw_completed_orders GROUP BY customer_name;
```


### 2. 유지보수 비용 문제

소프트웨어는 언제나 변한다. 테이블에 컬럼이 추가되거나, 테이블 이름이 바뀌거나, 비즈니스 로직이 달라질 수 있다.  
같은 쿼리를 여러 곳에서 반복하면, 나중에 테이블 구조가 바뀔 때 모든 곳을 찾아서 수정해야 한다.    
View는 수정이 필요한 지점을 단 한 곳으로 줄여준다.

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


### 3. 보안 — 민감한 데이터 보호

데이터베이스에는 급여, 개인정보처럼 누구나 볼 수 있어서는 안 되는 민감한 데이터가 있다. (예를 들어 회사의 임원만 볼 수있는 데이터, 특정 부서만 볼 수 있고 다른 부서에게는 감춰져야 하는 데이터) View는 필요한 컬럼만 노출하는 방식으로 데이터 접근 범위를 제한할 수 있다.

```sql

-- HR 팀에게는 이름/부서/입사일만 보여주는 View를 만든다
CREATE VIEW vw_emp_for_hr AS
SELECT id, name, dept, hire_date   -- 다른 컬럼은 제외
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

-- 계정별 권한 설정
GRANT SELECT ON mydb.vw_emp_for_hr TO  'hr_user'@'%';
GRANT SELECT ON mydb.vw_emp_for_dev TO 'dev_leader'@'%';
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

### 기본 문법: CREATE VIEW

```sql
-- 기본 형태
CREATE VIEW 뷰_이름 
AS
SELECT 문

-- 실제 예시: 활성 고객만 보여주는 View
CREATE VIEW vw_active_customers AS
SELECT id, name, email
FROM customers
WHERE is_active = 1;
```

---

### View 조회 · 수정 · 삭제

```sql
-- View 목록 조회
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- View 정의 확인
SHOW CREATE VIEW vw_active_customers;

-- View 수정 
-- 1. CREATE OR REPLACE VIEW 사용
CREATE OR REPLACE VIEW vw_active_customers AS
SELECT id, name, email, phone    -- phone 컬럼 추가
FROM customers
WHERE is_active = 1;

-- View 수정
-- 2. ALTER VIEW 사용
ALTER VIEW vw_active_customers AS
SELECT id, name, email, phone    -- phone 컬럼 추가
FROM customers
WHERE is_active = 1;

-- View 삭제
DROP VIEW IF EXISTS vw_active_customers;

-- 여러 View 동시 삭제
DROP VIEW IF EXISTS vw_view1, vw_view2;
```

> `ALTER VIEW` 문법도 존재하지만, `CREATE OR REPLACE VIEW`가 더 많이 쓰인다. 존재하지 않는 View에 `ALTER VIEW`를 실행하면 오류가 발생하지만, `CREATE OR REPLACE VIEW`는 없으면 새로 만들고 있으면 교체한다.


### WITH CHECK OPTION

View를 통해 데이터를 INSERT/UPDATE할 때, View의 WHERE 조건을 위반하는 행을 막아주는 옵션이다.  
즉, View가 보여주기로 약속한 조건을 깨는 데이터가 View를 통해 들어오지 못하게 하는 장치이다.

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
VALUES ('김인사', 'HR', 48000);
-- ERROR 1369 (HY000): CHECK OPTION failed 'mydb.vw_it_dept'
```


## Updatable View

- 모든 View가 `UPDATE/INSERT/DELETE`를 지원하지는 않는다. 수정 가능 여부를 결정하는 조건을 이해한다.

| 조건 | 수정 가능 여부 | 이유 |
|------|---------------|------|
| 단일 테이블, 단순 SELECT | ✅ 수정 가능 | 원본 행과 1:1 매핑이 명확하다. |
| DISTINCT 포함 | ❌ 읽기 전용 | 원본 행을 특정할 수 없다 |
| GROUP BY / HAVING 포함 | ❌ 읽기 전용 | 집계 결과는 단일 행이 아니다 |
| UNION / UNION ALL 포함 | ❌ 읽기 전용 | 여러 쿼리의 합산 결과이다 |
| 서브쿼리 포함 | ❌ 읽기 전용 | 연산 결과라 원본 특정이 불가하다 |
| JOIN 포함 (단순) | △ 조건부 가능 | 1개 테이블 수정 가능하다 |

