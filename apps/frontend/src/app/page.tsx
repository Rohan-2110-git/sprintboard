"use client";

import { useEffect, useState } from "react";

type Task = { id: number; title: string };

export default function Page() {
  const API = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8000";
  const [tasks, setTasks] = useState<Task[]>([]);
  const [title, setTitle] = useState("");
  const [loading, setLoading] = useState(false);

  async function load() {
    setLoading(true);
    try {
      const res = await fetch(`${API}/tasks`, { cache: "no-store" });
      const data = await res.json();
      setTasks(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  }

  async function createTask(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;
    const res = await fetch(`${API}/tasks`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title }),
    });
    if (res.ok) {
      setTitle("");
      load();
    } else {
      alert("Failed to create task");
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <main style={{ padding: 24, fontFamily: "system-ui, sans-serif" }}>
      <h1 style={{ marginBottom: 12 }}>SprintBoard – Tasks</h1>

      <form onSubmit={createTask} style={{ marginBottom: 16, display: "flex", gap: 8 }}>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Task title"
          style={{ padding: 8, border: "1px solid #ccc", borderRadius: 6, minWidth: 240 }}
        />
        <button type="submit" style={{ padding: "8px 12px", borderRadius: 6 }}>
          Add Task
        </button>
      </form>

      {loading ? <p>Loading…</p> : null}
      <ul style={{ paddingLeft: 18 }}>
        {tasks.map((t) => (
          <li key={t.id}>{t.title}</li>
        ))}
        {!loading && tasks.length === 0 ? <p>No tasks yet.</p> : null}
      </ul>
    </main>
  );
}
