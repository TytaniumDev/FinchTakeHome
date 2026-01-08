from flask import Blueprint
from server.routes.user import user_bp
from server.routes.top_level import main_bp

# Create the main blueprint
bp = Blueprint('main', __name__)

# Register the blueprints
bp.register_blueprint(user_bp, url_prefix='/user')
bp.register_blueprint(main_bp)
