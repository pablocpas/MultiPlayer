from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip, clips_array
from PySide6.QtCore import QObject, Signal, Slot
import os
from proglog import ProgressBarLogger
import multiprocessing

class CancellationException(Exception):
    pass

class MyCombineLogger(ProgressBarLogger):
    
    def __init__(self, signal, total_segments, combine_worker):
        super().__init__()
        self.progress_signal = signal
        self.total_segments = total_segments
        self.current_segment = 0
        self.combine_worker = combine_worker

    def callback(self, **changes):
        for (parameter, value) in changes.items():
            print ('Parameter %s is now %s' % (parameter, value))
    
    def bars_callback(self, bar, attr, value, old_value=None):
        if not self.combine_worker.is_running():
            raise CancellationException('Combining cancelled')
        if bar == 't':
            segment_progress = (value / self.bars[bar]['total']) * 100
            global_progress = ((self.current_segment + segment_progress / 100) / self.total_segments) * 100
            self.progress_signal.emit(int(global_progress))

    def update_current_segment(self):
        self.current_segment += 1

class CombineWorker(QObject):
    progress = Signal(int)
    finished = Signal(str)

    def __init__(self, video_players):
        super().__init__()
        self._video_players = video_players
        self._is_running = True  # Variable de control para cancelar

    def is_running(self):
        return self._is_running

    @Slot()
    def run(self):
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
                    raise CancellationException('Combining cancelled')

                segment_clips = []
                for i, clip in enumerate(clips):
                    if not self._is_running:
                        raise CancellationException('Combining cancelled')

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
                    raise CancellationException('Combining cancelled')

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
            print(f"Failed to combine videos: {e}")
            self.finished.emit(None)

    def stop(self):
        self._is_running = False
