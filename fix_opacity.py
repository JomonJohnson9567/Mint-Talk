import os
import re

lib_dir = r"d:\JOMON\Mint Talks\Project\mint-talk-frontend\mint_talk\lib"

def replacement(match):
    opacity_str = match.group(1).strip()
    try:
        opacity = float(opacity_str)
        alpha = round(opacity * 255)
        return f".withAlpha({alpha})"
    except ValueError:
        return f".withAlpha(({opacity_str} * 255).round())"

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = re.sub(r'\.withOpacity\(([^)]+)\)', replacement, content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for filename in files:
        if filename.endswith(".dart"):
            fix_file(os.path.join(root, filename))
