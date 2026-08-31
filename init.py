import re
from datetime import datetime
## Markdowns im TXT:
## dreimal überschriften jeweils von h1 --> # bis h3 --> ###
## Trennlinie --> ---
## fett **text** , kursiv *text*
## `code` 
## -> Zitat mit blauem rand links
## - macht listen mit punkt als listenzeichen
## ; macht sortierte Listen mit Zahl als Listenzeichen

INPUT_FILE = "docs.txt"  
OUTPUT_FILE = "docs.html" 
TITLE = "Informatik Dokumentation | E-Phase"


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        :root {{
            --bg: #f8f9fa;
            --text: #212529;
            --header: #0d6efd;
            --code-bg: #f0f0f0;
            --border: #dee2e6;
        }}
        [data-theme="dark"] {{
            --bg: #121212;
            --text: #e0e0e0;
            --header: #6ea8fe;
            --code-bg: #2d2d2d;
            --border: #444;
        }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: var(--bg);
            color: var(--text);
            transition: background 0, color 0.3s;
        }}
        h1, h2, h3 {{
            color: var(--header);
            border-bottom: 2px solid var(--header);
            padding-bottom: 10px;
        }}
        pre {{
            background: var(--code-bg);
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            border-left: 4px solid var(--header);
        }}
        code {{
            font-family: 'Courier New', monospace;
            background: var(--code-bg);
            padding: 2px 5px;
            border-radius: 3px;
        }}
        .verzArray {{
            background: var(--code-bg);
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }}
        .verzArray a {{
            color: var(--header);
            text-decoration: none;
        }}
        .verzArray a:hover {{
            text-decoration: underline;
        }}
        .theme-toggle {{
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--code-bg);
            border: none;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
        }}
        .entry {{
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }}
        blockquote {{
            border-left: 4px solid var(--header);
            padding-left: 15px;
            margin-left: 0;
            color: var(--text);
            opacity: 0.8;
        }}
    </style>
</head>
<body>
    <menu>
        <a href="main.html">Startseite</a>
    </menu>
    <button class="theme-toggle" onclick="toggleTheme()">Theme wechseln</button>
    <h1>{title}</h1>
    <p><em>Autor: Alwin Thias | Generiert am {date}</em></p>

    <div class="verzArray">
        <h2>Inhaltsverzeichnis</h2>
        <ul>
            {verzArray}
        </ul>
    </div>

    {content}

    <script>
        function toggleTheme() {{
            const html = document.documentElement;
            const currentTheme = html.getAttribute('data-theme');
            html.setAttribute('data-theme', currentTheme === 'dark' ? 'light' : 'dark');
        }}
        // Lade letztes Theme
        if (localStorage.getItem('theme') === 'dark') {{
            document.documentElement.setAttribute('data-theme', 'dark');
        }}
        document.querySelector('.theme-toggle').addEventListener('click', () => {{
            const theme = document.documentElement.getAttribute('data-theme');
            localStorage.setItem('theme', theme);
        }});
    </script>
</body>
</html>
"""

def parse_markdown_to_html(text):
   
    # Code 
    text = re.sub(r'\'([^\']+)\'', r'<code>\1</code>', text)

    # Fett 
    text = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', text)

    # Kursiv (
    text = re.sub(r'\*(.*?)\*', r'<em>\1</em>', text)

    # Listen
    lines = text.splitlines()
    result = []
    in_list = False

    for line in lines:
        if re.match(r'^\s*-\s+', line):
            if not in_list:
                result.append('<ul>')
                in_list = True

            item = re.sub(r'^\s*-\s+', '', line)
            result.append(f'<li>{item}</li>')

        else:
            if in_list:
                result.append('</ul>')
                in_list = False

            result.append(line)

    if in_list:
        result.append('</ul>')

    text = '\n'.join(result)

    # Sortierte Listen
    lines = text.splitlines()
    result = []
    in_list = False

    for line in lines:
        if re.match(r'^\s*;\s+', line):
            if not in_list:
                result.append('<ol>')
                in_list = True

            item = re.sub(r'^\s*;\s+', '', line)
            result.append(f'<li>{item}</li>')

        else:
            if in_list:
                result.append('</ol>')
                in_list = False

            result.append(line)

    if in_list:
        result.append('</ol>')

    text = '\n'.join(result)

    # Überschriften
    text = re.sub(r'^#\s+(.*?)$', r'<h1>\1</h1>', text, flags=re.MULTILINE)
    text = re.sub(r'^##\s+(.*?)$', r'<h2>\1</h2>', text, flags=re.MULTILINE)
    text = re.sub(r'^###\s+(.*?)$', r'<h3>\1</h3>', text, flags=re.MULTILINE)

    # Trennlinien 
    text = re.sub(r'^\s*---\s*$', r'<hr>', text, flags=re.MULTILINE)

    # Blockquotes 
    text = re.sub(r'^->\s+(.*?)$', r'<blockquote>\1</blockquote>', text, flags=re.MULTILINE)

    return text

def genInhaltsverz(content):
    # erstellt inhaltsverzeichnuss mithilfe der überschriften
    verzArray = []
    # <h2> überschriften mit ## machen 
    headings = re.findall(r'<h2>(.*?)</h2>', content)
    for i, heading in enumerate(headings, 1):
        # Ersetze Leerzeichen für die ID
        heading_id = heading.lower().replace(' ', '-').replace('|', '').replace('.', '')
        verzArray.append(f'<li><a href="#{heading_id}">{heading}</a></li>')
        
        content = content.replace(
            f'<h2>{heading}</h2>',
            f'<h2 id="{heading_id}">{heading}</h2>',
            1
        )
    return '\n'.join(verzArray), content

def main():
    # Lese Input
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        text = f.read()

    # Parse HTML
    html_content = parse_markdown_to_html(text)

    # In Einträge aufteilen (getrennt durch ---)
    entries = re.split(r'<hr>', html_content)
    entries_html = []

    for entry in entries:
        entry = entry.strip()
        if not entry:
            continue
        # alles kommt in nen div
        entries_html.append(f'<div class="entry">{entry}</div>')

    full_content = '\n'.join(entries_html)

    # Inhaltsverzeichnis 
    verzArray, full_content_with_anchors = genInhaltsverz(full_content)
    full_content = full_content_with_anchors

    # HTML basteln
    html_output = HTML_TEMPLATE.format(
        title=TITLE,
        date=datetime.now().strftime("%d.%m.%Y"),
        verzArray=verzArray,
        content=full_content
    )

    # Speichere die Ausgabe
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(html_output)

    print(f"alles glatt gelaufen")

if __name__ == "__main__":
    main()