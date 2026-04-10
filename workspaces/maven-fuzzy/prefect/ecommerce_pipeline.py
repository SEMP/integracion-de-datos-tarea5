"""
Pipeline ELT para Maven Fuzzy Factory
MySQL -> Airbyte -> MotherDuck -> dbt
"""

import os
import subprocess
import time
from pathlib import Path
from typing import Optional
from dotenv import load_dotenv
import httpx
from prefect import flow, task, get_run_logger

# Cargar variables de entorno
load_dotenv()

# Configuración
AIRBYTE_HOST = os.getenv("AIRBYTE_HOST", "localhost")
AIRBYTE_PORT = int(os.getenv("AIRBYTE_PORT", 8000))
AIRBYTE_CONNECTION_ID = os.getenv("AIRBYTE_CONNECTION_ID")
AIRBYTE_USERNAME = os.getenv("AIRBYTE_USERNAME", "airbyte")
AIRBYTE_PASSWORD = os.getenv("AIRBYTE_PASSWORD", "password")
DBT_PROJECT_DIR = Path(__file__).parent.parent / "dbt_maven_fuzzy"
DBT_PROFILES_DIR = (
    DBT_PROJECT_DIR
    if (DBT_PROJECT_DIR / "profiles.yml").exists()
    else Path.home() / ".dbt"
)


def _run_dbt(commands: list[str]):
    """Ejecuta comandos dbt como subproceso, propagando las variables de entorno."""
    env = os.environ.copy()
    env["DBT_PROFILES_DIR"] = str(DBT_PROFILES_DIR)

    for cmd in commands:
        result = subprocess.run(
            cmd.split(),
            cwd=str(DBT_PROJECT_DIR),
            env=env,
            capture_output=False,
        )
        if result.returncode != 0:
            raise RuntimeError(f"Comando '{cmd}' falló con código {result.returncode}")


@task(name="Extract and Load with Airbyte", retries=2, retry_delay_seconds=60)
def extract_and_load():
    """Extrae datos de MySQL y carga en MotherDuck via Airbyte"""
    logger = get_run_logger()
    base_url = f"http://{AIRBYTE_HOST}:{AIRBYTE_PORT}/api/v1"

    logger.info(f"Iniciando sync de Airbyte para connection {AIRBYTE_CONNECTION_ID}")

    with httpx.Client(timeout=30, auth=(AIRBYTE_USERNAME, AIRBYTE_PASSWORD)) as client:
        response = client.post(
            f"{base_url}/connections/sync", json={"connectionId": AIRBYTE_CONNECTION_ID}
        )
        if response.status_code == 409:
            logger.warning("Ya hay un sync en curso, esperando que termine...")
            jobs_response = client.post(
                f"{base_url}/jobs/list",
                json={
                    "configTypes": ["sync"],
                    "configId": AIRBYTE_CONNECTION_ID,
                    "pagination": {"pageSize": 1},
                },
            )
            jobs_response.raise_for_status()
            job_id = jobs_response.json()["jobs"][0]["job"]["id"]
            logger.info(f"Job activo encontrado: {job_id}")
        else:
            response.raise_for_status()
            response_data = response.json()
            job_id = response_data["job"]["id"]
            logger.info(f"Job {job_id} iniciado")

        # Esperar a que el job termine
        while True:
            status_response = client.post(f"{base_url}/jobs/get", json={"id": job_id})
            status_response.raise_for_status()
            status = status_response.json()["job"]["status"]
            logger.info(f"Job {job_id} status: {status}")

            if status == "succeeded":
                logger.info("Sync completado exitosamente")
                return job_id
            elif status in ("failed", "cancelled"):
                raise RuntimeError(f"Airbyte job {job_id} terminó con status: {status}")

            time.sleep(10)


@task(name="Transform with dbt")
def transform(select: str = None):
    """Ejecuta transformaciones dbt"""
    logger = get_run_logger()
    logger.info(f"Ejecutando dbt en {DBT_PROJECT_DIR}")

    commands = ["dbt deps"]
    commands.append(f"dbt run --select {select}" if select else "dbt run")

    _run_dbt(commands)


@task(name="Test with dbt")
def test_data(select: str = None):
    """Ejecuta tests de dbt"""
    logger = get_run_logger()
    logger.info("Ejecutando tests dbt")

    command = f"dbt test --select {select}" if select else "dbt test"
    _run_dbt([command])


@flow(name="Ecommerce ELT Pipeline")
def ecommerce_pipeline(
    run_extract: bool = True,
    run_transform: bool = True,
    run_tests: bool = True,
    dbt_select: Optional[str] = None,
):
    """
    Pipeline completo de ELT para Maven Fuzzy Factory

    Args:
        run_extract:   Si ejecutar extracción de Airbyte
        run_transform: Si ejecutar transformaciones dbt
        run_tests:     Si ejecutar tests de dbt
        dbt_select:    Selector de modelos dbt (ej: "staging", "marts")
    """
    logger = get_run_logger()
    logger.info("Iniciando pipeline ELT de Maven Fuzzy Factory")

    records_synced = 0

    if run_extract:
        records_synced = extract_and_load()

    if run_transform:
        transform(select=dbt_select)

    if run_tests:
        test_data(select=dbt_select)

    logger.info("Pipeline completado exitosamente!")
    return {"records_synced": records_synced, "status": "success"}


if __name__ == "__main__":
    ecommerce_pipeline()
