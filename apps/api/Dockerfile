FROM python:3.11-slim
WORKDIR /app
# Ensure module imports work even if run as a script
ENV PYTHONPATH=/app

# Copy *only* API sources and its requirements
COPY apps/api/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY apps/api/ ./

ENV PORT=8000
CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
