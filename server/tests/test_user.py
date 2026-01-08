from server.model.user import (
    User, create_user, create_or_update_user, get_user, get_all_users
)


def test_create_user(test_db):
    """Test creating a new user."""
    # Create a user
    user = create_user(uid="test123", name="Test User")
    
    # Verify the user was created correctly
    assert user.id == "test123"
    assert user.name == "Test User"
    
    # Verify the user was saved to the database
    retrieved_user = get_user("test123")
    assert retrieved_user is not None
    assert retrieved_user.id == "test123"
    assert retrieved_user.name == "Test User"


def test_create_or_update_user_new(test_db):
    """Test creating a new user with create_or_update_user."""
    # Create a user
    user = create_or_update_user(uid="test123", name="Test User")
    
    # Verify the user was created correctly
    assert user.id == "test123"
    assert user.name == "Test User"
    
    # Verify the user was saved to the database
    retrieved_user = get_user("test123")
    assert retrieved_user is not None
    assert retrieved_user.id == "test123"
    assert retrieved_user.name == "Test User"


def test_create_or_update_user_existing(test_db):
    """Test updating an existing user with create_or_update_user."""
    # Create a user first
    create_user(uid="test123", name="Test User")
    
    # Update the user
    updated_user = create_or_update_user(uid="test123", name="Updated Name")
    
    # Verify the user was updated correctly
    assert updated_user.id == "test123"
    assert updated_user.name == "Updated Name"
    
    # Verify the user was updated in the database
    retrieved_user = get_user("test123")
    assert retrieved_user is not None
    assert retrieved_user.id == "test123"
    assert retrieved_user.name == "Updated Name"


def test_get_user_existing(test_db):
    """Test getting an existing user."""
    # Create a user first
    create_user(uid="test123", name="Test User")
    
    # Get the user
    user = get_user("test123")
    
    # Verify the user was retrieved correctly
    assert user is not None
    assert user.id == "test123"
    assert user.name == "Test User"


def test_get_user_nonexistent(test_db):
    """Test getting a nonexistent user."""
    # Try to get a user that doesn't exist
    user = get_user("nonexistent")
    
    # Verify None was returned
    assert user is None


def test_get_all_users(test_db):
    """Test getting all users."""
    # Create multiple users
    create_user(uid="test1", name="User 1")
    create_user(uid="test2", name="User 2")
    create_user(uid="test3", name="User 3")
    
    # Get all users
    users = get_all_users()
    
    # Verify all users were retrieved correctly
    assert len(users) == 3
    
    # Check that all users are in the list
    user_ids = [user.id for user in users]
    assert "test1" in user_ids
    assert "test2" in user_ids
    assert "test3" in user_ids


def test_user_to_json(test_db):
    """Test the to_json method of the User class."""
    # Create a user
    user = User(id="test123", name="Test User")
    
    # Convert to JSON
    json_data = user.to_json()
    
    # Verify the JSON data is correct
    assert json_data == {
        'id': "test123",
        'name': "Test User"
    }


def test_user_from_json(test_db):
    """Test the from_json method of the User class."""
    # Create JSON data
    json_data = {
        'id': "test123",
        'name': "Test User"
    }
    
    # Create a user from JSON
    user = User.from_json(json_data)
    
    # Verify the user was created correctly
    assert user.id == "test123"
    assert user.name == "Test User" 