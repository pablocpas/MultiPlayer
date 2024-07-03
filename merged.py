from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip, clips_array
from PySide6.QtCore import QObject, Signal, Slot
import os
from proglog import ProgressBarLogger
import multiprocessing

## @ingroup python
class CancellationException(Exception):
    """
    Excepción personalizada para manejar la cancelación del proceso de combinación de videos.
    """
    pass

## @ingroup python
class MyCombineLogger(ProgressBarLogger):
    """
    Logger personalizado para manejar el progreso de la combinación de videos.
    """
    def __init__(self, signal, total_segments, combine_worker):
        """
        Inicializa el MyCombineLogger con las señales y el número total de segmentos.

        Args:
            signal: Señal para emitir el progreso.
            total_segments: Número total de segmentos a combinar.
            combine_worker: Instancia de CombineWorker.
        """
        super().__init__()
        self.progress_signal = signal
        self.total_segments = total_segments
        self.current_segment = 0
        self.combine_worker = combine_worker

    def callback(self, **changes):
        """
        Callback para manejar cambios en los parámetros de progreso.

        Args:
            changes: Diccionario con los cambios en los parámetros.
        """
        for (parameter, value) in changes.items():
            print ('Parámetro %s ahora es %s' % (parameter, value))
    
    def bars_callback(self, bar, attr, value, old_value=None):
        """
        Callback para manejar cambios en las barras de progreso.

        Args:
            bar: Barra de progreso.
            attr: Atributo de la barra.
            value: Valor actual del atributo.
            old_value: Valor anterior del atributo.
        """
        if not self.combine_worker.is_running():
            raise CancellationException('Combinación cancelada')
        if bar == 't':
            segment_progress = (value / self.bars[bar]['total']) * 100
            global_progress = ((self.current_segment + segment_progress / 100) / self.total_segments) * 100
            self.progress_signal.emit(int(global_progress))

    def update_current_segment(self):
        """
        Actualiza el segmento actual incrementando en uno.
        """
        self.current_segment += 1

## @ingroup python
class CombineWorker(QObject):
    """
    Clase para manejar la combinación de videos.
    
    Señales:
        progress(int): Emitida para actualizar el progreso de la combinación.
        finished(str): Emitida cuando la combinación de videos ha terminado.
    """
    progress = Signal(int)
    finished = Signal(str)

    def __init__(self, video_players):
        """
        Inicializa el CombineWorker con los reproductores de video.

        Args:
            video_players: Diccionario de reproductores de video.
        """
        super().__init__()
        self._video_players = video_players
        self._is_running = True  # Variable de control para cancelar

    def is_running(self):
        """
        Verifica si el proceso de combinación está en ejecución.

        Returns:
            bool: Verdadero si el proceso está en ejecución, falso de lo contrario.
        """
        return self._is_running

    @Slot()
    def run(self):
        """
        Ejecuta el proceso de combinación de videos.
        """
        try:
            print("Combinando videos...")

            paths = []
            video_names = []
            segments = []

            for video_player in self._video_players.values():
                if video_player.path:
                    path = video_player.path.replace('file:///', '')  # Eliminar el prefijo 'file:///'

                    if os.name == 'posix':
                        path = '/' + path

                    paths.append(path)
                    video_names.append(video_player.name)
                    segments.append(video_player.segments)

            clips = [VideoFileClip(path) for path in paths]

            if len(clips) == 0:
                print("No hay videos para combinar.")
                return

            total_segments = len(segments[0])
            logger = MyCombineLogger(self.progress, total_segments, self)

            num_threads = multiprocessing.cpu_count()

            for segment_index in range(total_segments):
                if not self._is_running:
                    raise CancellationException('Combinación cancelada')

                segment_clips = []
                for i, clip in enumerate(clips):
                    if not self._is_running:
                        raise CancellationException('Combinación cancelada')

                    start_time = segments[i][segment_index][0]
                    end_time = clip.duration
                    if segment_index < len(segments[i]) - 1:
                        end_time = segments[i][segment_index + 1][0]
                    subclip = clip.subclip(start_time, end_time)

                    txt_clip_video_name = TextClip(video_names[i], fontsize=24, color='white').set_position(('center', 'top')).set_duration(subclip.duration)
                    txt_clip_segment_name = TextClip(segments[i][segment_index][1], fontsize=24, color='white').set_position(('center', 'bottom')).set_duration(subclip.duration)

                    labeled_clip = CompositeVideoClip([subclip, txt_clip_video_name, txt_clip_segment_name])
                    segment_clips.append(labeled_clip)

                if len(segment_clips) == 1:
                    combined = segment_clips[0]
                elif len(segment_clips) == 2:
                    combined = clips_array([[segment_clips[0], segment_clips[1]]])
                elif len(segment_clips) == 3:
                    combined = clips_array([[segment_clips[0], segment_clips[1]], [segment_clips[2], None]])
                elif len(segment_clips) >= 4:
                    combined = clips_array([[segment_clips[0], segment_clips[1]], [segment_clips[2], segment_clips[3]]])

                if not self._is_running:
                    raise CancellationException('Combinación cancelada')

                video_name_str = ','.join(video_names)
                output_path = f"{video_name_str}_segment_{segment_index + 1}.mp4"
                
                combined.write_videofile(output_path, codec="libx264", threads=num_threads, logger=logger, fps=24, bitrate="5000k")

                logger.update_current_segment()
                print(f"Video combinado guardado en {output_path}")

            # Emitir la ruta absoluta
            self.finished.emit(os.path.abspath(output_path))

        except CancellationException as ce:
            print(ce)
            self.finished.emit("Combining was cancelled.")
        except Exception as e:
            print(f"Error al combinar videos: {e}")
            self.finished.emit(None)

    def stop(self):
        """
        Detiene el proceso de combinación de videos.
        """
        self._is_running = False
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
        self.temp_dir = ".temp"
        if not os.path.exists(self.temp_dir):
            os.makedirs(self.temp_dir)

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

    @Slot(str, int)
    def download_youtube_video(self, url, video_id):
        """
        Descarga un video de YouTube.

        Args:
            url: La URL del video de YouTube.
            output_path: La ruta para guardar el video descargado.
            video_id: El ID del video.
        """
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        filename = f"video_{video_id}_{timestamp}.mp4"
        output_path = self.temp_dir
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


    @Slot()
    def close_video_files(self):
        """
        Cierra todos los archivos de video abiertos.
        """
        for video_player in self._video_players.values():
            if video_player.path:
                try:
                    video_player.video_player.stop()
                    video_player.video_player.setPath("")
                    print(f"Archivo de video {video_player.path} cerrado.")
                except Exception as e:
                    print(f"Error cerrando el archivo de video {video_player.path}: {e}")
        self._video_players.clear()

## @}