FROM python:3.12.3

WORKDIR /app
COPY . .

# Install system dependencies
RUN apt update && \
    apt install -y python3 python3-pip python3-venv pkg-config default-libmysqlclient-dev && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv venv

# Install Python dependencies
RUN ./venv/bin/pip install --upgrade pip && \
    ./venv/bin/pip install -r requirements.txt && \
    ./venv/bin/pip install django mysqlclient python-dotenv python-decouple djangorestframework django-cors-headers django-nested-admin openai && \
    cp .env.example .env && \
    ./venv/bin/python manage.py migrate

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
CMD ["./venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]