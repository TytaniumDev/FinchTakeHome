from server.database import Base
from server.database.session import engine
from server.model import user  # noqa: F403, F401


def reset_database() -> None:
    """Drops any existing tables and recreates them using the latest schema."""
    # Import all models to ensure they are registered with
    # SQLAlchemy's metadata.
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)