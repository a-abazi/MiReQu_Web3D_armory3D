# docs @ http://flask.pocoo.org/docs/1.0/quickstart/
from src.python.timeTaggerData import CoincidencesNoUI
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


@app.route('/dataget', methods=['GET', 'POST'])
def dataGet():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json())  # parse as JSON
        return 'OK', 200

    # GET request
    else:
        # message = {'greeting':'Hello from Flask!'}
        message = {
            'C1': np.flip(ccStream.counter.getData()[0]* ccStream.getCouterNormalizationFactor()).tolist(),
            'C2': np.flip(ccStream.counter.getData()[1]* ccStream.getCouterNormalizationFactor()).tolist(),
            'CC12': np.flip(ccStream.counter.getData()[2] * ccStream.getCouterNormalizationFactor()).tolist(),
            'CR12': ccStream.correlation.getData().tolist()
            #'C1': [10, 20, 30, 40],
            #'C2': [20, 30, 40, 10],
            #'CC12': [10, 0, 0, 10],
            #'CR12': [0, 0, 10, 10, 0]
        }
        return jsonify(message)  # serialize and use JSON headers


