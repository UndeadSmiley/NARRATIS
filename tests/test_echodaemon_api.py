import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

# Ensure the project root is in the Python path so `echodaemon` can be imported
ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(ROOT_DIR))

import echodaemon

@pytest.fixture
def client():
    with TestClient(echodaemon.app) as c:
        yield c

def test_health_endpoint(client):
    resp = client.get('/health')
    assert resp.status_code == 200
    data = resp.json()
    assert data['status'] == 'alive'
    assert 'timestamp' in data

def test_hardware_endpoint(client):
    resp = client.get('/api/hardware')
    assert resp.status_code == 200
    data = resp.json()
    assert 'hardware' in data
    assert isinstance(data['hardware'], list)
    assert len(data['hardware']) > 0

def test_status_endpoint(client):
    resp = client.get('/api/status')
    assert resp.status_code == 200
    data = resp.json()
    for key in ['system_metrics', 'hardware', 'kernel_connected', 'active_connections', 'loaded_drivers']:
        assert key in data
