import json
import uuid
from datetime import date, datetime
from pathlib import Path
from typing import Any

DATA_FILE = Path(__file__).resolve().parent.parent / "data" / "todos.json"
_todos: dict[str, dict[str, Any]] = {}
_initialized = False


def _init():
    global _todos, _initialized
    if _initialized:
        return
    _initialized = True
    if DATA_FILE.exists():
        try:
            _todos = json.loads(DATA_FILE.read_text(encoding="utf-8"))
        except Exception:
            _todos = {}
    if not _todos:
        _seed()


def _seed():
    today = date.today().isoformat()
    samples = [
        {
            "title": "完成高数第三章复习",
            "date": today,
            "due_time": "20:00",
            "note": "极限与连续",
            "category": "study",
        },
        {
            "title": "互联网+报名截止",
            "date": today,
            "due_time": "23:59",
            "note": "记得提交材料",
            "category": "contest",
        },
    ]
    for item in samples:
        todo_id = str(uuid.uuid4())[:8]
        _todos[todo_id] = {
            "id": todo_id,
            "title": item["title"],
            "date": item["date"],
            "due_time": item["due_time"],
            "note": item["note"],
            "completed": False,
            "category": item["category"],
            "created_at": datetime.now().isoformat(),
        }
    _save()


def _save():
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    DATA_FILE.write_text(json.dumps(_todos, ensure_ascii=False, indent=2), encoding="utf-8")


def list_by_date(target: str) -> list[dict[str, Any]]:
    _init()
    return [t for t in _todos.values() if t.get("date") == target]


def month_dates(year: int, month: int) -> list[str]:
    _init()
    prefix = f"{year:04d}-{month:02d}-"
    dates = {t.get("date") for t in _todos.values() if str(t.get("date", "")).startswith(prefix)}
    return sorted(d for d in dates if d)


def create_todo(
    title: str,
    date: str,
    due_time: str = "",
    note: str = "",
    category: str = "study",
) -> dict[str, Any]:
    _init()
    todo_id = str(uuid.uuid4())[:8]
    item = {
        "id": todo_id,
        "title": title,
        "date": date,
        "due_time": due_time,
        "note": note,
        "completed": False,
        "category": category,
        "created_at": datetime.now().isoformat(),
    }
    _todos[todo_id] = item
    _save()
    return item


def update_todo(todo_id: str, **fields) -> dict[str, Any] | None:
    _init()
    item = _todos.get(todo_id)
    if not item:
        return None
    for k, v in fields.items():
        if v is not None and k in ("title", "due_time", "note", "completed", "category", "date"):
            item[k] = v
    _save()
    return item


def delete_todo(todo_id: str) -> bool:
    _init()
    if todo_id in _todos:
        del _todos[todo_id]
        _save()
        return True
    return False
