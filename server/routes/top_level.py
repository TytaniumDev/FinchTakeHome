from flask import Blueprint, jsonify
from server.routes.helpers import FlaskResponse

# Create the main routes blueprint
main_bp = Blueprint('main_routes', __name__)


@main_bp.route('/health', methods=['GET'])
def health_check() -> FlaskResponse:
    return jsonify({
        'status': 'healthy',
        'message': 'Server is running'
    })
