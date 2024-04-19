import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

if __name__ == "__main__":
    # Crea una aplicación GUI
    app = QGuiApplication(sys.argv)

    # Crea un motor QML
    engine = QQmlApplicationEngine()

    # Carga el archivo QML
    engine.load('main.qml')

    # Verifica si la carga fue exitosa
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
