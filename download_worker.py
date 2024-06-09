from PySide6.QtCore import QObject, Signal, Slot
import yt_dlp
import os
import re

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
