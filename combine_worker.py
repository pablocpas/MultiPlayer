from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip, clips_array
from PySide6.QtCore import QObject, Signal, Slot
import os
from proglog import ProgressBarLogger

class MyCombineLogger(ProgressBarLogger):
    
    def __init__(self, signal, total_segments):
        super().__init__()
        self.progress_signal = signal
        self.total_segments = total_segments
        self.current_segment = 0

    def callback(self, **changes):
        for (parameter, value) in changes.items():
            print ('Parameter %s is now %s' % (parameter, value))
    
    def bars_callback(self, bar, attr, value, old_value=None):
        # Check if the bar is the video progress bar (usually 't')
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

    @Slot()
    def run(self):

        print("Combinando videos...")

        paths = []
        video_names = []
        segments = []
        
        for video_player in self._video_players.values():
            if video_player.path:                
                path = video_player.path.replace('file:///', '')  # Eliminar el prefijo 'file:///'

                # if linux add / to the path
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
        logger = MyCombineLogger(self.progress, total_segments)
        
        for segment_index in range(total_segments):
            segment_clips = []
            for i, clip in enumerate(clips):
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

            output_path = f"combined_video_segment_{segment_index + 1}.mp4"
            combined.write_videofile(output_path, codec="libx264", threads=16, logger=logger)

            logger.update_current_segment()  # Update progress after each segment stage
            print(f"Video combinado guardado en {output_path}")

        self.finished.emit("All videos combined successfully.")
