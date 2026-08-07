# 12장. DML과 트랜잭션

## 학습 목표

- `INSERT`, `UPDATE`, `DELETE`로 데이터를 입력·수정·삭제할 수 있다
- `RETURNING`으로 변경된 행을 바로 확인할 수 있다
- 트랜잭션의 개념을 이해하고 `COMMIT`, `ROLLBACK`을 사용할 수 있다
- 실수로 데이터를 잘못 바꾸었을 때 되돌릴 수 있다
- 외래키가 있는 테이블의 입력·삭제 순서를 판단할 수 있다

---

## 12.0 실습 준비

11장과 마찬가지로 `study_` 접두사를 붙인 테이블로 실습합니다. 이번 장의 예제는 아래 테이블을 기준으로 합니다.

```sql
CREATE TABLE study_members (
    member_id   SERIAL PRIMARY KEY,
    member_name VARCHAR(50) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    grade       VARCHAR(10) NOT NULL DEFAULT '일반',
    points      INT NOT NULL DEFAULT 0,
    joined_at   DATE NOT NULL DEFAULT CURRENT_DATE
);
```

## 12.1 INSERT — 데이터 입력

```
[문법]
INSERT INTO 테이블명 (컬럼1, 컬럼2, ...)
VALUES (값1, 값2, ...);
```

**예제 12-1.** 회원 한 명을 등록합니다.

```sql
INSERT INTO study_members (member_name, email)
VALUES ('김철수', 'chulsoo@example.com');
```

```
INSERT 0 1
```

`grade`, `points`, `joined_at`은 입력하지 않았지만 11장에서 지정한 `DEFAULT` 값이 자동으로 채워집니다.

### 여러 행을 한 번에 입력하기

괄호를 쉼표로 이어 붙이면 됩니다.

**예제 12-2.** 회원 세 명을 한 번에 등록합니다.

```sql
INSERT INTO study_members (member_name, email, grade, points) VALUES
('이영희', 'younghee@example.com', 'VIP',  500),
('박민수', 'minsu@example.com',    '일반', 120),
('최지훈', 'jihoon@example.com',   '일반', 0);
```

| member_id | member_name | email | grade | points |
|---|---|---|---|---|
| 1 | 김철수 | chulsoo@example.com | 일반 | 0 |
| 2 | 이영희 | younghee@example.com | VIP | 500 |
| 3 | 박민수 | minsu@example.com | 일반 | 120 |
| 4 | 최지훈 | jihoon@example.com | 일반 | 0 |

한 줄씩 네 번 실행하는 것보다 훨씬 빠릅니다. 데이터베이스와 주고받는 횟수가 줄어들기 때문입니다.

> **자주 하는 실수**: 컬럼 목록을 생략하고 `INSERT INTO study_members VALUES (...)`라고 쓸 수도 있지만 권장하지 않습니다. **테이블에 정의된 순서 그대로** 모든 값을 넣어야 하고, 나중에 컬럼이 추가되면 기존 쿼리가 깨집니다. 컬럼 이름을 명시하세요.

### 조회 결과를 그대로 입력하기 — INSERT ... SELECT

`VALUES` 자리에 `SELECT`를 넣으면, 조회 결과가 그대로 입력됩니다. 데이터를 복사하거나 백업 테이블을 만들 때 씁니다.

**예제 12-3.** VIP 회원만 별도 로그 테이블에 복사합니다.

```sql
CREATE TABLE study_vip_log (
    member_id   INT,
    member_name VARCHAR(50),
    copied_at   DATE DEFAULT CURRENT_DATE
);

INSERT INTO study_vip_log (member_id, member_name)
SELECT member_id, member_name
FROM study_members
WHERE grade = 'VIP';
```

| member_id | member_name | copied_at |
|---|---|---|
| 2 | 이영희 | *(오늘 날짜)* |

4~10장에서 배운 모든 조회 기법을 여기에 쓸 수 있습니다. JOIN, 집계, 서브쿼리로 만든 결과도 그대로 입력할 수 있습니다.

### RETURNING — 입력한 행 바로 확인하기

`INSERT` 뒤에 `RETURNING`을 붙이면, 방금 입력된 행을 즉시 돌려받습니다. **자동 생성된 ID를 알아내는 표준적인 방법**입니다.

**예제 12-4.** 회원을 등록하면서 부여된 번호를 확인합니다.

```sql
INSERT INTO study_members (member_name, email)
VALUES ('정수진', 'sujin@example.com')
RETURNING member_id, member_name, joined_at;
```

| member_id | member_name | joined_at |
|---|---|---|
| 5 | 정수진 | *(오늘 날짜)* |

`RETURNING` 없이는 방금 넣은 행의 `member_id`를 알기 위해 다시 조회해야 합니다. `RETURNING`은 `UPDATE`와 `DELETE`에도 똑같이 쓸 수 있습니다.

## 12.2 UPDATE — 데이터 수정

```
[문법]
UPDATE 테이블명
SET 컬럼1 = 값1 [, 컬럼2 = 값2 ...]
[WHERE 조건];
```

**예제 12-5.** 1번 회원에게 포인트 100점을 추가합니다.

```sql
UPDATE study_members
SET points = points + 100
WHERE member_id = 1;
```

```
UPDATE 1
```

`points = points + 100`처럼 **현재 값을 이용한 계산**이 가능합니다. 오른쪽의 `points`는 수정 전의 값입니다.

**예제 12-6.** 포인트 100점 이상인 회원을 VIP로 승급시키고 보너스를 지급합니다.

```sql
UPDATE study_members
SET grade = 'VIP',
    points = points + 50
WHERE points >= 100
RETURNING member_id, member_name, grade, points;
```

| member_id | member_name | grade | points |
|---|---|---|---|
| 2 | 이영희 | VIP | 550 |
| 3 | 박민수 | VIP | 170 |
| 1 | 김철수 | VIP | 150 |

여러 컬럼은 쉼표로 나열합니다. `RETURNING`으로 실제로 어떤 회원이 승급했는지 바로 확인할 수 있습니다.

### WHERE를 빠뜨리면 전체가 바뀝니다

**이 장에서 가장 중요한 경고입니다.**

```sql
UPDATE study_members SET grade = '휴면';
```

```
UPDATE 5
```

`WHERE`가 없으므로 **모든 회원**의 등급이 "휴면"으로 바뀌었습니다. 경고도 확인 절차도 없습니다.

| member_id | member_name | grade |
|---|---|---|
| 1 | 김철수 | 휴면 |
| 2 | 이영희 | 휴면 |
| 3 | 박민수 | 휴면 |
| 4 | 최지훈 | 휴면 |
| 5 | 정수진 | 휴면 |

> **반드시 들여야 할 습관**: `UPDATE`나 `DELETE`를 쓰기 전에, **같은 `WHERE` 조건으로 먼저 `SELECT`를 실행**해서 대상이 맞는지 확인하세요.
> ```sql
> SELECT * FROM study_members WHERE points >= 100;   -- 먼저 확인
> UPDATE study_members SET grade = 'VIP' WHERE points >= 100;   -- 그 다음 실행
> ```
> 실행 후에는 `UPDATE 3`처럼 표시되는 **영향받은 행 수**가 예상과 맞는지 확인하는 것도 좋은 습관입니다.

## 12.3 DELETE — 데이터 삭제

```
[문법]
DELETE FROM 테이블명
[WHERE 조건];
```

**예제 12-7.** 포인트가 0인 회원을 삭제합니다.

```sql
DELETE FROM study_members
WHERE points = 0
RETURNING member_id, member_name;
```

| member_id | member_name |
|---|---|
| 4 | 최지훈 |
| 5 | 정수진 |

`UPDATE`와 마찬가지로 **`WHERE`를 빠뜨리면 모든 행이 삭제됩니다.** `DELETE FROM study_members;`는 테이블을 비웁니다.

### DELETE와 TRUNCATE 비교

11장에서 본 표를 다시 확인해 봅시다.

| | DELETE | TRUNCATE |
|---|---|---|
| 분류 | DML | DDL |
| 조건 지정 | `WHERE` 가능 | 불가 (항상 전체) |
| 속도 | 느림 (행마다 처리) | 매우 빠름 |
| `RETURNING` | 가능 | 불가 |
| 되돌리기 | 트랜잭션으로 가능 | 트랜잭션으로 가능 |

**일부만 지울 때는 `DELETE`, 전체를 비울 때는 `TRUNCATE`**가 기본 판단입니다.

## 12.4 UPSERT — 있으면 수정, 없으면 입력

"이미 있으면 수정하고, 없으면 새로 넣는" 동작이 자주 필요합니다. 이것을 **UPSERT**라고 하며, PostgreSQL에서는 `ON CONFLICT`로 구현합니다.

```
[문법]
INSERT INTO 테이블 (...) VALUES (...)
ON CONFLICT (충돌기준컬럼)
DO NOTHING | DO UPDATE SET 컬럼 = 값;
```

**예제 12-8.** 중복이면 아무것도 하지 않습니다.

```sql
INSERT INTO study_members (member_name, email, points)
VALUES ('김철수', 'chulsoo@example.com', 999)
ON CONFLICT (email) DO NOTHING;
```

```
INSERT 0 0
```

`email`이 이미 있으므로 아무 일도 일어나지 않았습니다. `ON CONFLICT`가 없었다면 `duplicate key value violates unique constraint` 오류가 났을 것입니다.

**예제 12-9.** 중복이면 기존 행을 수정합니다.

```sql
INSERT INTO study_members (member_name, email, points)
VALUES ('김철수', 'chulsoo@example.com', 999)
ON CONFLICT (email)
DO UPDATE SET points = EXCLUDED.points, grade = '갱신'
RETURNING member_id, member_name, points, grade;
```

| member_id | member_name | points | grade |
|---|---|---|---|
| 1 | 김철수 | 999 | 갱신 |

`EXCLUDED`는 **입력하려다 충돌한 값**을 가리키는 특별한 이름입니다. `EXCLUDED.points`는 위에서 넣으려 한 999입니다.

> `ON CONFLICT`의 충돌 기준 컬럼에는 `PRIMARY KEY`나 `UNIQUE` 제약조건이 있어야 합니다. 중복 판정 기준이 없으면 데이터베이스가 무엇을 "충돌"로 볼지 알 수 없기 때문입니다.

## 12.5 트랜잭션이란

### 왜 필요한가

계좌 이체를 생각해 봅시다. "A에서 20,000원을 빼고, B에 20,000원을 더한다"는 두 개의 `UPDATE`로 이루어집니다.

```sql
UPDATE study_accounts SET balance = balance - 20000 WHERE account_id = 1;
UPDATE study_accounts SET balance = balance + 20000 WHERE account_id = 2;
```

만약 첫 번째만 실행되고 두 번째 직전에 서버가 꺼진다면 어떻게 될까요? **20,000원이 그냥 사라집니다.**

**트랜잭션**(**Transaction**)은 여러 작업을 **하나의 덩어리**로 묶어, 전부 성공하거나 전부 취소되도록 보장합니다.

### ACID

트랜잭션이 보장하는 네 가지 성질입니다.

| 성질 | 의미 |
|---|---|
| **원자성**(**Atomicity**) | 전부 되거나 전부 안 되거나. 중간은 없음 |
| **일관성**(**Consistency**) | 제약조건 등 규칙이 항상 지켜짐 |
| **격리성**(**Isolation**) | 동시에 실행되는 다른 트랜잭션에 방해받지 않음 |
| **지속성**(**Durability**) | 커밋된 결과는 장애가 나도 남아 있음 |

용어를 외우기보다 **"이체 도중에 돈이 사라지지 않게 하는 장치"**로 이해하면 충분합니다.

## 12.6 BEGIN, COMMIT, ROLLBACK

| 명령 | 의미 |
|---|---|
| `BEGIN` | 트랜잭션 시작 |
| `COMMIT` | 지금까지의 변경을 **확정** |
| `ROLLBACK` | 지금까지의 변경을 **전부 취소** |

**예제 12-10.** 계좌 이체를 트랜잭션으로 묶습니다.

```sql
CREATE TABLE study_accounts (
    account_id SERIAL PRIMARY KEY,
    owner      VARCHAR(30),
    balance    INT NOT NULL CHECK (balance >= 0)
);
INSERT INTO study_accounts (owner, balance) VALUES ('김철수', 50000), ('이영희', 30000);

BEGIN;
UPDATE study_accounts SET balance = balance - 20000 WHERE account_id = 1;
UPDATE study_accounts SET balance = balance + 20000 WHERE account_id = 2;
COMMIT;
```

| account_id | owner | balance |
|---|---|---|
| 1 | 김철수 | 30000 |
| 2 | 이영희 | 50000 |

`COMMIT` 시점에 두 변경이 **동시에** 확정됩니다.

### 실수를 되돌리기

트랜잭션의 실질적인 가치는 여기에 있습니다.

**예제 12-11.** `WHERE`를 빠뜨린 실수를 취소합니다.

```sql
BEGIN;
UPDATE study_members SET grade = '일반';   -- 앗, WHERE를 빠뜨렸다
SELECT member_id, grade FROM study_members;  -- 확인해 보니 전부 바뀌었다
ROLLBACK;                                    -- 되돌린다
SELECT member_id, grade FROM study_members;  -- 원래대로 돌아왔다
```

`ROLLBACK` 후에는 변경 전 상태가 그대로 남아 있습니다. 위험한 `UPDATE`나 `DELETE`를 실행하기 전에 `BEGIN`을 먼저 치는 것만으로 대부분의 사고를 막을 수 있습니다.

### 트랜잭션 도중 오류가 나면

PostgreSQL의 중요한 특징입니다. 트랜잭션 안에서 **오류가 한 번 나면, 그 뒤의 모든 명령이 무시됩니다.**

```sql
BEGIN;
UPDATE study_members SET points = 999 WHERE member_id = 1;
INSERT INTO study_members (member_name, email) VALUES ('중복', 'chulsoo@example.com');
```
```
ERROR:  duplicate key value violates unique constraint "study_members_email_key"
```
```sql
SELECT member_id FROM study_members;
```
```
ERROR:  current transaction is aborted, commands ignored until end of transaction block
```

이 상태에서는 `SELECT`조차 실행되지 않습니다. **`COMMIT`을 쳐도 실제로는 `ROLLBACK`으로 처리**되어, 오류 전에 성공했던 `UPDATE`까지 함께 취소됩니다.

당황하지 말고 `ROLLBACK`을 실행해 트랜잭션을 정리한 뒤 다시 시작하면 됩니다.

### [참고] SAVEPOINT — 부분 취소

트랜잭션 안에 중간 저장 지점을 만들어, 거기까지만 되돌릴 수 있습니다.

```sql
BEGIN;
UPDATE study_accounts SET balance = balance + 1000 WHERE account_id = 1;
SAVEPOINT sp1;
UPDATE study_accounts SET balance = 0 WHERE account_id = 1;   -- 실수
ROLLBACK TO SAVEPOINT sp1;                                     -- 이 부분만 취소
COMMIT;                                                        -- 첫 UPDATE는 확정
```

첫 번째 `UPDATE`는 반영되고 두 번째만 취소됩니다. 긴 작업 중 일부만 되돌릴 때 유용합니다.

## 12.7 자동 커밋

여기까지 읽고 의문이 들 수 있습니다. 지금까지 `BEGIN` 없이 실행한 `INSERT`들은 어떻게 저장된 걸까요?

PostgreSQL은 기본적으로 **자동 커밋**(**autocommit**) 모드로 동작합니다. `BEGIN`을 명시하지 않으면 **각 SQL 문장이 그 자체로 하나의 트랜잭션**이 되어, 실행되는 즉시 자동으로 커밋됩니다.

```sql
UPDATE study_members SET grade = '휴면';   -- 실행 즉시 확정. ROLLBACK 불가
```

**즉, `BEGIN`을 치지 않은 상태에서 실행한 `UPDATE`나 `DELETE`는 되돌릴 수 없습니다.**

도구에 따라 동작이 다를 수 있으니 확인이 필요합니다.

| 도구 | 기본 동작 |
|---|---|
| psql | 자동 커밋 |
| pgAdmin | 자동 커밋 |
| DBeaver | 설정에 따라 다름 (수동 커밋 모드 선택 가능) |

DBeaver 같은 도구는 툴바에서 수동 커밋 모드로 전환할 수 있습니다. 수동 모드에서는 직접 커밋 버튼을 누르기 전까지 변경이 확정되지 않으므로, 중요한 작업을 할 때 안전합니다.

> **실무 원칙**: 중요한 데이터를 `UPDATE`하거나 `DELETE`할 때는 반드시 `BEGIN`으로 시작하세요. 결과를 `SELECT`로 확인한 뒤 `COMMIT` 또는 `ROLLBACK`을 결정하면 됩니다.

## 12.8 외래키가 있을 때의 입력·삭제 순서

11장에서 배운 `FOREIGN KEY`는 DML의 순서를 제약합니다.

```sql
CREATE TABLE study_orders (
    order_id  SERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES study_members(member_id),
    amount    INT NOT NULL
);
```

**입력은 부모 먼저.** 없는 회원의 주문은 넣을 수 없습니다.

```sql
INSERT INTO study_orders (member_id, amount) VALUES (99, 5000);
```
```
ERROR:  insert or update on table "study_orders" violates foreign key constraint
DETAIL:  Key (member_id)=(99) is not present in table "study_members".
```

**삭제는 자식 먼저.** 주문이 남아 있는 회원은 지울 수 없습니다.

```sql
DELETE FROM study_members WHERE member_id = 1;
```
```
ERROR:  update or delete on table "study_members" violates foreign key constraint
DETAIL:  Key (member_id)=(1) is still referenced from table "study_orders".
```

정리하면 이렇습니다.

| 작업 | 순서 |
|---|---|
| INSERT | 부모 → 자식 |
| DELETE | 자식 → 부모 |

11장 연습문제에서 `DROP TABLE`을 자식부터 지웠던 것과 같은 원리입니다. 여러 테이블을 함께 정리해야 한다면 **트랜잭션으로 묶어** 중간에 실패했을 때 전부 되돌아가게 하는 것이 안전합니다.

```sql
BEGIN;
DELETE FROM study_orders  WHERE member_id = 1;
DELETE FROM study_members WHERE member_id = 1;
COMMIT;
```

---

## 요약

- `INSERT`는 컬럼 이름을 명시해서 쓰고, 여러 행은 괄호를 쉼표로 이어 한 번에 넣는다
- `INSERT ... SELECT`로 조회 결과를 그대로 입력할 수 있다
- `RETURNING`은 변경된 행을 즉시 돌려주며, 자동 생성된 ID를 알아내는 표준 방법이다
- `UPDATE`와 `DELETE`에서 `WHERE`를 빠뜨리면 전체 행이 바뀌거나 지워진다. 같은 조건으로 먼저 `SELECT`해 보는 습관이 중요하다
- `ON CONFLICT`로 "있으면 수정, 없으면 입력"을 한 문장으로 처리할 수 있다
- 트랜잭션은 여러 작업을 하나로 묶어 전부 성공하거나 전부 취소되게 한다
- PostgreSQL은 기본이 자동 커밋이므로, `BEGIN` 없이 실행한 변경은 되돌릴 수 없다
- 트랜잭션 안에서 오류가 나면 이후 명령이 모두 무시되며, `COMMIT`을 해도 `ROLLBACK`으로 처리된다
- 외래키가 있으면 입력은 부모부터, 삭제는 자식부터 해야 한다

---

## 연습문제

`study_` 접두사를 붙인 테이블로 실습하세요.

**문제 1** (난이도: 하)
`study_members` 테이블에 회원 한 명을 등록하세요. 이름과 이메일만 지정하고, 나머지는 기본값이 들어가는지 확인하세요.

**문제 2** (난이도: 하)
회원 세 명을 한 번의 `INSERT`로 등록하세요.

**문제 3** (난이도: 중)
회원을 등록하면서 자동으로 부여된 `member_id`를 바로 확인하세요.

**문제 4** (난이도: 중)
2번 회원의 포인트를 200점 올리세요. 실행 전에 대상을 확인하는 `SELECT`를 먼저 작성하세요.

**문제 5** (난이도: 중)
포인트가 300점 이상인 회원의 등급을 'VIP'로 바꾸고, 변경된 회원을 `RETURNING`으로 확인하세요.

**문제 6** (난이도: 중)
포인트가 0인 회원을 삭제하세요.

**문제 7** (난이도: 상)
트랜잭션을 시작한 뒤 모든 회원의 등급을 '휴면'으로 바꾸고, 결과를 확인한 다음 되돌리세요.

**문제 8** (난이도: 상)
이미 등록된 이메일로 회원을 등록하되, 중복이면 포인트만 갱신되도록 작성하세요.

**문제 9** (난이도: 상)
`study_members`에서 등급이 'VIP'인 회원만 `study_vip_log` 테이블에 복사하세요.

**문제 10** (난이도: 상)
주문이 있는 회원을 삭제하려면 어떤 순서로 실행해야 하는지 설명하고, 트랜잭션으로 묶어 작성하세요.

---

## 정답 및 해설

**문제 1**
```sql
INSERT INTO study_members (member_name, email)
VALUES ('한지원', 'jiwon@example.com');

SELECT * FROM study_members WHERE email = 'jiwon@example.com';
```
`grade`는 '일반', `points`는 0, `joined_at`은 오늘 날짜가 자동으로 채워집니다.

**문제 2**
```sql
INSERT INTO study_members (member_name, email, points) VALUES
('강태영', 'taeyoung@example.com', 300),
('오세훈', 'sehun@example.com',    150),
('임하늘', 'haneul@example.com',   0);
```

**문제 3**
```sql
INSERT INTO study_members (member_name, email)
VALUES ('신동주', 'dongju@example.com')
RETURNING member_id;
```

**문제 4**
```sql
-- 1단계: 대상 확인
SELECT member_id, member_name, points FROM study_members WHERE member_id = 2;

-- 2단계: 실행
UPDATE study_members SET points = points + 200 WHERE member_id = 2;
```
`UPDATE 1`이 표시되어야 정상입니다. `UPDATE 5`처럼 나왔다면 `WHERE`를 빠뜨린 것이므로 즉시 `ROLLBACK`해야 합니다.

**문제 5**
```sql
UPDATE study_members
SET grade = 'VIP'
WHERE points >= 300
RETURNING member_id, member_name, points, grade;
```

**문제 6**
```sql
DELETE FROM study_members WHERE points = 0;
```
`WHERE`를 빠뜨리면 전체가 삭제되므로, 실행 전 `SELECT * FROM study_members WHERE points = 0;`으로 대상을 확인하세요.

**문제 7**
```sql
BEGIN;
UPDATE study_members SET grade = '휴면';
SELECT member_id, member_name, grade FROM study_members;
ROLLBACK;
SELECT member_id, member_name, grade FROM study_members;
```
`ROLLBACK` 후 조회하면 원래 등급이 그대로 남아 있습니다. `BEGIN`을 빠뜨렸다면 자동 커밋으로 즉시 확정되어 되돌릴 수 없습니다.

**문제 8**
```sql
INSERT INTO study_members (member_name, email, points)
VALUES ('한지원', 'jiwon@example.com', 777)
ON CONFLICT (email)
DO UPDATE SET points = EXCLUDED.points
RETURNING member_id, member_name, points;
```
`EXCLUDED.points`가 새로 넣으려던 777을 가리킵니다.

**문제 9**
```sql
INSERT INTO study_vip_log (member_id, member_name)
SELECT member_id, member_name
FROM study_members
WHERE grade = 'VIP';
```

**문제 10**

외래키 때문에 **자식 테이블의 행을 먼저 지워야** 합니다. 주문이 남아 있으면 회원 삭제가 거부되기 때문입니다.

```sql
BEGIN;
DELETE FROM study_orders  WHERE member_id = 1;
DELETE FROM study_members WHERE member_id = 1;
COMMIT;
```

트랜잭션으로 묶는 이유는, 첫 번째 `DELETE`만 성공하고 두 번째가 실패하면 **주문 기록만 사라지고 회원은 남는** 어중간한 상태가 되기 때문입니다. 트랜잭션 안에서는 둘 다 성공하거나 둘 다 취소됩니다.
