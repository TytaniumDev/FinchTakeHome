from flask import jsonify, Response
from typing import Dict, Any, Tuple, Union

# Type alias for Flask response types
FlaskResponse = Union[Response, Tuple[Response, int]]


def success_response(
    data: Dict[str, Any]
) -> FlaskResponse:
    """Create a success response with the given data."""
    return jsonify({
        'success': True,
        **data
    })


def failure_response(
    error_message: str
) -> FlaskResponse:
    """Create a failure response with the given error message."""
    return jsonify({
        'success': False,
        'error': error_message
    }), 404 