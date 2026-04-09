import pytest
from app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_index_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200

def test_index_has_message(client):
    response = client.get("/")
    data = response.get_json()
    assert "message" in data
    assert data["status"] == "healthy"

def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"
