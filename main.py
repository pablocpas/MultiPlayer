import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QIcon
from video_handler import VideoHandler
import ctypes
import os
import shutil
import atexit
IMAGEMAGICK_BINARY = "C:\\Program Files\\ImageMagick-7.1.1-Q16-HDRI\\magick.exe"

def clean_temp_directory(temp_dir):
    """
    Limpia el directorio temporal asegurándose de que todos los archivos estén cerrados.
    """
    if os.path.exists(temp_dir):
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                try:
                    os.remove(os.path.join(root, file))
                except PermissionError as e:
                    print(f"PermissionError: {e}")
                    # Aquí podrías intentar cerrar el archivo si es necesario
        shutil.rmtree(temp_dir)
        print(f"Directorio temporal {temp_dir} eliminado.")

def clean_up(video_handler):
    video_handler.close_video_files()
    clean_temp_directory(video_handler.temp_dir)

if __name__ == "__main__":
    """
    Punto de entrada principal para la aplicación de Video Player.
    """
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    print(os.getenv('IMAGEMAGICK_BINARY'))
    myappid = 'mycompany.myproduct.subproduct.version' # cadena arbitraria
    if(sys.platform == "win32"):
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

    app.setApplicationName("Video Player")
    app.setWindowIcon(QIcon("./images/icono.png"))

    video_handler = VideoHandler()
    engine.rootContext().setContextProperty("videoHandler", video_handler)
    engine.load('main.qml')
    
    if not engine.rootObjects():
        sys.exit(-1)

    atexit.register(clean_up, video_handler)
    exit_code = app.exec()
    sys.exit(exit_code)
