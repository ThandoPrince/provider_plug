from PIL import Image
import os

input_path = "assets/icons/plug_icon.png"
output_path = "assets/icons/plug_provider_foreground.png"

img = Image.open(input_path).convert("RGBA")

size = 1024
canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

safe = int(size * 0.7)
img.thumbnail((safe, safe), Image.LANCZOS)

x = (size - img.width) // 2
y = (size - img.height) // 2

canvas.paste(img, (x, y), img)

os.makedirs(os.path.dirname(output_path), exist_ok=True)
canvas.save(output_path)

print("Foreground icon created:", output_path)