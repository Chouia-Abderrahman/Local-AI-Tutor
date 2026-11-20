"""Builds the test PDFs in test/fixtures/. Run: python3 tool/fixtures/make_fixture_pdfs.py

The text is written for these fixtures. textbook.pdf has bookmarks, running
headers and footers, a contents page and a references section.
textbook_no_outline.pdf has the same pages without bookmarks, so the importer
has to find headings from font sizes and numbering. scanned.pdf has only
images of text, for the text recognition (OCR) path.

Needs reportlab, Pillow and the Liberation fonts.
"""
import os

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import PageBreak, Paragraph, SimpleDocTemplate, Spacer

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "test", "fixtures")

CHAPTERS = [
    ("1 Cells", [
        ("1.1 Cell membranes", [
            "Every cell is surrounded by a membrane made of a double layer of "
            "phospholipids. Each phospholipid has a head that is attracted to "
            "water and two tails that avoid it, so in water the molecules line "
            "up tail to tail and form a stable sheet.",
            "Proteins embedded in the membrane act as channels, pumps and "
            "receptors. Because small uncharged molecules such as oxygen pass "
            "through the lipid layer while ions and large molecules need a "
            "protein to cross, the membrane is called selectively permeable.",
        ]),
        ("1.2 Osmosis", [
            "Osmosis is the movement of water across a selectively permeable "
            "membrane, from a region where water is more concentrated to a "
            "region where it is less concentrated. Water therefore moves "
            "toward the side with the higher concentration of dissolved "
            "particles, called solutes.",
            "A solution with a lower solute concentration than the cytoplasm "
            "is called hypotonic, and a cell placed in it swells as water "
            "flows in. Animal cells, which lack a cell wall, can burst. In a "
            "hypertonic solution water leaves the cell and it shrinks. When "
            "both sides have equal concentrations the solution is isotonic "
            "and there is no net movement of water.",
            "Plant cells resist bursting because their rigid cell wall pushes "
            "back against the swelling vacuole. This creates turgor pressure, "
            "which keeps stems and leaves firm. When a plant loses too much "
            "water, turgor pressure falls and the plant wilts.",
        ]),
    ]),
    ("2 Energy", [
        ("2.1 ATP", [
            "Adenosine triphosphate, or ATP, is the molecule cells use to "
            "store and transfer energy. Breaking the bond to its last "
            "phosphate group releases energy that the cell can use for work "
            "such as muscle contraction or active transport.",
            "Active transport moves substances against their concentration "
            "gradient and always requires energy, usually from ATP. The "
            "sodium-potassium pump, for example, uses one molecule of ATP to "
            "move three sodium ions out of the cell and two potassium ions in.",
        ]),
        ("2.2 Cellular respiration", [
            "Cellular respiration releases the energy stored in glucose and "
            "uses it to make ATP. It begins with glycolysis in the cytoplasm, "
            "which splits one glucose molecule into two molecules of pyruvate "
            "and produces a small amount of ATP.",
            "In the presence of oxygen, pyruvate enters the mitochondria, "
            "where the Krebs cycle and the electron transport chain produce "
            "most of the cell's ATP. Oxygen is the final electron acceptor of "
            "the chain and combines with hydrogen to form water.",
        ]),
    ]),
]


def build(path, with_outline):
    styles = getSampleStyleSheet()
    body = ParagraphStyle("body", parent=styles["BodyText"], fontName="Times-Roman", fontSize=11, leading=15, spaceAfter=8)
    h1 = ParagraphStyle("h1", parent=styles["Heading1"], fontName="Helvetica-Bold", fontSize=20, leading=24, spaceAfter=12)
    h2 = ParagraphStyle("h2", parent=styles["Heading2"], fontName="Helvetica-Bold", fontSize=14, leading=18, spaceAfter=6)
    toc = ParagraphStyle("toc", parent=body, spaceAfter=2)

    story = [
        Paragraph("Biology Basics", h1),
        Paragraph("A short introduction to cells and energy", body),
        Spacer(1, 2 * cm),
        Paragraph("Copyright 2026 Fixture Press. All rights reserved. ISBN 000-0-00-000000-0.", body),
        PageBreak(),
        Paragraph("Contents", h1),
    ]
    page = 3
    for chapter, sections in CHAPTERS:
        story.append(Paragraph(f"{chapter} " + "." * 60 + f" {page}", toc))
        for title, _ in sections:
            story.append(Paragraph(f"{title} " + "." * 55 + f" {page}", toc))
        page += 1
    story.append(PageBreak())

    for chapter, sections in CHAPTERS:
        story.append(Paragraph(chapter, h1))
        for title, paragraphs in sections:
            story.append(Paragraph(title, h2))
            story.extend(Paragraph(p, body) for p in paragraphs)
        story.append(PageBreak())

    story.append(Paragraph("References", h1))
    story.append(Paragraph("Smith, J. (2019). Membranes and transport. Journal of Cell Fixtures, 12(3), 45-67. doi:10.0000/fixture.1", body))
    story.append(Paragraph("Lee, K. et al. (2021). Energy in cells. Fixture Biology Review, 8, 101-130. https://example.org/energy", body))

    def on_page(canvas, doc):
        canvas.saveState()
        canvas.setFont("Helvetica", 8)
        canvas.drawString(2 * cm, A4[1] - 1.2 * cm, "Biology Basics - Fixture Press")
        canvas.drawRightString(A4[0] - 2 * cm, 1.2 * cm, str(doc.page))
        canvas.restoreState()

    class Doc(SimpleDocTemplate):
        def afterFlowable(self, flowable):
            if not with_outline or not isinstance(flowable, Paragraph):
                return
            style = flowable.style.name
            text = flowable.getPlainText()
            if style in ("h1", "h2") and text not in ("Biology Basics", "Contents"):
                key = f"k{id(flowable)}"
                self.canv.bookmarkPage(key)
                self.canv.addOutlineEntry(text, key, level=0 if style == "h1" else 1)

    Doc(path, pagesize=A4, title="Biology Basics", topMargin=2.2 * cm, bottomMargin=2.2 * cm).build(
        story, onFirstPage=on_page, onLaterPages=on_page
    )


def build_scanned(path):
    """A two-page PDF whose pages are only images of text, like a scan."""
    from PIL import Image, ImageDraw, ImageFont
    from reportlab.lib.utils import ImageReader
    from reportlab.pdfgen import canvas

    font_path = "/usr/share/fonts/liberation/LiberationSerif-Regular.ttf"
    title = ImageFont.truetype(font_path, 56)
    body = ImageFont.truetype(font_path, 36)
    pages = [
        ("Photosynthesis", [
            "Photosynthesis is the process by which plants use light",
            "energy to make glucose from carbon dioxide and water.",
            "It takes place in the chloroplasts of leaf cells.",
            "Oxygen is released as a by-product of the process.",
        ]),
        ("Chlorophyll", [
            "Chlorophyll is the green pigment that absorbs light.",
            "It absorbs mostly red and blue light and reflects green.",
        ]),
    ]
    c = canvas.Canvas(path, pagesize=A4)
    for heading, lines in pages:
        img = Image.new("RGB", (1240, 1754), "white")
        draw = ImageDraw.Draw(img)
        draw.text((120, 140), heading, font=title, fill="black")
        y = 260
        for line in lines:
            draw.text((120, y), line, font=body, fill="black")
            y += 60
        c.drawImage(ImageReader(img), 0, 0, width=A4[0], height=A4[1])
        c.showPage()
    c.save()



if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    build(os.path.join(OUT, "textbook.pdf"), with_outline=True)
    build(os.path.join(OUT, "textbook_no_outline.pdf"), with_outline=False)
    build_scanned(os.path.join(OUT, "scanned.pdf"))
    print("wrote", sorted(os.listdir(OUT)))
