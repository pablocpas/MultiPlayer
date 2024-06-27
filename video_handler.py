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

# Set the path to the ImageMagick binary
# if windows
if os.name == 'nt':
    change_settings({"IMAGEMAGICK_BINARY": r"C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe"})

class VideoPlayer:
    def __init__(self, video_player):
        self.video_player = video_player
        self.path = ""
        self.segments = []
        self.name = "aaa"

class VideoHandler(QObject):
    finished = Signal(str, int)
    progressUpdated = Signal(int)

    finishedCombine = Signal(str)
    def __init__(self):
        super().__init__()
        self.thread = None
        self.worker = None
        self._video_players = {}


    @Slot(QObject, int)
    def registerVideoPlayer(self, video_player, player_id):
        self._video_players[player_id] = VideoPlayer(video_player)
        print(f"Video player {player_id} registered")

    @Slot(str, str, int)
    def download_youtube_video(self, url, output_path, video_id):
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
        if path:
            video_player_obj = self._video_players[video_id]
            video_player_obj.path = path
            video_player_obj.video_player.setPath(path)
            video_player_obj.video_player.pause()
            video_player_obj.video_player.seek(0)
            self.finished.emit(path, video_id)

    @Slot(int, str)
    def setVideoName(self, player_id, name):
        video_player_obj = self._video_players.get(player_id)
        if video_player_obj:
            video_player_obj.name = name
    
    @Slot(int, str)
    def load_video(self, video_id, path):
        if path:
            video_player_obj = self._video_players[video_id]
            video_player_obj.path = path

    @Slot(int)
    def update_progress(self, value):
        self.progressUpdated.emit(value)

    @Slot(int, list, result='QVariantList')
    def updateSegments(self, player_id, segments):
        video_player_obj = self._video_players[player_id]
        video_player_obj.segments = self.parse_segments(segments)
        print(f"Segmentos actualizados para el reproductor {player_id}: {video_player_obj.segments}")
        self.save_segments_to_file(player_id)

        # Extraer los tiempos de inicio y devolverlos como una lista
        start_times = [segment[0] for segment in video_player_obj.segments]
        return start_times

    @Slot(int, result='QVariantList')
    def getDescription(self, player_id):
        video_player_obj = self._video_players.get(player_id)
        if video_player_obj and video_player_obj.segments:
            # Extraer las descripciones de los segmentos
            descriptions = [segment[1] for segment in video_player_obj.segments]
            return descriptions
        else:
            # Si no hay segmentos para el player_id, retornar una lista vacía
            return []

    def parse_segments(self, segments):
        parsed_segments = []
        for segment in segments:
            if isinstance(segment, QObject) and hasattr(segment, 'property'):
                time_str = segment.property('timestampInSeconds')
                description = segment.property('description')
                print(f"Segmento: {time_str} - {description}")
                if time_str and description:
                    parsed_segments.append((time_str, description))
                else:
                    print("Segment missing required properties")
            else:
                print("Invalid segment object")
        return parsed_segments    

    def convert_time_to_seconds(self, time_str):
        minutes, seconds = map(int, time_str.split(':'))
        return minutes * 60 + seconds

    def save_segments_to_file(self, player_id):
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
        if self.thread:
            self.combine_worker.stop()

    #usar esto con path:
    #subprocess.Popen(r'explorer /select,"C:\Users\Pablo\Documents\tfg3\MultiPlayer\aaa,aaa_segment_1.mp4"')

    @Slot(str)
    def open_file_explorer(self, path):
        path = os.path.normpath(path)
        if platform.system() == "Windows":
            subprocess.Popen(fr'explorer /select,"{path}"')

        elif platform.system() == "Darwin":  # macOS
            subprocess.run(["open", path])
        else:  # Linux and other UNIX-like systems
            subprocess.run(["xdg-open", path])
