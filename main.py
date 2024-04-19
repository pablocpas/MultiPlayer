import sys
from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from moviepy.editor import VideoFileClip
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
