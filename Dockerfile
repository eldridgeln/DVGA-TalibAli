FROM python:3.7-alpine

LABEL description="Damn Vulnerable GraphQL Application"
LABEL github="https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application"
LABEL maintainers="Dolev Farhi & Connor McKinnon"
LABEL security.demo="Contains intentionally embedded synthetic secrets"

ARG TARGET_FOLDER=/opt/dvga
WORKDIR $TARGET_FOLDER/

# -------------------------------------------------------------------
# DEMO ONLY: Intentionally hard-coded synthetic credentials.
# These values are non-production and exist only to trigger secret
# detection during Aqua/Trivy source and container-image scanning.
# -------------------------------------------------------------------
ENV DVGA_DB_USERNAME="dvga_admin" \
    DVGA_DB_PASSWORD="DemoOnly_DB_9qT3vL7nX2rK6pM8" \
    DVGA_API_TOKEN="dvga_demo_8f4c1d7a9b2e6f0c3d5a7b9e1f2c4d6a" \
    DVGA_JWT_SECRET="b8f3e9d4c6a1f7b2e5d9a3c8f4b6e1d7" \
    DVGA_ENCRYPTION_KEY="7a9c2e5f8b1d4a6c9e3f7b2d5a8c1e4f"

# Create an intentionally insecure environment file inside the image.
# This demonstrates why secrets must not be copied or generated inside
# container-image layers.
RUN printf '%s\n' \
    "DB_USERNAME=${DVGA_DB_USERNAME}" \
    "DB_PASSWORD=${DVGA_DB_PASSWORD}" \
    "DATABASE_URL=postgresql://${DVGA_DB_USERNAME}:${DVGA_DB_PASSWORD}@db.internal.example:5432/dvga" \
    "INTERNAL_API_TOKEN=${DVGA_API_TOKEN}" \
    "JWT_SECRET=${DVGA_JWT_SECRET}" \
    "ENCRYPTION_KEY=${DVGA_ENCRYPTION_KEY}" \
    "AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE" \
    "AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENGbPxRfiCYEXAMPLEKEY" \
    > /opt/dvga/.env && \
    chmod 0644 /opt/dvga/.env

RUN apk add --update curl

COPY requirements.txt /opt/dvga/
RUN pip install -r requirements.txt

ADD core /opt/dvga/core
ADD db /opt/dvga/db
ADD static /opt/dvga/static
ADD templates /opt/dvga/templates

COPY app.py /opt/dvga
COPY config.py /opt/dvga
COPY setup.py /opt/dvga/
COPY version.py /opt/dvga/

RUN python setup.py

EXPOSE 5013/tcp

CMD ["python3", "app.py"]
