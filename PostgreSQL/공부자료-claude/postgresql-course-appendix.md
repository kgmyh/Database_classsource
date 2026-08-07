# 부록

본문에서 다루지 못했거나, 필요할 때 찾아보는 편이 나은 내용을 모았습니다. 처음부터 끝까지 읽기보다 **필요할 때 찾아보는 참고 자료**로 활용하세요.

---

# 부록 A. 데이터 타입 레퍼런스

11장에서 자주 쓰는 타입만 다뤘습니다. 여기서는 전체를 정리합니다.

## A.1 숫자 타입

| 타입 | 별칭 | 크기 | 범위 / 정밀도 |
|---|---|---|---|
| `SMALLINT` | `INT2` | 2바이트 | -32,768 ~ 32,767 |
| `INTEGER` | `INT`, `INT4` | 4바이트 | 약 -21억 ~ 21억 |
| `BIGINT` | `INT8` | 8바이트 | 약 ±922경 |
| `NUMERIC(p, s)` | `DECIMAL` | 가변 | 소수점 이하 최대 16,383자리, **정확함** |
| `REAL` | `FLOAT4` | 4바이트 | 유효숫자 약 6자리 |
| `DOUBLE PRECISION` | `FLOAT8` | 8바이트 | 유효숫자 약 15자리 |
| `SMALLSERIAL` | `SERIAL2` | 2바이트 | 자동 증가 |
| `SERIAL` | `SERIAL4` | 4바이트 | 자동 증가 |
| `BIGSERIAL` | `SERIAL8` | 8바이트 | 자동 증가 |

`NUMERIC(10, 2)`는 **전체 10자리 중 소수점 이하 2자리**라는 뜻입니다. 즉 정수 부분은 8자리까지 가능합니다.

> **금액에는 반드시 `NUMERIC`을 쓰세요.** `REAL`이나 `DOUBLE PRECISION`은 이진 근사값을 저장하므로 `0.1 + 0.2`가 정확히 `0.3`이 되지 않습니다.

## A.2 문자 타입

| 타입 | 별칭 | 설명 |
|---|---|---|
| `VARCHAR(n)` | `CHARACTER VARYING(n)` | 최대 n글자, 가변 길이 |
| `CHAR(n)` | `CHARACTER(n)` | 정확히 n글자, 부족하면 공백으로 채움 |
| `TEXT` | — | 길이 제한 없음 |

PostgreSQL에서는 세 타입의 **성능 차이가 거의 없습니다.** `VARCHAR(n)`은 길이 제한이 필요할 때, `TEXT`는 제한이 필요 없을 때 쓰면 됩니다. `CHAR`는 뒤에 공백이 붙으므로 특별한 이유가 없으면 피하세요.

## A.3 날짜와 시간 타입

| 타입 | 저장 범위 | 예 |
|---|---|---|
| `DATE` | 날짜만 | `2025-06-15` |
| `TIME` | 시각만 | `14:30:00` |
| `TIMETZ` | 시각 + 시간대 | `14:30:00+09` |
| `TIMESTAMP` | 날짜 + 시각 | `2025-06-15 14:30:00` |
| `TIMESTAMPTZ` | 날짜 + 시각 + 시간대 | 국제 서비스에 권장 |
| `INTERVAL` | 기간 | `1 year 2 mons 3 days` |

> **`TIMESTAMP`와 `TIMESTAMPTZ` 중 무엇을 쓸까**: 사용자가 여러 시간대에 있다면 `TIMESTAMPTZ`가 안전합니다. PostgreSQL이 내부적으로 UTC로 저장하고 조회 시 세션 시간대로 변환해 주기 때문입니다. 국내 서비스만 다룬다면 `TIMESTAMP`로도 충분합니다.

## A.4 그 밖의 타입

| 타입 | 설명 |
|---|---|
| `BOOLEAN` | `TRUE` / `FALSE` / `NULL`. `t`, `f`로 표시됨 |
| `UUID` | 128비트 고유 식별자 |
| `JSON` | JSON 텍스트를 그대로 저장 |
| `JSONB` | JSON을 이진 형태로 저장. **인덱스 가능, 더 빠름** |
| `ARRAY` | 배열. `INT[]`, `TEXT[]` 형태로 선언 |
| `BYTEA` | 이진 데이터 |
| `INET`, `CIDR` | IP 주소 |
| `POINT`, `POLYGON` | 기하 데이터 |

JSON을 저장한다면 대부분의 경우 `JSONB`가 정답입니다. `JSON`은 입력한 텍스트를 그대로 보관할 뿐이라 조회할 때마다 파싱해야 합니다.

## A.5 타입 선택 요령

| 저장할 것 | 권장 타입 |
|---|---|
| 금액, 비율 | `NUMERIC(전체, 소수)` |
| 수량, 나이, ID | `INTEGER` |
| 대용량 테이블의 ID | `BIGINT` / `BIGSERIAL` |
| 별점, 코드값 | `SMALLINT` |
| 이름, 이메일 | `VARCHAR(n)` |
| 게시글 본문, 리뷰 | `TEXT` |
| 생년월일, 주문일 | `DATE` |
| 로그 기록 시각 | `TIMESTAMPTZ` |
| 사용 여부, 삭제 여부 | `BOOLEAN` |

---

# 부록 B. 함수 레퍼런스

5장에서 핵심 함수만 다뤘습니다. 아래 예시의 결과는 모두 실제 실행 결과입니다.

## B.1 문자열 함수

| 함수 | 예 | 결과 |
|---|---|---|
| `LENGTH(문자열)` | `LENGTH('안녕 SQL')` | `6` |
| `UPPER(문자열)` | `UPPER('sql')` | `SQL` |
| `LOWER(문자열)` | `LOWER('SQL')` | `sql` |
| `INITCAP(문자열)` | `INITCAP('hello world')` | `Hello World` |
| `SUBSTRING(s FROM a FOR b)` | `SUBSTRING('PostgreSQL' FROM 1 FOR 4)` | `Post` |
| `LEFT(s, n)` | `LEFT('PostgreSQL', 4)` | `Post` |
| `RIGHT(s, n)` | `RIGHT('PostgreSQL', 3)` | `SQL` |
| `POSITION(a IN b)` | `POSITION('greSQL' IN 'PostgreSQL')` | `5` |
| `REPLACE(s, 찾을값, 바꿀값)` | `REPLACE('a-b-c', '-', '/')` | `a/b/c` |
| `SPLIT_PART(s, 구분자, n)` | `SPLIT_PART('a-b-c', '-', 2)` | `b` |
| `TRIM(s)` | `TRIM('  hi  ')` | `hi` |
| `LTRIM(s, 문자)` | `LTRIM('xxhi', 'x')` | `hi` |
| `RTRIM(s, 문자)` | `RTRIM('hixx', 'x')` | `hi` |
| `LPAD(s, 길이, 채울문자)` | `LPAD('7', 3, '0')` | `007` |
| `RPAD(s, 길이, 채울문자)` | `RPAD('7', 3, '0')` | `700` |
| `REPEAT(s, n)` | `REPEAT('ab', 3)` | `ababab` |
| `REVERSE(s)` | `REVERSE('SQL')` | `LQS` |
| `CONCAT(a, b, ...)` | `CONCAT('a', NULL, 'b')` | `ab` |
| `CONCAT_WS(구분자, ...)` | `CONCAT_WS('-', '2025', '06', '01')` | `2025-06-01` |
| `STARTS_WITH(s, 접두사)` | `STARTS_WITH('PostgreSQL', 'Post')` | `t` |
| `MD5(s)` | `MD5('abc')` | `900150983cd2...` |

`POSITION`은 찾지 못하면 `0`을 반환합니다. 문자 위치는 **1부터 시작**합니다.

## B.2 숫자 함수

| 함수 | 예 | 결과 |
|---|---|---|
| `ROUND(n [, 자릿수])` | `ROUND(3.567, 2)` | `3.57` |
| `TRUNC(n [, 자릿수])` | `TRUNC(3.567, 2)` | `3.56` |
| `CEIL(n)` | `CEIL(3.1)` | `4` |
| `FLOOR(n)` | `FLOOR(3.9)` | `3` |
| `ABS(n)` | `ABS(-7)` | `7` |
| `SIGN(n)` | `SIGN(-7)` | `-1` |
| `MOD(a, b)` | `MOD(10, 3)` | `1` |
| `POWER(a, b)` | `POWER(2, 8)` | `256` |
| `SQRT(n)` | `SQRT(16)` | `4` |
| `GREATEST(...)` | `GREATEST(3, 9, 5)` | `9` |
| `LEAST(...)` | `LEAST(3, 9, 5)` | `3` |
| `RANDOM()` | — | 0 이상 1 미만 난수 |

> `GREATEST`와 `LEAST`는 **한 행 안에서 여러 값을 비교**합니다. `MAX`, `MIN`이 여러 행을 비교하는 것과 다릅니다. NULL이 섞이면 무시하고 나머지 중에서 고릅니다.

## B.3 날짜/시간 함수

| 함수 | 예 | 결과 |
|---|---|---|
| `CURRENT_DATE` | — | 오늘 날짜 |
| `CURRENT_TIMESTAMP` | — | 현재 날짜와 시각 |
| `EXTRACT(단위 FROM 날짜)` | `EXTRACT(YEAR FROM DATE '2025-06-15')` | `2025` |
| | `EXTRACT(MONTH FROM ...)` | `6` |
| | `EXTRACT(DOW FROM ...)` | `0` (일요일) |
| | `EXTRACT(QUARTER FROM ...)` | `2` |
| `DATE_TRUNC(단위, 날짜)` | `DATE_TRUNC('month', DATE '2025-06-15')` | `2025-06-01` |
| | `DATE_TRUNC('year', ...)` | `2025-01-01` |
| `AGE(a, b)` | `AGE(DATE '2025-06-15', DATE '2024-01-01')` | `1 year 5 mons 14 days` |
| 날짜 + 정수 | `DATE '2025-06-15' + 3` | `2025-06-18` |
| 날짜 + `INTERVAL` | `DATE '2025-06-15' + INTERVAL '1 month'` | `2025-07-15 00:00:00` |
| 날짜 − 날짜 | `DATE '2025-07-01' - DATE '2024-01-15'` | `533` (일수) |

`EXTRACT`의 `DOW`는 **일요일이 0**, 토요일이 6입니다.

`DATE_TRUNC`에 쓸 수 있는 단위: `year`, `quarter`, `month`, `week`, `day`, `hour`, `minute`, `second`

## B.4 형변환과 서식

| 함수 | 예 | 결과 |
|---|---|---|
| `CAST(값 AS 타입)` | `CAST('123' AS INTEGER)` | `123` |
| `값::타입` | `'123'::INTEGER` | `123` |
| `TO_CHAR(날짜, 서식)` | `TO_CHAR(DATE '2025-06-15', 'YYYY-MM-DD')` | `2025-06-15` |
| | `TO_CHAR(DATE '2025-06-15', 'YYYY"년" MM"월"')` | `2025년 06월` |
| `TO_CHAR(숫자, 서식)` | `TO_CHAR(1234567.891, 'FM999,999,999.00')` | `1,234,567.89` |
| `TO_DATE(문자열, 서식)` | `TO_DATE('2025-06-01', 'YYYY-MM-DD')` | `2025-06-01` |
| `TO_NUMBER(문자열, 서식)` | `TO_NUMBER('1,234,567', '999,999,999')` | `1234567` |

**날짜 서식 기호**

| 기호 | 의미 | 기호 | 의미 |
|---|---|---|---|
| `YYYY` | 4자리 연도 | `HH24` | 24시간제 시 |
| `YY` | 2자리 연도 | `HH12` | 12시간제 시 |
| `MM` | 2자리 월 | `MI` | 분 |
| `DD` | 2자리 일 | `SS` | 초 |
| `Day` | 요일 이름 | `AM`/`PM` | 오전/오후 |

서식 안에 한글 등 리터럴 문자를 넣으려면 큰따옴표로 감쌉니다. `'YYYY"년"'`처럼요.

**숫자 서식 기호**

| 기호 | 의미 |
|---|---|
| `9` | 숫자 한 자리 (값이 없으면 공백) |
| `0` | 숫자 한 자리 (값이 없으면 0) |
| `,` | 천 단위 구분 |
| `.` | 소수점 |
| `FM` | 앞의 불필요한 공백 제거 |
| `%` | 퍼센트 기호 |

## B.5 조건과 NULL 처리

| 함수 | 예 | 결과 |
|---|---|---|
| `COALESCE(...)` | `COALESCE(NULL, NULL, '기본값')` | `기본값` |
| `NULLIF(a, b)` | `NULLIF(5, 5)` | `NULL` |
| | `NULLIF(5, 3)` | `5` |
| `CASE WHEN ... THEN ... END` | 5.8절 참고 | — |

## B.6 집계 함수

| 함수 | 설명 |
|---|---|
| `COUNT(*)` / `COUNT(컬럼)` | 행 개수 / NULL 아닌 값의 개수 |
| `SUM`, `AVG`, `MIN`, `MAX` | 합계, 평균, 최솟값, 최댓값 |
| `STRING_AGG(컬럼, 구분자)` | 문자열을 이어 붙임 |
| `ARRAY_AGG(컬럼)` | 배열로 모음 |
| `STDDEV`, `VARIANCE` | 표준편차, 분산 |

## B.7 윈도우 함수

| 함수 | 설명 |
|---|---|
| `ROW_NUMBER()` | 동점에도 다른 번호 |
| `RANK()` | 동점은 같은 순위, 다음은 건너뜀 |
| `DENSE_RANK()` | 동점은 같은 순위, 다음은 이어짐 |
| `NTILE(n)` | n개 그룹으로 분할 |
| `LAG(컬럼 [, n])` | n칸 앞 행의 값 |
| `LEAD(컬럼 [, n])` | n칸 뒤 행의 값 |
| `FIRST_VALUE`, `LAST_VALUE` | 창문의 첫 / 마지막 값 |
| `PERCENT_RANK()`, `CUME_DIST()` | 백분위 순위, 누적 분포 |

---

# 부록 C. 사용자 계정과 권한 관리

여러 사람이 같은 데이터베이스를 쓸 때, 누가 무엇을 할 수 있는지 통제하는 방법입니다. 실무 배포 단계에서 필요한 내용이므로 입문 학습 중에는 건너뛰어도 됩니다.

## C.1 역할이라는 개념

PostgreSQL에는 "사용자"와 "그룹"이 따로 없습니다. 둘 다 **역할**(**Role**)이라는 하나의 개념으로 다룹니다.

- 로그인 권한(`LOGIN`)이 있는 역할 = 우리가 흔히 말하는 **사용자**
- 로그인 권한이 없는 역할 = 권한을 묶어 두는 **그룹**

`CREATE USER`는 사실 `CREATE ROLE ... LOGIN`의 축약 표기입니다.

## C.2 역할 생성과 삭제

```sql
-- 로그인 가능한 사용자
CREATE ROLE study_analyst LOGIN PASSWORD 'temp1234';

-- 권한을 묶어 두는 그룹
CREATE ROLE study_readonly;
```

주요 옵션입니다.

| 옵션 | 의미 |
|---|---|
| `LOGIN` / `NOLOGIN` | 접속 가능 여부 |
| `PASSWORD '...'` | 비밀번호 설정 |
| `SUPERUSER` | 모든 권한 (매우 위험) |
| `CREATEDB` | 데이터베이스 생성 가능 |
| `CREATEROLE` | 다른 역할 생성 가능 |
| `VALID UNTIL '날짜'` | 계정 만료일 |

수정과 삭제는 이렇게 합니다.

```sql
ALTER ROLE study_analyst PASSWORD 'newpass5678';
ALTER ROLE study_analyst NOLOGIN;      -- 접속 차단
DROP ROLE study_analyst;
```

> **자주 하는 실수**: 권한이 남아 있는 역할은 삭제되지 않습니다.
> ```
> ERROR:  role "study_analyst" cannot be dropped because some objects depend on it
> DETAIL:  privileges for database postgres
> ```
> 먼저 `REVOKE`로 권한을 회수한 뒤 삭제해야 합니다.

역할 목록은 `\du`로 확인합니다.

## C.3 권한 부여 — GRANT

```
[문법]
GRANT 권한 ON 대상 TO 역할;
```

**접속 권한부터 필요합니다.**

```sql
GRANT CONNECT ON DATABASE shop_db TO study_analyst;
GRANT USAGE ON SCHEMA public TO study_readonly;
```

`USAGE ON SCHEMA`를 빠뜨리면 테이블 권한을 줘도 조회되지 않습니다. 스키마에 들어갈 수 없기 때문입니다. 입문자가 자주 막히는 지점입니다.

**테이블 권한**

```sql
GRANT SELECT ON products, categories TO study_readonly;
GRANT SELECT, INSERT, UPDATE ON orders TO study_analyst;
GRANT ALL PRIVILEGES ON orders TO study_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO study_readonly;
```

| 권한 | 허용되는 작업 |
|---|---|
| `SELECT` | 조회 |
| `INSERT` | 입력 |
| `UPDATE` | 수정 |
| `DELETE` | 삭제 |
| `TRUNCATE` | 전체 비우기 |
| `REFERENCES` | 외래키로 참조 |
| `ALL PRIVILEGES` | 위 전부 |

**컬럼 단위로도 줄 수 있습니다.**

```sql
GRANT SELECT (employee_name, department) ON employees TO study_readonly;
```

급여는 감추고 이름과 부서만 열어 주는 식입니다. 13장의 View를 이용한 방법과 함께 자주 쓰입니다.

## C.4 역할에 역할 부여하기

그룹 역할에 권한을 모아 두고, 사용자에게 그 그룹을 주는 방식이 관리하기 좋습니다.

```sql
GRANT study_readonly TO study_analyst;
```

이제 `study_analyst`는 `study_readonly`가 가진 모든 권한을 물려받습니다. 사람이 늘어나도 그룹만 부여하면 되고, 권한을 바꿀 때도 그룹 하나만 수정하면 됩니다.

## C.5 권한 회수 — REVOKE

```
[문법]
REVOKE 권한 ON 대상 FROM 역할;
```

```sql
REVOKE SELECT ON categories FROM study_readonly;
REVOKE ALL PRIVILEGES ON orders FROM study_analyst;
```

## C.6 권한 확인

```sql
SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'study_readonly'
ORDER BY table_name;
```

| grantee | table_name | privilege_type |
|---|---|---|
| study_readonly | products | SELECT |

psql에서는 `\dp 테이블명` 또는 `\z 테이블명`으로도 확인할 수 있습니다.

## C.7 실무 권장 사항

- **애플리케이션마다 전용 계정을 만드세요.** 모든 프로그램이 `postgres` 슈퍼유저로 접속하는 것은 위험합니다
- **필요한 최소 권한만 주세요.** 조회만 하는 대시보드에 `DELETE` 권한은 필요 없습니다
- **`SUPERUSER`는 관리 작업에만 쓰세요**
- **권한은 개별 사용자가 아니라 그룹 역할에 부여하세요.** 사람이 바뀌어도 관리가 쉬워집니다

---

# 부록 D. 인덱스 맛보기

## D.1 인덱스란

**인덱스**(**Index**)는 책의 색인과 같습니다. 색인이 없으면 특정 단어를 찾기 위해 첫 페이지부터 넘겨야 하지만, 색인이 있으면 곧바로 해당 페이지로 갈 수 있습니다.

데이터베이스도 마찬가지입니다. 인덱스가 없으면 **테이블 전체를 처음부터 끝까지 훑어야**(Sequential Scan) 하지만, 인덱스가 있으면 원하는 행으로 바로 접근합니다(Index Scan).

## D.2 효과 확인하기

20만 건짜리 테이블로 직접 비교해 봅시다.

```sql
CREATE TABLE study_big (id SERIAL PRIMARY KEY, code VARCHAR(20), val INT);
INSERT INTO study_big (code, val)
SELECT 'C' || g, g % 1000 FROM generate_series(1, 200000) g;
ANALYZE study_big;
```

> `generate_series(1, 200000)`은 1부터 200000까지의 숫자를 만들어 주는 함수입니다. 테스트 데이터를 대량으로 만들 때 유용합니다.

**인덱스가 없을 때**

```sql
EXPLAIN ANALYZE SELECT * FROM study_big WHERE code = 'C150000';
```
```
Seq Scan on study_big  (cost=0.00..3582.00 rows=1)
                       (actual time=10.727..14.461 rows=1 loops=1)
  Filter: ((code)::text = 'C150000'::text)
  Rows Removed by Filter: 199999
Execution Time: 14.474 ms
```

`Seq Scan`은 전체 훑기라는 뜻이고, `Rows Removed by Filter: 199999`는 **한 건을 찾으려고 199,999건을 버렸다**는 의미입니다.

**인덱스를 만든 뒤**

```sql
CREATE INDEX idx_study_big_code ON study_big(code);
ANALYZE study_big;
EXPLAIN ANALYZE SELECT * FROM study_big WHERE code = 'C150000';
```
```
Index Scan using idx_study_big_code on study_big  (cost=0.42..8.44 rows=1)
                                                  (actual time=0.060..0.061 rows=1 loops=1)
  Index Cond: ((code)::text = 'C150000'::text)
Execution Time: 0.174 ms
```

`Seq Scan`이 `Index Scan`으로 바뀌었고, 실행 시간이 **14.474ms에서 0.174ms로 약 80배 빨라졌습니다.** 데이터가 많을수록 격차는 더 커집니다.

## D.3 인덱스 만들기와 지우기

```sql
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_cust_date ON orders(customer_id, order_date);  -- 복합 인덱스
CREATE UNIQUE INDEX idx_customers_email ON customers(email);           -- 유일성까지 보장
DROP INDEX idx_products_category;
```

인덱스 목록은 `\di`로, 특정 테이블의 인덱스는 `\d 테이블명`으로 확인합니다.

> `PRIMARY KEY`와 `UNIQUE` 제약조건은 **인덱스를 자동으로 만듭니다.** 11장에서 `\d study_members`를 실행했을 때 `Indexes:` 항목에 나온 것이 그것입니다. 따로 만들 필요가 없습니다.

## D.4 인덱스의 대가

인덱스는 공짜가 아닙니다.

| 좋아지는 것 | 나빠지는 것 |
|---|---|
| `SELECT` 속도 | `INSERT`, `UPDATE`, `DELETE` 속도 |
| 정렬, JOIN 성능 | 저장 공간 사용량 |

데이터가 바뀔 때마다 인덱스도 함께 갱신해야 하기 때문입니다. **인덱스를 많이 만들수록 쓰기가 느려집니다.**

## D.5 어디에 만들어야 할까

**만들면 좋은 경우**

- `WHERE` 조건에 자주 쓰이는 컬럼
- JOIN의 연결 조건에 쓰이는 컬럼 (특히 외래키 컬럼)
- `ORDER BY`에 자주 쓰이는 컬럼

**만들어도 소용없거나 오히려 손해인 경우**

- 값의 종류가 몇 개뿐인 컬럼 (성별, 참/거짓 등)
- 행이 몇백 건뿐인 작은 테이블
- 자주 수정되는 컬럼
- 컬럼에 함수를 씌워 조회하는 경우 — `WHERE UPPER(email) = '...'`는 `email` 인덱스를 쓰지 못합니다. 이럴 때는 `CREATE INDEX ... ON customers(UPPER(email))`처럼 **함수 인덱스**를 만들어야 합니다

> **원칙**: 인덱스는 미리 잔뜩 만들어 두는 것이 아니라, **느린 쿼리를 발견한 뒤 `EXPLAIN`으로 확인하고 필요한 곳에 만드는 것**입니다.

---

# 부록 E. 백업과 복원

## E.1 pg_dump — 논리 백업

`pg_dump`는 데이터베이스의 내용을 **SQL 문장으로 뽑아내는** 도구입니다. psql 안에서 실행하는 명령이 아니라 **터미널에서 실행**합니다.

```bash
# 데이터베이스 전체를 SQL 파일로
pg_dump -U postgres -d shop_db -f shop_db_backup.sql

# 특정 테이블만
pg_dump -U postgres -d shop_db -t products -f products.sql

# 구조만 (데이터 제외)
pg_dump -U postgres -d shop_db --schema-only -f schema.sql

# 데이터만 (구조 제외)
pg_dump -U postgres -d shop_db --data-only -f data.sql
```

만들어진 파일을 열어 보면 `CREATE TABLE`과 `INSERT`(또는 `COPY`) 문이 들어 있습니다.

```sql
--
-- PostgreSQL database dump
--
CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name character varying(50) NOT NULL
);
...
```

2장에서 사용한 `shop_db_seed.sql`도 같은 성격의 파일입니다.

## E.2 복원

SQL 형식으로 백업했다면 `psql`로 실행하면 됩니다.

```bash
createdb -U postgres shop_db_restored
psql -U postgres -d shop_db_restored -f shop_db_backup.sql
```

## E.3 압축 형식

대용량이라면 압축 형식이 유리합니다. 이 형식은 `psql`이 아니라 `pg_restore`로 복원합니다.

```bash
# 백업 (커스텀 형식, 압축됨)
pg_dump -U postgres -d shop_db -Fc -f shop_db.dump

# 복원
pg_restore -U postgres -d shop_db_restored shop_db.dump

# 특정 테이블만 골라 복원
pg_restore -U postgres -d shop_db_restored -t products shop_db.dump
```

| 형식 | 옵션 | 복원 도구 | 특징 |
|---|---|---|---|
| 평문 SQL | (기본) | `psql` | 사람이 읽고 편집 가능 |
| 커스텀 | `-Fc` | `pg_restore` | 압축, 선택적 복원 가능 |
| 디렉터리 | `-Fd` | `pg_restore` | 병렬 백업/복원 가능 |

## E.4 서버 전체 백업

`pg_dump`는 데이터베이스 하나만 백업합니다. 역할과 권한을 포함한 **서버 전체**를 백업하려면 `pg_dumpall`을 씁니다.

```bash
pg_dumpall -U postgres -f all_databases.sql
psql -U postgres -f all_databases.sql
```

## E.5 실무에서 기억할 것

- **백업은 정기적으로, 자동으로.** 손으로 하는 백업은 결국 잊힙니다
- **복원을 실제로 해 보세요.** 복원해 본 적 없는 백업은 백업이 아닙니다
- **백업 파일은 다른 장비에 보관하세요.** 서버가 통째로 고장 나면 같은 서버의 백업도 함께 사라집니다
- **작업 전 백업.** 대량 `UPDATE`나 스키마 변경 전에는 반드시 백업을 남기세요. 12장의 트랜잭션은 세션 안에서만 되돌릴 수 있습니다

---

# 마치며

여기까지 오셨다면 SQL의 기본기는 모두 갖춘 것입니다. 지금까지 배운 것을 정리하면 이렇습니다.

| 무엇을 | 어디서 |
|---|---|
| 데이터 조회 | 4장 (SELECT, WHERE, ORDER BY) |
| 값 가공 | 5장 (스칼라 함수) |
| 요약 | 6장 (집계, GROUP BY) |
| 테이블 연결 | 7장 (JOIN), 8장 (집합 연산) |
| 단계적 계산 | 9장 (서브쿼리, CTE) |
| 행을 유지한 분석 | 10장 (윈도우 함수) |
| 구조 만들기 | 11장 (DDL) |
| 데이터 변경과 안전장치 | 12장 (DML, 트랜잭션) |
| 재사용 | 13장 (View) |

다음 단계로 나아가고 싶다면 이런 주제들이 기다리고 있습니다.

- **성능 튜닝** — `EXPLAIN` 읽는 법, 실행 계획 최적화
- **함수와 트리거** — PL/pgSQL로 데이터베이스 안에서 로직 실행
- **JSONB 활용** — 정형과 비정형 데이터를 함께 다루기
- **파티셔닝과 복제** — 대용량 운영
- **애플리케이션 연동** — Python, Java 등에서 PostgreSQL 사용하기

가장 좋은 학습법은 **직접 만들어 보는 것**입니다. 관심 있는 주제로 작은 데이터베이스를 설계하고, 필요한 질문을 SQL로 던져 보세요. 이 교재의 `shop_db`처럼 테이블 대여섯 개면 충분합니다.
