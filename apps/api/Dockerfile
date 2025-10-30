FROM python:3.11-slim

# 1) Setup workdir
WORKDIR /app

# 2) Install deps (paths are RELATIVE to build context: ./apps/api)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3) Copy the app source
COPY . .

# 4) Run the API
ENV PORT=8000
CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
