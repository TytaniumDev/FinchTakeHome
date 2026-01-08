import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from server.database import Base
from contextlib import contextmanager

# Import all models to ensure they are registered with SQLAlchemy
import server.model.user  # noqa: F401


@pytest.fixture(scope="function", autouse=True)
def test_db():
    """Create an in-memory SQLite database for testing."""
    # Create an in-memory SQLite database
    engine = create_engine('sqlite:///:memory:', echo=True)
    
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    # Create a session factory
    SessionLocal = sessionmaker(bind=engine)
    
    # Define a test version of db_session_context
    @contextmanager
    def test_db_session_context():
        session = SessionLocal()
        try:
            yield session
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()
    
    # Monkey patch the db_session_context
    import server.model.user as user_module
    
    # Save original functions
    original_user_context = user_module.db_session_context
    
    # Replace with our test version
    user_module.db_session_context = test_db_session_context
    
    yield engine
    
    # Clean up
    Base.metadata.drop_all(engine)
    
    # Restore the original functions
    user_module.db_session_context = original_user_context