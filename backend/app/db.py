import contextlib
from typing import Any, Generator

import psycopg2
from psycopg2.extras import RealDictCursor

from app.config import settings


@contextlib.contextmanager
def get_conn() -> Generator[Any, None, None]:
    conn = psycopg2.connect(settings.database_url, cursor_factory=RealDictCursor)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
