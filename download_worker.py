from PySide6.QtCore import QObject, Signal, Slot
import yt_dlp
import os

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
        print(f"Downloading video from {self.url} to {self.output_path}")
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
            if d.get('total_bytes') is not None:
                percentage = d['downloaded_bytes'] * 100 / d['total_bytes']
                self.progress.emit(int(percentage))
            else:
                print("Downloading, size unknown.")
        elif d['status'] == 'finished':
            self.finished.emit(d['filename'])
        elif d['status'] == 'error':
            print('Error during download.')
