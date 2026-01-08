from contextlib import contextmanager
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from typing import Generator

# Create the engine and session factory
engine = create_engine('sqlite:///birdo.db')
_SessionLocal = sessionmaker(bind=engine)


@contextmanager
def db_session_context() -> Generator[Session, None, None]:
    """Returns a context manager to manage a database session."""
    session = _SessionLocal()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close() 