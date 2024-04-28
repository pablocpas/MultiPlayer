import sys
from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from moviepy.editor import VideoFileClip, clips_array
import numpy as np
import urllib.parse

class VideoHandler(QObject):
    def __init__(self):
        super().__init__()

    @Slot(str, float, float)
    def trim_video(self, filepath, start, end):
        # Convertir la URL del archivo a una ruta de archivo local
        filepath = urllib.parse.unquote(filepath.replace("file:///", ""))

        # Asegúrate de que los tiempos están en segundos y son flotantes
        start = float(start)
        end = float(end)

        print(f"Recortando el vídeo {filepath} desde {start} segundos hasta {end} segundos.")
        
        try:
            # Cargar el vídeo
            clip = VideoFileClip(filepath)
            
            # Recortar el clip al rango especificado
            trimmed_clip = clip.subclip(start, end)
            
            # Definir el nombre del archivo de salida
            output_filename = f"trimmed_{start}_{end}.mp4"
            
            # Guardar el vídeo recortado
            trimmed_clip.write_videofile(output_filename, codec="libx264")

            print(f"Vídeo recortado guardado como {output_filename}")

        except Exception as e:
            print(f"Error al procesar el video: {e}")

    
    def resize_clip(self, clip, height):
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
        
        return clip.fl_image(resize_frame)

    @Slot(str, str)
    def fusion_video(self, filepath1, filepath2):
        # Convertir la URL del archivo a una ruta de archivo local
        filepath1 = urllib.parse.unquote(filepath1.replace("file:///", ""))
        filepath2 = urllib.parse.unquote(filepath2.replace("file:///", ""))

        print(f"Fusionando los vídeos {filepath1} y {filepath2}.")

        try:
            # Cargar los vídeos
            clip1 = VideoFileClip(filepath1)
            clip2 = VideoFileClip(filepath2)

            clip2_resized = self.resize_clip(clip2, clip1.h)

            
            final_clip = clips_array([[clip1, clip2_resized]])
            
            final_clip.write_videofile("resultado.mp4", codec='libx264')


            print(f"Vídeos fusionados guardados como {"resultado.mp4"}")

        except Exception as e:
            print(f"Error al procesar los vídeos: {e}")




if __name__ == "__main__":
    # Crea una aplicación GUI
    app = QGuiApplication(sys.argv)

    # Crea un motor QML
    engine = QQmlApplicationEngine()

    # Crea una instancia de VideoHandler
    video_handler = VideoHandler()

    # Exponer la instancia de VideoHandler al contexto de QML
    engine.rootContext().setContextProperty("videoHandler", video_handler)

    # Carga el archivo QML
    engine.load('main.qml')

    # Verifica si la carga fue exitosa
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
