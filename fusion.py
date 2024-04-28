from moviepy.editor import VideoFileClip, clips_array
import numpy as np

def resize_clip(clip, height):
    # Esta función ajusta el tamaño de los frames usando numpy
    def resize_frame(frame):
        from PIL import Image
        # Convertir el array de numpy a una imagen PIL
        img = Image.fromarray(frame)
        # Calcular el nuevo ancho manteniendo la proporción
        width = int(img.width * height / img.height)
        # Redimensionar la imagen y volver a convertirla a array
        resized_img = np.array(img.resize((width, height), Image.LANCZOS))
        return resized_img

    # Aplicar la función de redimensionamiento a cada frame del vídeo
    return clip.fl_image(resize_frame)

# Cargar los vídeos
clip1 = VideoFileClip("video.mp4")
clip2 = VideoFileClip("video.mp4")

# Redimensionar clip2 para que coincida con la altura de clip1
clip2_resized = resize_clip(clip2, clip1.h)

# Crear un array de clips. En este caso, los clips se mostrarán uno al lado del otro
final_clip = clips_array([[clip1, clip2_resized]])

# Escribir el resultado a un archivo
final_clip.write_videofile("resultado.mp4", codec='libx264')
