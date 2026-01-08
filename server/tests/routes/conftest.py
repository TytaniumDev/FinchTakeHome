import pytest
from flask import Flask
from server.routes import bp


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
