import sys
import os
import PySide2

# PySide2 for the UI
from PySide2.QtWidgets import QApplication
from TimeTagger import  createTimeTagger, freeTimeTagger

from src.python.TimeTaggerNoServer.CoincidenceExample import CoincidenceExample


dirname = os.path.dirname(PySide2.__file__)
plugin_path = os.path.join(dirname, 'plugins', 'platforms')
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = plugin_path

app = QApplication(sys.argv)

tagger = createTimeTagger()

# If you want to include this window within a bigger UI,
# just copy these two lines within any of your handlers.
window = CoincidenceExample(tagger)

window.show()

app.exec_()

freeTimeTagger(tagger)