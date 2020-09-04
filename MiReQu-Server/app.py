# docs @ http://flask.pocoo.org/docs/1.0/quickstart/
from src.python.timeTaggerData import CoincidencesNoUI
from src.python.rotEncoderData import rotEncoderInterface


from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
import sys, os
import PySide2
import numpy as np

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger

from PySide2.QtWidgets import QApplication, QFileDialog

app = Flask(__name__)
CORS(app)

dirname = os.path.dirname(PySide2.__file__)
plugin_path = os.path.join(dirname, 'plugins', 'platforms')
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = plugin_path


tagger = createTimeTagger()

ccStream = CoincidencesNoUI(tagger)
rEncoder = rotEncoderInterface("COM5")


@app.route('/datagettimetagger', methods=['GET', 'POST'])
def dataGetTimetagger():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json())  # parse as JSON
        return 'OK', 200

    # GET request
    else:
        message = {
            'C1': np.flip(ccStream.counter.getData()[0]* ccStream.getCouterNormalizationFactor()).tolist(),
            'C2': np.flip(ccStream.counter.getData()[1]* ccStream.getCouterNormalizationFactor()).tolist(),
            'CC12': np.flip(ccStream.counter.getData()[2] * ccStream.getCouterNormalizationFactor()).tolist(),
            'CR12': ccStream.correlation.getData().tolist()
        }
        return jsonify(message)  # serialize and use JSON headers


@app.route('/datagetrotations', methods=['GET', 'POST'])
def dataGetRot():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json())  # parse as JSON
        return 'OK', 200

    # GET request
    else:
        message = {
            'p00': rEncoder.getPos(),
        }
        return jsonify(message)  # serialize and use JSON headers


