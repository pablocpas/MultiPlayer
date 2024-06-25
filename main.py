import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QIcon
from video_handler import VideoHandler
import ctypes
import os


IMAGEMAGICK_BINARY = "C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe"

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    print(os.getenv('IMAGEMAGICK_BINARY'))
    myappid = 'mycompany.myproduct.subproduct.version' # arbitrary string
    if(sys.platform == "win32"):
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

    app.setApplicationName("Video Player")
    app.setWindowIcon(QIcon("./images/icono.png"))


    video_handler = VideoHandler()
    engine.rootContext().setContextProperty("videoHandler", video_handler)
    engine.load('main.qml')
    
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
