import sys
import re
import os
import urllib.parse
from datetime import datetime
from PySide6.QtCore import QObject, Signal, Slot, QThread, QTimer
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
import yt_dlp
from moviepy.editor import VideoFileClip, clips_array
import numpy as np


class VideoHandler(QObject):
    finished = Signal()
    progressUpdated = Signal(int)

    def __init__(self):
        super().__init__()
        self.thread = None
        self.worker = None
        self._video_players = {}
        self.segments = {}

    @Slot(QObject, int)
    def registerVideoPlayer(self, video_player, player_id):
        self._video_players[player_id] = video_player
        self.segments[player_id] = []
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
            self._video_players[video_id].setPath(path)
            self._video_players[video_id].pause()
            self._video_players[video_id].seek(0)
            self.finished.emit()

    @Slot(int)
    def update_progress(self, value):
        print("Progress updating to:", value)
        self.progressUpdated.emit(value)

    @Slot(str, float, float)
    def trim_video(self, filepath, start, end):
        filepath = urllib.parse.unquote(filepath.replace("file:///", ""))
        start, end = float(start), float(end)

        try:
            clip = VideoFileClip(filepath)
            trimmed_clip = clip.subclip(start, end)
            output_filename = f"trimmed_{start}_{end}.mp4"
            trimmed_clip.write_videofile(output_filename, codec="libx264")
            print(f"Vídeo recortado guardado como {output_filename}")
        except Exception as e:
            print(f"Error al procesar el video: {e}")

    def resize_clip(self, clip, height):
        def resize_frame(frame):
            from PIL import Image
            img = Image.fromarray(frame)
            width = int(img.width * height / img.height)
            return np.array(img.resize((width, height), Image.LANCZOS))
        
        return clip.fl_image(resize_frame)

    @Slot(str, str)
    def fusion_video(self, filepath1, filepath2):
        filepath1 = urllib.parse.unquote(filepath1.replace("file:///", ""))
        filepath2 = urllib.parse.unquote(filepath2.replace("file:///", ""))

        try:
            clip1 = VideoFileClip(filepath1)
            clip2 = VideoFileClip(filepath2)
            clip2_resized = self.resize_clip(clip2, clip1.h)
            final_clip = clips_array([[clip1, clip2_resized]])
            final_clip.write_videofile("resultado.mp4", codec='libx264')
            print(f"Vídeos fusionados guardados como resultado.mp4")
        except Exception as e:
            print(f"Error al procesar los vídeos: {e}")

    @Slot(int, list)
    def updateSegments(self, player_id, segments):
        self.segments[player_id] = self.parse_segments(segments)
        print(f"Segmentos actualizados para el reproductor {player_id}: {self.segments[player_id]}")
        self.save_segments_to_file(player_id)

    def parse_segments(self, segments):
        parsed_segments = []
        for segment in segments:
            if isinstance(segment, QObject) and hasattr(segment, 'property'):
                time_str = segment.property('timestamp')
                description = segment.property('description')
                if time_str and description:
                    parsed_segments.append((self.convert_time_to_seconds(time_str), description))
                else:
                    print("Segment missing required properties")
            else:
                print("Invalid segment object")
        return parsed_segments

    def convert_time_to_seconds(self, time_str):
        minutes, seconds = map(int, time_str.split(':'))
        return minutes * 60 + seconds

    def save_segments_to_file(self, player_id):
        segments = self.segments.get(player_id, [])
        with open(f'segments_{player_id}.txt', 'w') as f:
            for start, description in segments:
                minutes, seconds = divmod(start, 60)
                time_str = f"{minutes:02}:{seconds:02}"
                f.write(f"{time_str} - {description}\n")
        print(f"Segmentos guardados en segments_{player_id}.txt")

    @Slot(int)
    def play_next_segment(self, player_id):
        if player_id in self._video_players and player_id in self.segments:
            segments = self.segments[player_id]
            if segments:
                start, description = segments.pop(0)
                video_player = self._video_players[player_id]
                self.play_segment(video_player, start)
            else:
                print(f"No hay más segmentos para reproducir para el reproductor {player_id}")
        else:
            print(f"Reproductor {player_id} no encontrado o sin segmentos")

    def play_segment(self, video_player, start):
        video_player.seek(start)
        video_player.play()
        QTimer.singleShot(5000, video_player.pause)


class DownloadWorker(QObject):
    finished = Signal(str)
    progress = Signal(int)

    def __init__(self, url, output_path, filename):
        super().__init__()
        self.url = url
        self.output_path = output_path
        self.filename = filename

    @Slot()
    def run(self):
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
                print(f"Video downloaded to {full_path}")
                self.finished.emit(full_path)
        except Exception as e:
            print(f"Failed to download video: {e}")
            self.finished.emit(None)

    def progress_hook(self, d):
        if d['status'] == 'downloading':
            percentage_str = re.sub(r'\x1b\[[0-9;]*m', '', d['_percent_str'].strip())
            try:
                percentage = float(percentage_str.replace('%', ''))
                self.progress.emit(int(percentage))
            except ValueError as e:
                print(f"ValueError: {e}")
        elif d['status'] == 'finished':
            self.finished.emit(d['filename'])


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    video_handler = VideoHandler()
    engine.rootContext().setContextProperty("videoHandler", video_handler)
    engine.load('main.qml')
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
