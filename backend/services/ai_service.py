import re
import uuid
from datetime import datetime, timezone
from typing import Any

from config import USE_MOCK_AI, TELEAGENT_API_KEY, TELEAGENT_BASE_URL


async def _call_teleagent(skill: str, payload: dict[str, Any]) -> str | None:
    if not TELEAGENT_BASE_URL or USE_MOCK_AI:
        return None
    try:
        import httpx

        async with httpx.AsyncClient(timeout=120) as client:
            resp = await client.post(
                f"{TELEAGENT_BASE_URL.rstrip('/')}/invoke",
                json={"skill": skill, "input": payload},
                headers={"Authorization": f"Bearer {TELEAGENT_API_KEY}"},
            )
            resp.raise_for_status()
            data = resp.json()
            return data.get("output") or data.get("result")
    except Exception:
        return None


def _skill_tags(text: str) -> list[str]:
    keywords = ["Python", "AI", "产品设计", "UI设计", "数据分析", "Java", "前端", "商业分析"]
    found = [k for k in keywords if k.lower() in text.lower() or k in text]
    return found[:4] or ["综合技能"]


async def generate_note(content: str, has_pdf: bool) -> str:
    ai = await _call_teleagent("study_note", {"content": content, "has_pdf": has_pdf})
    if ai:
        return ai
    source = content.strip() or ("（已接收 PDF 课件，待 AI 深度解析）" if has_pdf else "")
    return f"""一、核心概念

{source[:200]}{'...' if len(source) > 200 else ''}

二、重点知识

1. 梳理课堂主线概念与定义
2. 标记老师强调的高频考点
3. 补充例题与易错点说明

三、考试高频考点

• 基础概念理解与辨析
• 典型题型解题步骤
• 与前后章节的知识关联

---
由星小助整理 · 演示模式（接入 TeleAgent 后将返回真实 AI 结果）"""


async def generate_review_plan(subject: str, remain_days: int, weak_points: str) -> str:
    ai = await _call_teleagent(
        "review_plan",
        {"subject": subject, "remain_days": remain_days, "weak_points": weak_points},
    )
    if ai:
        return ai
    points = [p.strip() for p in re.split(r"[\n,，、]", weak_points) if p.strip()]
    if not points:
        points = ["基础回顾", "重点强化", "综合练习"]
    lines = [f"【{subject}】{remain_days} 天专属复习计划\n"]
    per = max(1, remain_days // len(points))
    day = 1
    for i, pt in enumerate(points):
        end = min(day + per - 1, remain_days)
        lines.append(f"Day {day}–{end}\n{pt} · 概念梳理 + 基础题练习\n")
        day = end + 1
    while day <= remain_days:
        lines.append(f"Day {day}\n综合模拟 + 错题回顾\n")
        day += 1
    lines.append("\n建议：每天留 30 分钟复盘，周末做一次小结。")
    return "\n".join(lines)


async def polish_resume(text: str) -> str:
    ai = await _call_teleagent("resume_polish", {"text": text})
    if ai:
        return ai
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    polished = []
    for ln in lines:
        if len(ln) < 20 and not ln.endswith("："):
            polished.append(ln)
        else:
            polished.append(ln.replace("负责", "主导").replace("做了", "完成"))
    header = "【星小助润色版】\n\n"
    return header + "\n".join(polished)


async def generate_activity_plan(
    name: str, desc: str, venue: str, budget: str, audience: str
) -> str:
    ai = await _call_teleagent(
        "activity_plan",
        {
            "name": name,
            "desc": desc,
            "venue": venue,
            "budget": budget,
            "audience": audience,
        },
    )
    if ai:
        return ai
    return f"""{name}活动策划书

一、活动背景
{desc or '面向校园师生的特色活动，丰富课余生活。'}

二、活动目标
• 提升校园文化氛围
• 增强同学参与感与归属感

三、活动时间
建议周末 14:00–17:00（可根据校历调整）

四、活动地点
{venue or '待定'}

五、活动对象
{audience or '全校师生'}

六、活动流程
1. 签到入场（30min）
2. 主题环节（90min）
3. 互动与合影（30min）

七、人员分工
• 统筹 1 人 · 宣传 2 人 · 现场 3 人 · 后勤 2 人

八、宣传方案
公众号推文 + 班级群 + 校园海报

九、预算方案
{budget or '待定'}（含物料、场地、奖品）

十、风险预案
天气/人数不足/设备故障 → 备选室内方案与延期机制

---
由星小助生成 · 演示模式"""


async def match_contest_cards(card_a: dict, card_b: dict) -> dict:
    ai = await _call_teleagent("contest_match", {"card_a": card_a, "card_b": card_b})
    if ai and isinstance(ai, dict):
        return ai
    score = 72
    if card_a.get("skills") and card_b.get("skills"):
        overlap = set(card_a["skills"].split("/")) & set(card_b["skills"].split("/"))
        score = min(95, 68 + len(overlap) * 8)
    return {
        "score": score,
        "advantages": (
            f"• A 擅长 {card_a.get('skills', '')}，B 擅长 {card_b.get('skills', '')}\n"
            f"• 双方可投入时间：{card_a.get('available_time', '')} / {card_b.get('available_time', '')}\n"
            "• 技能组合有望覆盖竞赛核心需求"
        ),
        "risks": (
            "• 投入时间可能存在差异\n"
            "• 分工边界需提前明确\n"
            "• 沟通节奏需要磨合"
        ),
        "suggestions": (
            "建议赛前完成一次正式分工会议，"
            "明确负责人、里程碑与交付节点，并约定每周固定同步时间。"
        ),
    }


def infer_category(skills: str) -> str:
    s = skills.lower()
    if "python" in s or "java" in s or "编程" in skills:
        return "编程"
    if "ai" in s or "机器学习" in skills:
        return "AI"
    if "设计" in skills or "ui" in s:
        return "设计"
    if "商业" in skills:
        return "商业"
    if "科研" in skills:
        return "科研"
    return "其他"
