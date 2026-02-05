import pytest
from fastapi.testclient import TestClient
from health import app

@pytest.fixture
def client():
    return TestClient(app)

def test_health_check(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    
def test_get_users_empty(client):
    response = client.get("/users")
    
    assert response.status_code == 200
    assert response.json() == []
    
def test_create_user_success(client):
    response = client.post(
        "/users",
        json = {"name": "Alice"}
        )
    
    assert response.status_code == 200
    assert response.json()["name"] == "Alice"
    
def test_create_user_missing_name(client):
    response = client.post(
        "/users",
        json = {}
    )
        
    assert response.status_code == 400
    assert response.json()["detail"] == "name required"    
    
def test_create_user_null_body(client):
    response = client.post("/users")
    
    assert response.status_code == 422