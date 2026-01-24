# Using a slim version of the Python base image to keep the image small
FROM python:3.12-slim

# Set environment variables to optimize Python for Docker
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required for mysqlclient and patch vulnerabilities identified by Trivy (CVE-2025-13699 for mariadb)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    mariadb-common \    
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Patch vulnerabilities identified by Trivy (CVE-2025-8869 and CVE-2026-21441)
RUN pip install --no-cache-dir --upgrade pip==25.3 urllib3==2.6.3

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project code
COPY . .

# Expose Django's default port
EXPOSE 8000

# Start the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]