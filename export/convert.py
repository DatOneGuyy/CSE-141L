from pdf2image import convert_from_path
import os

files = [f for f in os.listdir('.') if (os.path.isfile(f) and f[-4:] == ".pdf")]
print(files)

for file in files:
    print(f"Converting {file}")
    pages = convert_from_path(file, dpi=1200)
    for i, page in enumerate(pages):
        page.save(f"{file[:-4]}.png", "PNG")