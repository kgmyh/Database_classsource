# 2장. PostgreSQL 설치와 실습 환경

## 학습 목표

- PostgreSQL을 설치하고 psql로 접속할 수 있다
- psql의 기본 메타 명령을 사용할 수 있다
- GUI 도구(pgAdmin 또는 DBeaver)로 데이터베이스에 접속할 수 있다
- 실습용 샘플 데이터베이스(`shop_db`)를 복원하고 첫 쿼리를 실행할 수 있다

---

## 2.1 PostgreSQL 설치

### Windows

1. [postgresql.org](https://www.postgresql.org/download/windows/) 공식 다운로드 페이지에서 Windows용 설치 파일을 받습니다. 이 교재는 **PostgreSQL 18 이상** 버전을 기준으로 합니다
2. 설치 마법사를 따라 진행하면서, 설치 항목 중 **pgAdmin 4**(GUI 도구)와 **Command Line Tools**(psql 포함)가 함께 체크되어 있는지 확인합니다
3. 설치 중 **superuser**(postgres 계정) 비밀번호를 설정하는 단계가 나옵니다. 이 비밀번호는 실습 내내 사용하므로 반드시 기억해 둡니다
4. 포트 번호는 기본값인 `5432`를 그대로 사용합니다
5. 설치가 끝나면 시작 메뉴에서 "SQL Shell (psql)"을 실행해 접속을 확인합니다

### macOS

Homebrew를 사용하는 방법이 가장 간단합니다.

```bash
brew install postgresql@18
brew services start postgresql@18
```

설치 후 아래 명령으로 접속을 확인합니다.

```bash
psql postgres
```

> **[참고]** Docker로 설치하기
> 운영체제에 상관없이 아래 명령 한 줄로 PostgreSQL을 컨테이너로 띄울 수도 있습니다. 이미 Docker에 익숙하다면 이 방법도 무방합니다.
> ```bash
> docker run --name pg-course -e POSTGRES_PASSWORD=mypassword -p 5432:5432 -d postgres:18
> ```

## 2.2 psql 접속과 기본 메타 명령

**psql**은 PostgreSQL이 기본으로 제공하는 명령줄(CLI) 클라이언트입니다. 아래 명령으로 접속합니다.

```bash
psql -U postgres -h localhost
```

- `-U postgres` : `postgres`라는 사용자로 접속
- `-h localhost` : 내 컴퓨터에서 실행 중인 서버에 접속

접속되면 `postgres=#` 프롬프트가 나타납니다. 여기서 사용하는 `\`(백슬래시)로 시작하는 명령을 **메타 명령**이라고 하며, SQL 문장이 아니라 psql 자체의 기능입니다.

| 명령 | 설명 |
|---|---|
| `\l` | 현재 서버의 데이터베이스 목록 보기 |
| `\c 데이터베이스명` | 다른 데이터베이스로 접속 전환 |
| `\dt` | 현재 데이터베이스의 테이블 목록 보기 |
| `\d 테이블명` | 테이블의 구조(컬럼, 타입, 제약조건) 보기 |
| `\du` | 사용자(role) 목록 보기 |
| `\x` | 조회 결과를 세로로 보기 (컬럼이 많을 때 유용) |
| `\?` | 메타 명령 도움말 |
| `\q` | psql 종료 |

> **자주 하는 실수**: 메타 명령 뒤에는 세미콜론(`;`)을 붙이지 않습니다. `\dt;`가 아니라 `\dt`입니다. 반면 SQL 문장은 반드시 세미콜론으로 끝나야 합니다.

## 2.3 GUI 도구 사용하기 — pgAdmin / DBeaver

명령줄이 익숙하지 않다면 GUI(그래픽) 도구를 사용할 수 있습니다.

- **pgAdmin 4**: PostgreSQL 공식 GUI 도구로, Windows 설치 시 함께 설치됩니다. 왼쪽 트리에서 서버 → 데이터베이스 → 테이블 순으로 탐색하고, "Query Tool"에서 SQL을 실행합니다
- **DBeaver**: PostgreSQL뿐 아니라 다양한 DBMS를 지원하는 무료 범용 도구입니다. [dbeaver.io](https://dbeaver.io)에서 Community 버전을 받을 수 있습니다

두 도구 모두 새 연결을 만들 때 아래 정보를 입력합니다.

| 항목 | 값 |
|---|---|
| Host | localhost |
| Port | 5432 |
| Username | postgres |
| Password | 설치 시 설정한 비밀번호 |

이 교재의 예제는 psql 기준으로 설명하지만, 같은 SQL 문장을 pgAdmin이나 DBeaver의 쿼리 창에 그대로 입력해도 동일하게 동작합니다.

## 2.4 데이터베이스와 스키마, search_path 개념

PostgreSQL 서버 하나에는 여러 개의 **데이터베이스**(**Database**)를 만들 수 있습니다. 각 데이터베이스는 완전히 독립된 공간이며, 한 데이터베이스의 테이블을 다른 데이터베이스에서 직접 조회할 수 없습니다. 지금까지 접속했던 `postgres`는 기본으로 만들어지는 관리용 데이터베이스입니다.

데이터베이스 안에는 다시 **스키마**(**Schema**)라는 하위 단위가 있습니다. 스키마는 테이블을 그룹으로 묶는 "폴더"와 비슷한 역할을 합니다. 특별히 지정하지 않으면 모든 테이블은 `public`이라는 기본 스키마에 만들어집니다. 이 교재에서는 스키마를 별도로 다루지 않고 기본값인 `public`만 사용합니다.

> **참고**: PostgreSQL이 테이블 이름을 찾을 때 어떤 스키마부터 확인할지 순서를 정한 것이 `search_path`입니다. 지금 단계에서는 "기본값을 그대로 쓰면 문제없다" 정도만 알아 두면 충분합니다.

## 2.5 실습용 샘플 데이터베이스 복원하기

이 교재의 모든 예제는 `shop_db`라는 온라인 쇼핑몰 샘플 데이터베이스를 기준으로 합니다. 아래 순서로 준비합니다.

**1단계. 데이터베이스 생성**

psql에서 `postgres` 계정으로 접속한 상태에서 실행합니다.

```sql
CREATE DATABASE shop_db;
```

**2단계. 접속 전환**

```
\c shop_db
```

**3단계. 스키마와 데이터 복원**

교재와 함께 제공되는 `shop_db_seed.sql` 파일을 실행합니다. 이 파일에는 테이블 생성(DDL)과 예제 데이터 입력(DML) 구문이 모두 들어 있습니다.

```bash
psql -U postgres -d shop_db -f shop_db_seed.sql
```

GUI 도구를 사용한다면 `shop_db_seed.sql` 파일을 열어 전체 내용을 복사한 뒤, Query Tool에 붙여넣고 실행하면 됩니다.

**4단계. 복원 확인**

```
\dt
```

`categories`, `products`, `customers`, `employees`, `orders`, `order_items`, `reviews` 7개의 테이블이 보이면 정상적으로 복원된 것입니다.

## 2.6 첫 번째 쿼리 실행해보기

모든 준비가 끝났다면, 아래 쿼리를 실행해 데이터가 잘 들어 있는지 확인합니다. `SELECT`의 자세한 문법은 4장에서 배우므로, 지금은 "실습 환경이 정상적으로 동작하는지" 확인하는 용도로만 실행해 봅니다.

```sql
SELECT * FROM products;
```

| product_id | product_name | category_id | price | stock_quantity | created_at |
|---|---|---|---|---|---|
| 1 | 무선 이어폰 | 2 | 89000.00 | 45 | 2026-08-07 |
| 2 | 블루투스 키보드 | 2 | 45000.00 | 20 | 2026-08-07 |
| ... | ... | ... | ... | ... | ... |

총 10개의 행이 조회되면 실습 환경 준비가 끝난 것입니다. (`created_at`은 데이터를 입력한 날짜로 표시되므로 실습 시점에 따라 달라질 수 있습니다.)

---

## 요약

- PostgreSQL은 Windows에서는 공식 설치 파일로, macOS에서는 Homebrew로 설치할 수 있으며 Docker로도 실행할 수 있다
- psql은 명령줄 클라이언트이며, `\dt`, `\d`, `\c` 같은 메타 명령으로 데이터베이스를 탐색한다
- pgAdmin, DBeaver 같은 GUI 도구로도 동일한 작업을 할 수 있다
- 하나의 서버에는 여러 데이터베이스가 있을 수 있고, 데이터베이스 안에는 스키마(기본값 `public`)가 있다
- 이 교재는 `shop_db`라는 샘플 데이터베이스를 기준으로 모든 예제를 설명한다

---

## 연습문제

**문제 1** (난이도: 하)
psql로 서버에 접속한 뒤, 현재 서버에 어떤 데이터베이스가 있는지 확인하는 메타 명령을 실행하세요.

**문제 2** (난이도: 하)
`shop_db`라는 이름의 데이터베이스를 생성하고, 그 데이터베이스로 접속을 전환하세요.

**문제 3** (난이도: 중)
`shop_db`에서 테이블 목록을 확인하고, `products` 테이블의 구조(컬럼명, 데이터 타입)를 확인하세요.

**문제 4** (난이도: 중)
pgAdmin 또는 DBeaver로 `shop_db`에 접속해서, GUI 화면에서 `customers` 테이블의 데이터를 확인하세요.

**문제 5** (난이도: 상)
`SELECT * FROM products;`를 실행하고, 결과가 몇 건 조회되는지 확인하세요. 만약 테이블이 없다는 오류가 발생한다면 어떤 단계를 다시 확인해야 할지 설명하세요.

---

## 정답 및 해설

**문제 1**
```
\l
```

**문제 2**
```sql
CREATE DATABASE shop_db;
```
```
\c shop_db
```

**문제 3**
```
\dt
\d products
```

**문제 4**
GUI 도구에서 새 연결(Host: localhost, Port: 5432, Username: postgres)을 만든 뒤, `shop_db` → `public` 스키마 → `customers` 테이블을 찾아 데이터를 확인합니다. (도구별로 메뉴 이름은 다를 수 있습니다.)

**문제 5**
정상적으로 복원되었다면 10건이 조회됩니다. "relation \"products\" does not exist" 같은 오류가 발생한다면, `shop_db_seed.sql`을 실행하지 않았거나, 다른 데이터베이스(예: `postgres`)에 접속한 상태에서 쿼리를 실행했을 가능성이 큽니다. `\c shop_db`로 올바른 데이터베이스에 접속되어 있는지 먼저 확인합니다.
