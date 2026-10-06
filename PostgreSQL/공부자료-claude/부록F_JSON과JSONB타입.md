## 부록 F. JSON과 JSONB 타입

### 학습 목표

- **JSON**(JavaScript Object Notation)과 **JSONB**(JSON Binary) 타입의 차이를 이해하고, 상황에 맞게 선택할 수 있다
- 테이블에 JSONB 컬럼을 추가하고 JSON 형식의 데이터를 입력할 수 있다
- `->`, `->>`, `#>`, `#>>` 연산자로 JSON 데이터의 특정 값을 조회할 수 있다
- `jsonb_set`, `jsonb_build_object` 등의 함수로 JSON 데이터를 수정하거나 생성할 수 있다
- JSONB 컬럼에 GIN 인덱스를 적용하면 조회 성능이 향상되는 이유를 설명할 수 있다

---

### 도입 — 왜 필요한가

`products` 테이블을 다시 살펴봅시다. 카테고리마다 상품이 가진 속성은 서로 다릅니다. 전자제품은 "색상"과 "무선충전 지원 여부"가 중요하고, 도서는 "저자"와 "쪽수"가 중요하며, 의류는 "사이즈"가 여러 개 존재합니다.

이런 속성을 모두 컬럼(Column)으로 만들면 어떻게 될까요? `color`, `author`, `page_count`, `size_s`, `size_m`... 카테고리가 늘어날 때마다 컬럼이 계속 추가되어야 하고, 대부분의 행에서는 자신과 관계없는 컬럼이 NULL로 남게 됩니다. 이런 식으로 상품마다 속성의 종류와 개수가 달라지는 데이터는 고정된 행(Row)·열(Column) 구조에 억지로 맞추기보다, **하나의 컬럼 안에 유연한 구조로 저장**하는 편이 자연스럽습니다. 이때 사용하는 것이 JSON과 JSONB 타입입니다.

11장에서 자주 사용하는 데이터 타입을 다루면서 JSON 계열 타입을 간단히 언급했습니다. 이 부록에서는 JSON과 JSONB를 실제로 어떻게 저장하고 조회하는지 `shop_db`를 통해 자세히 살펴봅니다.

---

### 개념 설명

#### JSON과 JSONB의 차이

PostgreSQL은 JSON 데이터를 저장하는 타입으로 `JSON`과 `JSONB` 두 가지를 제공합니다. 겉보기에는 같은 형식의 데이터를 담지만, 내부 저장 방식이 다릅니다.

| 항목 | **JSON** | **JSONB** |
|---|---|---|
| 저장 방식 | 입력한 텍스트를 그대로 저장 | 파싱하여 이진(Binary) 형태로 저장 |
| 처리 속도 | 조회할 때마다 다시 파싱 (느림) | 이미 분해된 상태라 빠름 |
| 공백·줄바꿈 | 원본 그대로 보존 | 보존하지 않음 |
| 키(Key) 순서 | 입력한 순서 유지 | 유지하지 않음 (내부적으로 재정렬) |
| 중복 키 | 모두 보존 | 마지막 값만 유지 |
| 인덱스 | 지원하지 않음 | GIN 인덱스 지원 |

다음 예시로 차이를 확인할 수 있습니다.

```sql
-- JSON은 원본 텍스트를 그대로 저장하므로 중복된 키가 모두 남습니다
SELECT '{"a":1, "a":2}'::json AS as_json;

-- JSONB는 파싱 과정에서 중복된 키 중 마지막 값만 남깁니다
SELECT '{"a":1, "a":2}'::jsonb AS as_jsonb;
```

| 표현식 | 결과 |
|---|---|
| `as_json` | `{"a":1, "a":2}` |
| `as_jsonb` | `{"a": 2}` |

**PostgreSQL 공식 문서**는 원본 텍스트를 그대로 보존해야 하는 특수한 경우가 아니라면 대부분의 상황에서 **JSONB**(JSON Binary) 사용을 권장합니다. 이 부록의 모든 예제도 JSONB를 기준으로 진행합니다.

#### 컬럼 추가 구문

```
[문법]
ALTER TABLE 테이블명
ADD COLUMN 컬럼명 JSONB;
```

#### 조회 연산자

JSONB 값에서 특정 키의 값을 꺼낼 때는 다음 연산자를 사용합니다.

```
[문법]
JSONB식 -> 키           -- 결과를 JSONB 타입으로 반환
JSONB식 ->> 키          -- 결과를 TEXT 타입으로 반환
JSONB식 #> 경로배열      -- 중첩된 경로를 따라가며 JSONB 타입으로 반환
JSONB식 #>> 경로배열     -- 중첩된 경로를 따라가며 TEXT 타입으로 반환
```

`->`는 결과를 JSON 형태(따옴표 포함) 그대로 반환하고, `->>`는 사람이 읽기 쉬운 TEXT로 변환하여 반환합니다. 값을 화면에 출력하거나 문자열과 비교할 때는 주로 `->>`를 사용합니다.

#### 포함 연산자

```
[문법]
JSONB식1 @> JSONB식2   -- JSONB식1이 JSONB식2의 내용을 포함하면 TRUE
```

> **[참고]** 특정 키나 배열 요소의 존재 여부만 확인할 때는 `?` 연산자(`JSONB식 ? 텍스트`)도 사용할 수 있습니다. 다만 일부 클라이언트 라이브러리에서는 `?`를 매개변수 자리표시자로 해석하므로 이스케이프가 필요할 수 있습니다.

---

### 예제

예제를 진행하기 전, `products` 테이블에 상품별 속성을 담을 `attributes` 컬럼을 추가합니다.

#### 예제 1 — attributes 컬럼 추가

```sql
-- products 테이블에 JSONB 타입의 attributes 컬럼 추가
ALTER TABLE products
ADD COLUMN attributes JSONB;
```

DDL 문이므로 결과 행을 반환하지 않습니다. `\d products`로 컬럼이 추가되었는지 확인할 수 있습니다.

#### 예제 2 — JSON 데이터 입력

```sql
-- 상품별로 서로 다른 구조의 속성 데이터 입력
UPDATE products SET attributes = '{"색상": "블랙", "무선충전": true, "재생시간_시간": 6}' WHERE product_id = 1;
UPDATE products SET attributes = '{"색상": "화이트", "연결방식": "블루투스 5.0", "키개수": 87}' WHERE product_id = 2;
UPDATE products SET attributes = '{"색상": "우드", "밝기_단계": 3}' WHERE product_id = 3;
UPDATE products SET attributes = '{"용량_ml": 350, "재질": "도자기"}' WHERE product_id = 4;
UPDATE products SET attributes = '{"원산지": "콜롬비아", "로스팅": "미디엄"}' WHERE product_id = 5;
UPDATE products SET attributes = '{"구성": ["아몬드", "캐슈넛", "호두"], "중량_g": 500}' WHERE product_id = 6;
UPDATE products SET attributes = '{"저자": "김민수", "쪽수": 320, "난이도": "입문"}' WHERE product_id = 7;
UPDATE products SET attributes = '{"저자": "이영희", "쪽수": 450, "난이도": "중급"}' WHERE product_id = 8;
UPDATE products SET attributes = '{"색상": "화이트", "사이즈": ["S", "M", "L", "XL"]}' WHERE product_id = 9;
UPDATE products SET attributes = '{"색상": "그레이", "사이즈": ["M", "L", "XL"], "소재": "면혼방"}' WHERE product_id = 10;
```

```sql
-- 입력된 결과 확인
SELECT product_id, product_name, attributes
FROM products
ORDER BY product_id;
```

| product_id | product_name | attributes |
|---|---|---|
| 1 | 무선 이어폰 | {"색상": "블랙", "무선충전": true, "재생시간_시간": 6} |
| 2 | 블루투스 키보드 | {"색상": "화이트", "연결방식": "블루투스 5.0", "키개수": 87} |
| 3 | 스탠드 조명 | {"색상": "우드", "밝기_단계": 3} |
| 4 | 머그컵 | {"용량_ml": 350, "재질": "도자기"} |
| ... | ... 외 6건 | ... |

#### 예제 3 — `->` 연산자로 값 조회

```sql
-- 전자제품 카테고리 상품의 색상 값을 JSONB 타입으로 조회
SELECT product_name, attributes -> '색상' AS color
FROM products
WHERE category_id = 2;
```

| product_name | color |
|---|---|
| 무선 이어폰 | "블랙" |
| 블루투스 키보드 | "화이트" |

`->` 연산자의 결과는 JSONB 타입이므로 문자열 값에 큰따옴표가 그대로 남아있는 것을 확인할 수 있습니다.

#### 예제 4 — `->>` 연산자로 값 조회

```sql
-- 전자제품 카테고리 상품의 색상 값을 TEXT 타입으로 조회
SELECT product_name, attributes ->> '색상' AS color
FROM products
WHERE category_id = 2;
```

| product_name | color |
|---|---|
| 무선 이어폰 | 블랙 |
| 블루투스 키보드 | 화이트 |

`->>`의 결과는 TEXT 타입이므로 큰따옴표 없이 값만 반환됩니다. `WHERE` 절에서 문자열과 비교하거나 화면에 표시할 때는 `->>`를 사용합니다.

#### 예제 5 — 배열 요소 접근

`사이즈`처럼 값이 배열인 경우, 경로 배열과 인덱스를 함께 지정하여 특정 요소에 접근할 수 있습니다.

```sql
-- 후드 집업의 사이즈 배열에서 첫 번째 요소(인덱스 0) 조회
SELECT product_name, attributes #> '{사이즈,0}' AS first_size
FROM products
WHERE product_id = 10;
```

| product_name | first_size |
|---|---|
| 후드 집업 | "M" |

배열의 인덱스는 0부터 시작하며, `#>>`를 사용하면 큰따옴표 없이 텍스트로 반환됩니다.

#### 예제 6 — `@>` 연산자로 조건 검색

```sql
-- 색상이 '화이트'인 상품 조회
SELECT product_name, attributes ->> '색상' AS color
FROM products
WHERE attributes @> '{"색상": "화이트"}';
```

| product_name | color |
|---|---|
| 블루투스 키보드 | 화이트 |
| 면 티셔츠 | 화이트 |

`@>` 연산자는 `attributes` 컬럼이 오른쪽에 제시한 JSON 구조를 포함하는지 확인합니다. `WHERE attributes ->> '색상' = '화이트'`와 결과는 같지만, `@>`는 GIN 인덱스를 활용할 수 있어 대량 데이터에서 더 유리합니다.

#### 예제 7 — `jsonb_set`으로 값 수정

```sql
-- 무선 이어폰의 재생시간_시간 값을 6에서 8로 수정
UPDATE products
SET attributes = jsonb_set(attributes, '{재생시간_시간}', '8')
WHERE product_id = 1;
```

```sql
-- 수정 결과 확인
SELECT product_name, attributes
FROM products
WHERE product_id = 1;
```

| product_name | attributes |
|---|---|
| 무선 이어폰 | {"색상": "블랙", "무선충전": true, "재생시간_시간": 8} |

`jsonb_set`의 두 번째 인자는 수정할 키의 경로를 나타내는 배열입니다. 중첩된 키를 수정할 때는 `'{상위키,하위키}'`처럼 경로를 나열합니다.

#### 예제 8 — `jsonb_build_object`로 JSON 생성

```sql
-- 기존 컬럼 값을 조합하여 즉석에서 JSON 객체 생성
SELECT jsonb_build_object('상품명', product_name, '가격', price) AS product_info
FROM products
WHERE product_id = 1;
```

| product_info |
|---|
| {"상품명": "무선 이어폰", "가격": 89000.00} |

`jsonb_build_object`는 테이블의 여러 컬럼 값을 하나의 JSON 응답으로 묶어야 할 때(API 응답 생성 등) 유용합니다.

> **[참고] GIN 인덱스**
> JSONB 컬럼에 `@>`, `?` 연산자로 조건 검색을 자주 한다면 GIN 인덱스를 생성하여 조회 속도를 높일 수 있습니다. (GIN 인덱스 자체에 대한 설명은 부록 D를 참고합니다.)
>
> ```sql
> -- attributes 컬럼에 GIN 인덱스 생성
> CREATE INDEX idx_products_attributes
> ON products
> USING GIN (attributes);
> ```

---

### 요약

- **JSON**은 원본 텍스트를 그대로, **JSONB**는 파싱된 이진 형태로 저장하며 대부분의 경우 JSONB를 사용합니다
- `->`는 JSONB, `->>`는 TEXT로 값을 반환하며, `#>` / `#>>`는 중첩된 경로를 조회할 때 사용합니다
- `@>` 연산자는 JSON 구조의 포함 여부를 확인하며, GIN 인덱스로 조회 성능을 높일 수 있습니다
- `jsonb_set`은 값 수정, `jsonb_build_object`는 JSON 생성에 사용합니다
- 상품마다 속성의 종류가 달라지는 데이터처럼 스키마가 유동적인 경우에 JSONB가 적합합니다

---

### 자주 하는 실수

- **작은따옴표 충돌**: JSON 문자열은 큰따옴표(`"`)를 사용해야 합니다. SQL 문자열 리터럴을 감싸는 작은따옴표(`'`)와 혼동하여 `'{'색상': '블랙'}'`처럼 작성하면 오류가 발생합니다.
- **`->`와 `->>` 혼동**: `WHERE attributes -> '색상' = '블랙'`처럼 JSONB 값과 TEXT 값을 직접 비교하면 항상 결과가 없습니다. `->>`로 TEXT로 변환한 뒤 비교해야 합니다.
- **인덱스 없이 대용량 검색**: 데이터가 많은 테이블에서 `@>`나 `?`로 반복 검색하면서 GIN 인덱스를 생성하지 않으면 순차 탐색으로 인해 성능이 크게 떨어집니다.
- **과도한 JSON 사용**: 모든 컬럼을 JSONB 하나에 몰아넣으면 제약조건(Constraint)을 걸 수 없고 조회도 복잡해집니다. 자주 조회·정렬하는 값은 일반 컬럼으로, 유동적인 부가 속성만 JSONB로 분리하는 것이 좋습니다.

---

### 연습문제

```
문제 1 (난이도: 하)
category_id가 1(도서)인 상품의 상품명과 attributes를 조회하세요.
```

```
문제 2 (난이도: 하)
전자제품(category_id = 2) 상품의 상품명과 색상 값을 TEXT 타입으로 조회하세요.
```

```
문제 3 (난이도: 중)
attributes에 무선충전 값이 true인 상품의 상품명을 조회하세요. (@> 연산자를 사용하세요)
```

```
문제 4 (난이도: 중)
사이즈 배열에 'L'이 포함된 상품의 상품명을 조회하세요. (@> 연산자를 사용하세요)
```

```
문제 5 (난이도: 중)
jsonb_set을 사용하여 product_id 2(블루투스 키보드)의 attributes에 보증기간_개월 값 12를 추가하는 UPDATE 문을 작성하세요.
```

```
문제 6 (난이도: 상)
attributes에 난이도 키가 존재하는 상품(도서)을 대상으로, 난이도별 상품 개수를 집계하는 쿼리를 작성하세요.
```

```
문제 7 (난이도: 상)
attributes 컬럼에 GIN 인덱스를 생성하는 쿼리를 작성하고, 이 인덱스가 어떤 연산자의 조회 속도를 높이는지 한 문장으로 설명하세요.
```

---

### 정답 및 해설

**문제 1 정답**
```sql
SELECT product_name, attributes
FROM products
WHERE category_id = 1;
```
`category_id = 1`(도서)인 SQL 첫걸음, 데이터베이스 개론 두 상품이 조회됩니다.

**문제 2 정답**
```sql
SELECT product_name, attributes ->> '색상' AS color
FROM products
WHERE category_id = 2;
```
`->>`는 결과를 TEXT 타입으로 반환하므로 큰따옴표 없이 값만 표시됩니다.

**문제 3 정답**
```sql
SELECT product_name
FROM products
WHERE attributes @> '{"무선충전": true}';
```
`@>` 연산자로 `attributes`가 `{"무선충전": true}` 구조를 포함하는 행만 걸러냅니다. 무선 이어폰이 조회됩니다.

**문제 4 정답**
```sql
SELECT product_name
FROM products
WHERE attributes @> '{"사이즈": ["L"]}';
```
`@>`는 배열에도 사용할 수 있으며, 우측 배열이 좌측 배열의 부분집합인지 확인합니다. 면 티셔츠, 후드 집업이 조회됩니다.

**문제 5 정답**
```sql
UPDATE products
SET attributes = jsonb_set(attributes, '{보증기간_개월}', '12')
WHERE product_id = 2;
```
경로 배열에 새 키 이름을 지정하면, 해당 키가 없을 경우 `jsonb_set`이 새로 추가합니다(네 번째 인자 기본값이 `true`이기 때문입니다).

**문제 6 정답**
```sql
SELECT attributes ->> '난이도' AS 난이도, COUNT(*) AS 상품수
FROM products
WHERE attributes ->> '난이도' IS NOT NULL
GROUP BY attributes ->> '난이도';
```
`난이도` 키가 없는 상품은 `->>` 결과가 NULL이므로 `WHERE` 절에서 제외됩니다. 입문 1건, 중급 1건으로 집계됩니다.

**문제 7 정답**
```sql
CREATE INDEX idx_products_attributes
ON products
USING GIN (attributes);
```
GIN 인덱스는 `@>`(포함), `?`(키 존재)처럼 JSONB 내부 구조를 검사하는 연산자의 조회 속도를 높여줍니다.
