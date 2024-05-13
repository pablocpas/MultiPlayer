import sys
from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot, QThread, QTimer
from pytube import YouTube
from moviepy.editor import VideoFileClip, clips_array
import numpy as np
import urllib.parse
import os
from datetime import datetime


class VideoHandler(QObject):
    finished = Signal()  # Definir esta señal en VideoHandler también
    progressUpdated = Signal(int)  # Añadir esta línea
    def __init__(self):
        super().__init__()
        self.thread = None
        self.worker = None
        self._video_players = {}


    @Slot(QObject, int)
    def registerVideoPlayer(self, video_player, player_id):
        self._video_players[player_id] = video_player
        print(f"Video player {player_id} registered")


    @Slot(str, str, int)
    def download_youtube_video(self, url, output_path, video_id):
        # Generar un nombre de archivo único con timestamp
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
        self._video_players[video_id].setPath(path)
        self.finished.emit()

    @Slot(int)
    def update_progress(self, value):
        # Emite una señal propia que pueda ser manejada por QML
        print("Progress updating to: ", value)  # Diagnóstico: Imprimir en consola de Python
        self.progressUpdated.emit(value)

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


            print(f"Vídeos fusionados guardados como resultado.mp4")

        except Exception as e:
            print(f"Error al procesar los vídeos: {e}")


    @Slot(str)
    def updateSegments(self, segment_text):
        self.segments = self.parse_segments(segment_text)
        self._video_players[0].play()
        print("Segmentos actualizados:", self.segments)

    def parse_segments(self, segment_text):
        segments = {}
        lines = segment_text.split('\n')
        for line in lines:
            if line.strip():
                time_str, description = map(str.strip, line.split('-', 1))
                segments[self.convert_time_to_seconds(time_str)] = description
        return segments

    def convert_time_to_seconds(self, time_str):
        minutes, seconds = map(int, time_str.split(':'))
        return minutes * 60 + seconds
    
    @Slot()
    def play_next_segment(self, video_player):
        if self.current_segment_index < len(self.segments):
            start, end = self.segments[self.current_segment_index]
            video_player.play_segment(start, end)
            self.current_segment_index += 1
        else:
            print("No hay más segmentos para reproducir")

    def play_segment(self, video_player, start, end):
        video_player.seek(start)
        video_player.play()
        QTimer.singleShot((end - start) * 1000, video_player.pause)  # Detiene la reproducción después del segmento



class DownloadWorker(QObject):
    finished = Signal(str)  # Emite la ruta completa del archivo descargado
    progress = Signal(int)  # Emite el progreso de la descarga

    def __init__(self, url, output_path, filename):
        super().__init__()
        self.url = url
        self.output_path = output_path  # Definir output_path como un atributo
        self.filename = filename  # Definir filename como un atributo

    @Slot()
    def run(self):
        try:
            yt = YouTube(self.url, on_progress_callback=self.progress_callback)
            video = yt.streams.filter(progressive=True, file_extension='mp4').order_by('resolution').desc().first()
            if video:
                video.download(output_path=self.output_path, filename=self.filename)
                full_path = os.path.join(self.output_path, self.filename)
                print(f"Video downloaded to {full_path}")
                self.finished.emit(full_path)
            else:
                raise Exception("No suitable video found")
        except Exception as e:
            print(f"Failed to download video: {e}")
            self.finished.emit(None)

    def progress_callback(self, stream, chunk, bytes_remaining):
        total_size = stream.filesize
        bytes_downloaded = total_size - bytes_remaining
        percentage = int((bytes_downloaded / total_size) * 100)
        self.progress.emit(percentage)





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
