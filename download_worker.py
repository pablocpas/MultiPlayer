from PySide6.QtCore import QObject, Signal, Slot
import yt_dlp
import os



## @ingroup python
class DownloadWorker(QObject):
    """
    Clase para manejar la descarga de videos utilizando yt-dlp.

    Señales:
        finished(str): Emitida cuando la descarga del video ha terminado.
        progress(int): Emitida para actualizar el progreso de la descarga.
    """
    finished = Signal(str)
    progress = Signal(int)

    def __init__(self, url, output_path, filename):
        """
        Inicializa el DownloadWorker con la URL del video, la ruta de salida y el nombre del archivo.

        Args:
            url: La URL del video para descargar.
            output_path: La ruta donde se guardará el video descargado.
            filename: El nombre del archivo para el video descargado.
        """
        super().__init__()
        self.url = url
        self.output_path = output_path
        self.filename = filename

    @Slot()
    def run(self):
        """
        Ejecuta la descarga del video.
        """
        print(f"Descargando video desde {self.url} a {self.output_path}")
        ydl_opts = {
            'format': 'best',
            'outtmpl': os.path.join(self.output_path, self.filename),
            'progress_hooks': [self.progress_hook],
            'noprogress': False,
            'nocolor': True
        }

        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([self.url])
                full_path = os.path.join(self.output_path, self.filename)
                print(f"Video descargado a {full_path}")
                self.finished.emit(full_path)
        except Exception as e:
            print(f"Error al descargar el video: {e}")
            self.finished.emit(None)

    def progress_hook(self, d):
        """
        Hook de progreso para la descarga del video.

        Args:
            d: Diccionario con la información de progreso.
        """
        if d['status'] == 'downloading':
            if d.get('total_bytes') is not None:
                percentage = d['downloaded_bytes'] * 100 / d['total_bytes']
                self.progress.emit(int(percentage))
            else:
                print("Descargando, tamaño desconocido.")
        elif d['status'] == 'finished':
            self.finished.emit(d['filename'])
        elif d['status'] == 'error':
            print('Error durante la descarga.')
