from flask import Blueprint, request
from server.model.user import create_or_update_user, get_user
from server.routes.helpers import (
    FlaskResponse, success_response, failure_response
)

# Create the user blueprint
user_bp = Blueprint('user', __name__)


@user_bp.route('/get_user/<user_id>', methods=['GET'])
def get_user_handler(user_id: str) -> FlaskResponse:
    user = get_user(user_id)
    if user is None:
        return failure_response('User not found')
    return success_response({'user': user.to_json()})


@user_bp.route('/create_or_update_user', methods=['POST'])
def create_or_update_user_handler() -> FlaskResponse:
    data = request.get_json()
    if not data:
        return failure_response('No data provided')

    user_id = data.get('id')
    name = data.get('name')

    if not user_id or not name:
        return failure_response('Missing required fields: id and name')

    try:
        user = create_or_update_user(uid=user_id, name=name)
        return success_response({'user': user.to_json()})
    except Exception as e:
        return failure_response(str(e))