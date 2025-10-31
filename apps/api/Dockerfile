# apps/api/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy the API source (context is apps/api)
COPY . .

ENV PORT=8000
EXPOSE 8000

# IMPORTANT: run as a package module
# expects FastAPI app at apps/api/app/main.py -> app.main:app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
