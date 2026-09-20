import uuid
from typing import Any

_cards: dict[str, dict[str, Any]] = {}


def _seed():
    if _cards:
        return
    samples = [
        {
            "contest_name": "全国大学生创新创业大赛",
            "skills": "Python / 数据分析 / 产品策划",
            "available_time": "每周 10～15 小时",
            "teammate_expect": "有责任心、执行力强",
            "contact": "",
            "category": "AI",
        },
        {
            "contest_name": "ACM 程序设计竞赛",
            "skills": "C++ / 算法 / 数据结构",
            "available_time": "每周 15 小时",
            "teammate_expect": "有竞赛经验、能抗压",
            "contact": "",
            "category": "编程",
        },
    ]
    for item in samples:
        create_card(**item)


def list_cards() -> list[dict[str, Any]]:
    _seed()
    return list(_cards.values())


def get_card(card_id: str) -> dict[str, Any] | None:
    return _cards.get(card_id)


def create_card(
    contest_name: str,
    skills: str,
    available_time: str,
    teammate_expect: str,
    contact: str = "",
    category: str = "",
) -> dict[str, Any]:
    from services.ai_service import _skill_tags, infer_category

    card_id = str(uuid.uuid4())[:8]
    card = {
        "id": card_id,
        "card_id": card_id,
        "contest_name": contest_name,
        "skills": skills,
        "skill_tags": _skill_tags(skills),
        "available_time": available_time,
        "teammate_expect": teammate_expect,
        "contact": contact or None,
        "category": category or infer_category(skills),
    }
    _cards[card_id] = card
    return card
