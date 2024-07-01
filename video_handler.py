from PySide6.QtCore import QObject, Signal, Slot, QThread
from PySide6.QtGui import QGuiApplication
from moviepy.editor import VideoFileClip, clips_array, TextClip, CompositeVideoClip
from moviepy.config import change_settings
import platform
import subprocess
from download_worker import DownloadWorker
from combine_worker import CombineWorker
from datetime import datetime
import os


## @defgroup python Python
# @brief Módulo de Python
# @details Backend de la aplicación de Video Player.
# @{



if os.name == 'nt':
    change_settings({"IMAGEMAGICK_BINARY": r"C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe"})

## @ingroup python
class VideoPlayer:
    """
    Clase para manejar la información relacionada con el reproductor de video.

    Atributos:
        video_player: La instancia del reproductor de video.
        path: Ruta al archivo de video.
        segments: Lista de segmentos en el video.
        name: Nombre del video.
    """
    def __init__(self, video_player):
        """
        Inicializa el VideoPlayer con la instancia del reproductor de video dada.
        
        Args:
            video_player: La instancia del reproductor de video.
        """
        self.video_player = video_player
        self.path = ""
        self.segments = []
        self.name = "aaa"

## @ingroup python
class VideoHandler(QObject):
    """
    Clase para manejar operaciones de video, incluyendo descarga, actualización de segmentos y combinación de videos.

    Señales:
        finished(str, int): Emitida cuando una descarga de video ha terminado.
        progressUpdated(int): Emitida para actualizar el progreso de la descarga.
        finishedCombine(str): Emitida cuando la combinación de videos ha terminado.
    """
    finished = Signal(str, int)
    progressUpdated = Signal(int)
    finishedCombine = Signal(str)

    def __init__(self):
        """
        Inicializa el VideoHandler.
        """
        super().__init__()
        self.thread = None
        self.worker = None
        self._video_players = {}

    @Slot(QObject, int)
    def registerVideoPlayer(self, video_player, player_id):
        """
        Registra un reproductor de video con un ID específico.
        
        Args:
            video_player: La instancia del reproductor de video.
            player_id: El ID del reproductor de video.
        """
        self._video_players[player_id] = VideoPlayer(video_player)
        print(f"Reproductor de video {player_id} registrado")

    @Slot(str, str, int)
    def download_youtube_video(self, url, output_path, video_id):
        """
        Descarga un video de YouTube.

        Args:
            url: La URL del video de YouTube.
            output_path: La ruta para guardar el video descargado.
            video_id: El ID del video.
        """
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        filename = f"video_{video_id}_{timestamp}.mp4"
        self.thread = QThread()
        self.worker = DownloadWorker(url, output_path, filename)
        self.worker.moveToThread(self.thread)
        self.worker.finished.connect(self.thread.quit)
        self.worker.finished.connect(lambda path, vid=video_id: self.on_download_finished(vid, path))
        self.worker.progress.connect(self.update_progress)
        self.thread.started.connect(self.worker.run)
        self.thread.start()

    @Slot()
    def on_download_finished(self, video_id, path):
        """
        Slot llamado cuando la descarga del video ha terminado.

        Args:
            video_id: El ID del video.
            path: La ruta del video descargado.
        """
        if path:
            video_player_obj = self._video_players[video_id]
            video_player_obj.path = path
            video_player_obj.video_player.setPath(path)
            video_player_obj.video_player.pause()
            video_player_obj.video_player.seek(0)
            self.finished.emit(path, video_id)

    @Slot(int, str)
    def setVideoName(self, player_id, name):
        """
        Establece el nombre del video para un ID de reproductor específico.

        Args:
            player_id: El ID del reproductor de video.
            name: El nombre para establecer en el video.
        """
        video_player_obj = self._video_players.get(player_id)
        if video_player_obj:
            video_player_obj.name = name
    
    @Slot(int, str)
    def load_video(self, video_id, path):
        """
        Carga un video para un ID de reproductor específico.

        Args:
            video_id: El ID del reproductor de video.
            path: La ruta del video para cargar.
        """
        if path:
            video_player_obj = self._video_players[video_id]
            video_player_obj.path = path

    @Slot(int)
    def update_progress(self, value):
        """
        Actualiza el progreso de una operación.

        Args:
            value: El valor del progreso.
        """
        self.progressUpdated.emit(value)

    @Slot(int, list, result='QVariantList')
    def updateSegments(self, player_id, segments):
        """
        Actualiza los segmentos para un ID de reproductor específico.

        Args:
            player_id: El ID del reproductor de video.
            segments: Lista de segmentos para actualizar.

        Returns:
            list: Lista de tiempos de inicio para los segmentos.
        """
        video_player_obj = self._video_players[player_id]
        video_player_obj.segments = self.parse_segments(segments)
        print(f"Segmentos actualizados para el reproductor {player_id}: {video_player_obj.segments}")
        self.save_segments_to_file(player_id)

        # Extraer los tiempos de inicio y devolverlos como una lista
        start_times = [segment[0] for segment in video_player_obj.segments]
        return start_times

    @Slot(int, result='QVariantList')
    def getDescription(self, player_id):
        """
        Obtiene las descripciones de los segmentos para un ID de reproductor específico.

        Args:
            player_id: El ID del reproductor de video.

        Returns:
            list: Lista de descripciones de los segmentos.
        """
        video_player_obj = self._video_players.get(player_id)
        if (video_player_obj and video_player_obj.segments):
            descriptions = [segment[1] for segment in video_player_obj.segments]
            return descriptions
        else:
            return []

    def parse_segments(self, segments):
        """
        Analiza los segmentos de una lista de objetos de segmento.

        Args:
            segments: Lista de objetos de segmento.

        Returns:
            list: Lista de segmentos analizados como tuplas (tiempo, descripción).
        """
        parsed_segments = []
        for segment in segments:
            if isinstance(segment, QObject) and hasattr(segment, 'property'):
                time_str = segment.property('timestampInSeconds')
                description = segment.property('description')
                print(f"Segmento: {time_str} - {description}")
                if time_str and description:
                    parsed_segments.append((time_str, description))
                else:
                    print("Segmento falta de propiedades requeridas")
            else:
                print("Objeto de segmento inválido")
        return parsed_segments    

    def convert_time_to_seconds(self, time_str):
        """
        Convierte una cadena de tiempo a segundos.

        Args:
            time_str: Cadena de tiempo en el formato 'MM:SS'.

        Returns:
            int: Tiempo en segundos.
        """
        minutes, seconds = map(int, time_str.split(':'))
        return minutes * 60 + seconds

    def save_segments_to_file(self, player_id):
        """
        Guarda los segmentos en un archivo para un ID de reproductor específico.

        Args:
            player_id: El ID del reproductor de video.
        """
        video_player_obj = self._video_players.get(player_id)
        segments = video_player_obj.segments if video_player_obj else []
        with open(f'segments_{player_id}.txt', 'w') as f:
            for start, description in segments:
                minutes, seconds = divmod(start, 60)
                time_str = f"{minutes:02}:{seconds:02}"
                f.write(f"{time_str} - {description}\n")
        print(f"Segmentos guardados en segments_{player_id}.txt")

    @Slot()
    def combine_videos(self):
        """
        Combina múltiples videos en uno solo.
        """
        self.thread = QThread()
        print("Combinando videos... 111")
        self.combine_worker = CombineWorker(self._video_players)
        self.combine_worker.moveToThread(self.thread)
        self.combine_worker.progress.connect(self.update_progress)
        self.combine_worker.finished.connect(self.thread.quit)
        self.combine_worker.finished.connect(lambda path: self.finishedCombine.emit(path))

        self.thread.started.connect(self.combine_worker.run)
        self.thread.start()

    @Slot()
    def stop(self):
        """
        Detiene la operación actual.
        """
        if self.thread:
            self.combine_worker.stop()

    @Slot(str)
    def open_file_explorer(self, path):
        """
        Abre el explorador de archivos en la ruta especificada.

        Args:
            path: La ruta para abrir en el explorador de archivos.
        """
        path = os.path.normpath(path)
        if platform.system() == "Windows":
            subprocess.Popen(fr'explorer /select,"{path}"')
        elif platform.system() == "Darwin":  # macOS
            subprocess.run(["open", path])
        else:  # Linux y otros sistemas UNIX-like
            subprocess.run(["xdg-open", path])

## @}