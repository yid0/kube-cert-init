from kubernetes import client, config
from kubernetes.client.exceptions import ApiException
import os
import base64
import subprocess

config.load_incluster_config()
v1 = client.CoreV1Api()

NAMESPACE = os.getenv("NAMESPACE", "default")
SECRET_NAME = os.getenv("SECRET_NAME", "postgres")

VENV = os.getenv("VIRTUAL_ENV", "/app/venv")

CERT_PATH = f"{VENV}/certs"
CERT_FILE = f"{CERT_PATH}/{SECRET_NAME}.crt"
KEY_FILE = f"{CERT_PATH}/{SECRET_NAME}.key"

os.makedirs(CERT_PATH, exist_ok=True)

subprocess.run([
    "openssl", "req", "-new", "-x509", "-days", "365", "-nodes",
    "-out", CERT_FILE,
    "-keyout", KEY_FILE,
    "-subj", "/CN=localhost"
])


with open(CERT_FILE, "rb") as cert_file:
    cert_data = base64.b64encode(cert_file.read()).decode("utf-8")
with open(KEY_FILE, "rb") as key_file:
    key_data = base64.b64encode(key_file.read()).decode("utf-8")

secret = client.V1Secret(
    metadata=client.V1ObjectMeta(name=SECRET_NAME),
    data={
        "tls.crt": cert_data,
        "tls.key": key_data
    },
    type="kubernetes.io/tls"
)

try:
    v1.create_namespaced_secret(namespace=NAMESPACE, body=secret)
    print(f"Secret '{SECRET_NAME}' créé avec succès.")
except ApiException as e:
    if e.status == 409:
        print(f"Secret '{SECRET_NAME}' existe déjà, mise à jour en cours.")
        try:
            v1.replace_namespaced_secret(name=SECRET_NAME, namespace=NAMESPACE, body=secret)
            print(f"Secret '{SECRET_NAME}' mis à jour avec succès.")
        except ApiException as update_e:
            print(f"Erreur lors de la mise à jour du secret : {update_e}")
    else:
        print(f"Erreur lors de la création du secret : {e}")