from flask import Blueprint, request

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    return {
        "message": "Register API working",
        "data": data
    }


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    return {
        "message": "Login API working",
        "data": data
    }
