from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text
from apps.db import SessionLocal
from models import Task

app = FastAPI(title="SprintBoard API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def root():
    return {"ok": True, "service": "api"}

@app.get("/healthz")
def health():
    return {"status": "ok"}

@app.get("/readyz")
def ready():
    return {"ready": True}

@app.get("/dbz")
def db_ping(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"db": "ok"}

@app.get("/tasks")
def list_tasks(db: Session = Depends(get_db)):
    return [{"id": t.id, "title": t.title} for t in db.query(Task).all()]

class TaskIn(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str | None = None

@app.post("/tasks", status_code=201)
def create_task(payload: TaskIn, db: Session = Depends(get_db)):
    t = Task(title=payload.title, description=payload.description)
    db.add(t)
    db.commit()
    db.refresh(t)
    return {"id": t.id, "title": t.title}
