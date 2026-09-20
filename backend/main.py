from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from config import EXPORT_DIR, HOST, PORT
from services import ai_service, contest_store, file_store, todo_store

app = FastAPI(title="星助校园 API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/files", StaticFiles(directory=str(EXPORT_DIR)), name="files")


@app.get("/api/health")
def health():
    return {"status": "ok", "service": "星助校园"}


class NoteGenerateReq(BaseModel):
    content: str = ""
    pdf_base64: str | None = None


@app.post("/api/study/note_generate")
async def note_generate(req: NoteGenerateReq):
    result = await ai_service.generate_note(req.content, bool(req.pdf_base64))
    return {"result": result}


class ReviewPlanReq(BaseModel):
    subject: str
    remain_days: int = Field(alias="remain_days")
    weak_points: str = Field(default="", alias="weak_points")

    model_config = {"populate_by_name": True}


@app.post("/api/study/review_plan")
async def review_plan(req: ReviewPlanReq):
    result = await ai_service.generate_review_plan(
        req.subject, req.remain_days, req.weak_points
    )
    return {"result": result}


class ExportTxtReq(BaseModel):
    content: str
    filename: str = "export.txt"


@app.post("/api/export/txt")
def export_txt(req: ExportTxtReq):
    url = file_store.save_txt(req.content, req.filename)
    return {"download_url": url}


@app.get("/api/contest/card_list")
def contest_card_list():
    return {"items": contest_store.list_cards()}


class CreateCardReq(BaseModel):
    contest_name: str
    skills: str
    available_time: str
    teammate_expect: str
    contact: str | None = None


@app.post("/api/contest/create_card")
def create_card(req: CreateCardReq):
    card = contest_store.create_card(
        contest_name=req.contest_name,
        skills=req.skills,
        available_time=req.available_time,
        teammate_expect=req.teammate_expect,
        contact=req.contact or "",
    )
    return card


class MatchReq(BaseModel):
    card_a_id: str
    card_b_id: str


@app.post("/api/contest/match_analysis")
async def match_analysis(req: MatchReq):
    a = contest_store.get_card(req.card_a_id)
    b = contest_store.get_card(req.card_b_id)
    if not a or not b:
        return {"score": 0, "advantages": "", "risks": "卡片不存在", "suggestions": ""}
    return await ai_service.match_contest_cards(a, b)


class ResumePolishReq(BaseModel):
    resume_raw_text: str


@app.post("/api/document/resume_polish")
async def resume_polish(req: ResumePolishReq):
    polished = await ai_service.polish_resume(req.resume_raw_text)
    return {"polished_text": polished, "result": polished}


class ResumePdfReq(BaseModel):
    resume_raw_text: str


@app.post("/api/document/resume_pdf")
def resume_pdf(req: ResumePdfReq):
    url = file_store.save_pdf_from_text(req.resume_raw_text)
    return {"download_url": url}


class PlanGenerateReq(BaseModel):
    activity_name: str
    activity_desc: str = ""
    venue: str = ""
    budget: str = ""
    target_audience: str = ""


@app.post("/api/document/plan_generate")
async def plan_generate(req: PlanGenerateReq):
    result = await ai_service.generate_activity_plan(
        req.activity_name,
        req.activity_desc,
        req.venue,
        req.budget,
        req.target_audience,
    )
    return {"result": result}


@app.get("/api/todo/month")
def todo_month(year: int, month: int):
    return {"dates": todo_store.month_dates(year, month)}


@app.get("/api/todo/list")
def todo_list(date: str):
    return {"items": todo_store.list_by_date(date)}


class CreateTodoReq(BaseModel):
    title: str
    date: str
    due_time: str = ""
    note: str = ""
    category: str = "study"


@app.post("/api/todo/create")
def todo_create(req: CreateTodoReq):
    return todo_store.create_todo(
        title=req.title,
        date=req.date,
        due_time=req.due_time,
        note=req.note,
        category=req.category,
    )


class UpdateTodoReq(BaseModel):
    title: str | None = None
    due_time: str | None = None
    note: str | None = None
    completed: bool | None = None
    category: str | None = None
    date: str | None = None


@app.patch("/api/todo/{todo_id}")
def todo_update(todo_id: str, req: UpdateTodoReq):
    item = todo_store.update_todo(
        todo_id,
        title=req.title,
        due_time=req.due_time,
        note=req.note,
        completed=req.completed,
        category=req.category,
        date=req.date,
    )
    if not item:
        return {"error": "not_found"}
    return item


@app.delete("/api/todo/{todo_id}")
def todo_delete(todo_id: str):
    ok = todo_store.delete_todo(todo_id)
    return {"ok": ok}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
