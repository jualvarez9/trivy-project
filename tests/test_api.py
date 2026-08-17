from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_status():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_create_task():
    response = client.post(
        "/tasks",
        json={
            "title": "Test task",
            "description": "Created by pytest",
            "priority": 1,
        },
    )

    assert response.status_code == 200
    assert response.json()["title"] == "Test task"