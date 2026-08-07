import sqlite3
import pymysql
import sys

def get_sqlite_tables(sqlite_cursor):
    """SQLite 데이터베이스의 모든 테이블 목록을 반환합니다."""
    sqlite_cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = sqlite_cursor.fetchall()
    return [table[0] for table in tables if table[0] != 'sqlite_sequence']

def get_table_schema(sqlite_cursor, table_name):
    """SQLite 테이블의 스키마 정보를 반환합니다."""
    sqlite_cursor.execute(f"PRAGMA table_info({table_name});")
    return sqlite_cursor.fetchall()

def sqlite_type_to_mysql(sqlite_type):
    """SQLite 데이터 타입을 MySQL 데이터 타입으로 변환합니다."""
    sqlite_type = sqlite_type.upper()
    if 'INT' in sqlite_type:
        return 'INT'
    elif 'CHAR' in sqlite_type or 'TEXT' in sqlite_type or 'CLOB' in sqlite_type:
        return 'TEXT'
    elif 'REAL' in sqlite_type or 'FLOA' in sqlite_type or 'DOUB' in sqlite_type:
        return 'FLOAT'
    elif 'BLOB' in sqlite_type:
        return 'BLOB'
    elif 'DATE' in sqlite_type or 'TIME' in sqlite_type:
        return 'DATETIME'
    else:
        return 'TEXT'  # 기본값으로 TEXT 사용

def create_mysql_table(mysql_cursor, table_name, schema):
    """MySQL에 테이블을 생성합니다."""
    columns = []
    primary_keys = []
    
    for column in schema:
        col_id, col_name, col_type, not_null, default_value, is_pk = column
        
        mysql_type = sqlite_type_to_mysql(col_type)
        column_def = f"`{col_name}` {mysql_type}"
        
        if not_null:
            column_def += " NOT NULL"
        
        if default_value is not None:
            if isinstance(default_value, str):
                column_def += f" DEFAULT '{default_value}'"
            else:
                column_def += f" DEFAULT {default_value}"
        
        if is_pk:
            primary_keys.append(col_name)
            
        columns.append(column_def)
    
    # 기본 키 추가
    if primary_keys:
        columns.append(f"PRIMARY KEY ({', '.join([f'`{pk}`' for pk in primary_keys])})")
    
    create_query = f"CREATE TABLE IF NOT EXISTS `{table_name}` ({', '.join(columns)});"
    mysql_cursor.execute(create_query)

def copy_data(sqlite_cursor, mysql_cursor, table_name):
    """SQLite에서 MySQL로 데이터를 복사합니다."""
    # 테이블의 모든 데이터 가져오기
    sqlite_cursor.execute(f"SELECT * FROM {table_name};")
    rows = sqlite_cursor.fetchall()
    
    if not rows:
        print(f"테이블 '{table_name}'에 데이터가 없습니다.")
        return
    
    # 열 이름 가져오기
    sqlite_cursor.execute(f"PRAGMA table_info({table_name});")
    columns = [column[1] for column in sqlite_cursor.fetchall()]
    
    # MySQL에 데이터 삽입
    placeholders = ', '.join(['%s'] * len(columns))
    columns_str = ', '.join([f'`{col}`' for col in columns])
    
    insert_query = f"INSERT INTO `{table_name}` ({columns_str}) VALUES ({placeholders});"
    
    # 배치 처리로 데이터 삽입
    batch_size = 1000
    for i in range(0, len(rows), batch_size):
        batch = rows[i:i+batch_size]
        mysql_cursor.executemany(insert_query, batch)
    
    print(f"테이블 '{table_name}'에서 {len(rows)}개의 행이 복사되었습니다.")

def migrate_sqlite_to_mysql(sqlite_db_path, mysql_config):
    """SQLite 데이터베이스를 MySQL로 마이그레이션합니다."""
    try:
        # SQLite 연결
        sqlite_conn = sqlite3.connect(sqlite_db_path)
        sqlite_cursor = sqlite_conn.cursor()
        
        # MySQL 연결
        mysql_conn = pymysql.connect(
            host=mysql_config['host'],
            user=mysql_config['user'],
            password=mysql_config['password'],
            database=mysql_config['database'],
            charset='utf8mb4'
        )
        mysql_cursor = mysql_conn.cursor()
        
        # SQLite 테이블 목록 가져오기
        tables = get_sqlite_tables(sqlite_cursor)
        
        if not tables:
            print("마이그레이션할 테이블이 없습니다.")
            return
        
        print(f"마이그레이션할 테이블: {tables}")
        
        # 각 테이블마다 마이그레이션 수행
        for table in tables:
            print(f"\n테이블 '{table}' 마이그레이션 중...")
            
            # 테이블 스키마 가져오기
            schema = get_table_schema(sqlite_cursor, table)
            
            # MySQL에 테이블 생성
            create_mysql_table(mysql_cursor, table, schema)
            
            # 데이터 복사
            copy_data(sqlite_cursor, mysql_cursor, table)
        
        # 변경사항 커밋
        mysql_conn.commit()
        print("\n마이그레이션이 성공적으로 완료되었습니다.")
        
    except Exception as e:
        print(f"마이그레이션 중 오류 발생: {e}")
        if 'mysql_conn' in locals():
            mysql_conn.rollback()
    
    finally:
        # 연결 종료
        if 'sqlite_cursor' in locals():
            sqlite_cursor.close()
        if 'sqlite_conn' in locals():
            sqlite_conn.close()
        if 'mysql_cursor' in locals():
            mysql_cursor.close()
        if 'mysql_conn' in locals():
            mysql_conn.close()

if __name__ == "__main__":
    # MySQL 연결 정보
    mysql_config = {
        'host': 'localhost',
        'user': 'root',
        'password': '1111',
        'database': 'test'
    }
    
    # SQLite 데이터베이스 파일 경로
    sqlite_db_path = 'db.sqlite3'
    
    # 마이그레이션 실행
    migrate_sqlite_to_mysql(sqlite_db_path, mysql_config)
