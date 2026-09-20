import uuid
from pathlib import Path

from fpdf import FPDF

from config import BASE_URL, EXPORT_DIR

_WIN_FONTS = [
    Path(r"C:\Windows\Fonts\simsun.ttc"),
    Path(r"C:\Windows\Fonts\msyh.ttc"),
    Path(r"C:\Windows\Fonts\simhei.ttf"),
]


def _file_url(filename: str) -> str:
    return f"{BASE_URL}/files/{filename}"


def save_txt(content: str, filename: str) -> str:
    safe = filename.replace("..", "").replace("/", "_").replace("\\", "_")
    if not safe.endswith(".txt"):
        safe += ".txt"
    unique = f"{uuid.uuid4().hex[:8]}_{safe}"
    path = EXPORT_DIR / unique
    path.write_text(content, encoding="utf-8")
    return _file_url(unique)


def _setup_pdf_font(pdf: FPDF) -> bool:
    for font_path in _WIN_FONTS:
        if font_path.exists():
            try:
                pdf.add_font("CJK", "", str(font_path))
                pdf.set_font("CJK", size=11)
                return True
            except Exception:
                continue
    pdf.set_font("Helvetica", size=11)
    return False


def save_pdf_from_text(content: str, title: str = "个人简历") -> str:
    unique = f"{uuid.uuid4().hex[:8]}_resume.pdf"
    path = EXPORT_DIR / unique
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    has_cjk = _setup_pdf_font(pdf)
    pdf.set_font_size(16)
    pdf.cell(0, 10, title if has_cjk else "Resume", ln=True)
    pdf.ln(4)
    pdf.set_font_size(11)
    for line in content.splitlines():
        text = line.strip()
        if text:
            try:
                pdf.multi_cell(0, 6, text)
            except Exception:
                pdf.multi_cell(0, 6, text.encode("ascii", "replace").decode())
        else:
            pdf.ln(3)
    pdf.output(str(path))
    return _file_url(unique)
