# docs @ http://flask.pocoo.org/docs/1.0/quickstart/
from src.python.timeTaggerData import QKDNoUI
from src.python.rotEncoderData import rotEncoderInterface
from src.python.CommunicationManager import CommunicationManager

import time

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger, TimeTagStream


" Start Server by running this Script"

"""
Here is an Example for the structure of the JsonFiles for the export:
tstJsonExport = '{"Exercise":"Hauptversuch", "Subexercise":"Aufgabe1"' \
                ',"FileName": "TstName"' \
                ',"xAxis": [0,1,2,3,4]' \
                ',"yAxis1": [0.0,10.0,20.0,30.0,40.0]' \
                ',"yAxis2": [0.0,12.0,22.0,32.0,42.0]' \
                ',"yAxis3": [0.0,13.0,23.0,33.0,43.0]' \
                ' }'
"""



tagger = createTimeTagger()
ccStream = QKDNoUI(tagger)
ccManager = CommunicationManager()
tagStream = TimeTagStream(tagger, n_max_events=1, channels=ccStream.coincidences.getChannels())

time.sleep(0.5)

for i in range(10000):
    buffer = tagStream.getData()
    channels = buffer.getChannels()
    detection = int (channels[0] - 1000)
    print(channels-1000,detection)
    time.sleep(2)