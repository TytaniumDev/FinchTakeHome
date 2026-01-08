from server.database import Base, db_session_context
from sqlalchemy import Column, String
from typing import List, Optional


class User(Base):
    __tablename__ = 'users'

    id = Column(String, primary_key=True)
    name = Column(String)

    def copy(self) -> 'User':
        return User(id=self.id, name=self.name)

    def __str__(self) -> str:
        return f'User(id={self.id}, name={self.name})'

    def __repr__(self) -> str:
        return self.__str__()

    def to_json(self) -> dict:
        return {
            'id': self.id,
            'name': self.name
        }

    @classmethod
    def from_json(cls, json_data: dict) -> 'User':
        return cls(
            id=json_data.get('id'),
            name=json_data.get('name')
        )


def create_user(*, uid: str, name: str) -> User:
    with db_session_context() as session:
        user = User(id=uid, name=name)
        session.add(user)
        # Flush to ensure we get the ID
        session.flush()
        # Create a new detached instance with the data we need since
        # session will close.
        return user.copy()


def create_or_update_user(*, uid: str, name: str) -> User:
    with db_session_context() as session:
        user = session.query(User).filter(User.id == uid).first()
        if user is None:
            return create_user(uid=uid, name=name)
        user.name = name
        session.flush()
        return user.copy()


def get_user(id: str) -> Optional[User]:
    with db_session_context() as session:
        user = session.query(User).filter(User.id == id).first()
        if user is None:
            return None
        # Create a new detached instance with the data we need since
        # session will close.
        return user.copy()


def get_all_users() -> List[User]:
    with db_session_context() as session:
        return [user.copy() for user in session.query(User).all()]
