import pytest
from flask import Flask
import json
from server.routes import bp
from server.model.user import create_or_update_user


@pytest.fixture
def app():
    """Create a Flask app for testing."""
    app = Flask(__name__)
    app.register_blueprint(bp)
    return app


@pytest.fixture
def client(app):
    """Create a test client for the app."""
    return app.test_client()


@pytest.fixture
def test_user(test_db):
    """Create a test user in the database."""
    user = create_or_update_user(uid="test_user_id", name="Test User")
    return user


def test_get_user_success(client, test_user):
    """Test getting a user that exists."""
    response = client.get(f'/user/get_user/{test_user.id}')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['success'] is True
    assert data['user']['id'] == test_user.id
    assert data['user']['name'] == test_user.name


def test_get_user_not_found(client):
    """Test getting a user that doesn't exist."""
    response = client.get('/user/get_user/nonexistent_user')
    assert response.status_code == 404
    data = json.loads(response.data)
    assert data['success'] is False
    assert data['error'] == 'User not found'


def test_create_or_update_user_success(client):
    """Test creating a new user."""
    user_data = {
        'id': 'new_user_id',
        'name': 'New User'
    }
    response = client.post(
        '/user/create_or_update_user',
        data=json.dumps(user_data),
        content_type='application/json'
    )
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['success'] is True
    assert data['user']['id'] == user_data['id']
    assert data['user']['name'] == user_data['name']


def test_update_existing_user(client, test_user):
    """Test updating an existing user."""
    updated_name = "Updated User Name"
    user_data = {
        'id': test_user.id,
        'name': updated_name
    }
    response = client.post(
        '/user/create_or_update_user',
        data=json.dumps(user_data),
        content_type='application/json'
    )
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['success'] is True
    assert data['user']['id'] == test_user.id
    assert data['user']['name'] == updated_name


def test_create_or_update_user_missing_fields(client):
    """Test creating a user with missing required fields."""
    # Missing name
    user_data = {
        'id': 'new_user_id'
    }
    response = client.post(
        '/user/create_or_update_user',
        data=json.dumps(user_data),
        content_type='application/json'
    )
    assert response.status_code == 404
    data = json.loads(response.data)
    assert data['success'] is False
    assert data['error'] == 'Missing required fields: id and name'

    # Missing id
    user_data = {
        'name': 'New User'
    }
    response = client.post(
        '/user/create_or_update_user',
        data=json.dumps(user_data),
        content_type='application/json'
    )
    assert response.status_code == 404
    data = json.loads(response.data)
    assert data['success'] is False
    assert data['error'] == 'Missing required fields: id and name'


def test_create_or_update_user_no_data(client):
    """Test creating a user with no data provided."""
    response = client.post(
        '/user/create_or_update_user',
        data='',
        content_type='application/json'
    )
    assert response.status_code == 400
    # The response is HTML, not JSON, so we don't try to parse it
    assert b'Bad Request' in response.data 