# docs @ http://flask.pocoo.org/docs/1.0/quickstart/
from src.python.timeTaggerData import CoincidencesNoUI
from src.python.rotEncoderData import rotEncoderInterface
from src.python.ExportManager import ExportManager
from src.python.CommunicationManager import CommunicationManager

from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
import numpy as np
import time
import random

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger


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


#app = Flask(__name__)
#CORS(app)




#rEncoder = rotEncoderInterface("COM5") # Port Vorversuch
rEncoder = rotEncoderInterface("COM3") # Port Hauptversuch

tagger = createTimeTagger()
ccStream = CoincidencesNoUI(tagger)
ccManager = CommunicationManager()

#group = "Schueler1"  # GruppenNamen im Praktikum
#group = "Debug20210409"  # GruppenNamen im Praktikum
group = "Debug20220316"  # GruppenNamen im Praktikum
type = "Grundpraktikum"  # or "MR"
exportpath = "c:/ExportMiReQu/"

exportManager = ExportManager(group, type, exportpath)


boolTest = False

app = Flask(__name__)
CORS(app)





# TODO: !!! CHANGE INPUTS for Timetagger and arduino

@app.route("/helloWorld", methods=['GET', 'POST'])
def helloWorld():
    if request.method == 'POST':
        print("Hello World POST")
        return 'OK', 200

    # GET request
    else:
        message = "Hello World GET"

        return jsonify(message)  # serialize and use JSON headers

@app.route('/communication', methods=['GET', 'POST']) # method used to communicate data for multiuser environment in Unity
def getCommunication():
    # POST request
    if request.method == 'POST':
        message = request.get_json()
        print (message)
        ccManager.saveData(message)
        return 'OK', 200

    # GET request
    if request.method == 'GET':
        message = ccManager.getData()

        return jsonify(message)  # serialize and use JSON headers


@app.route('/getratessingles', methods=['GET', 'POST'])
def getRatesSingles():
    # POST request
    if request.method == 'POST':
        return 'OK', 200
        print('Incoming..')
        print(request.get_json())  # parse as JSON

    # GET request
    else:

        message = {
            'CA0': np.random.randint(0,30000,100).tolist(),
            'CA1': np.random.randint(0,30000,100).tolist(),
            'CB0': np.random.randint(0,30000,100).tolist(),
            'CB1': np.random.randint(0,30000,100).tolist(),

        }
        return jsonify(message)  # serialize and use JSON headers

@app.route('/getratesdoubles', methods=['GET', 'POST'])
def getRatesDoubles():
    # POST request
    if request.method == 'POST':
        return 'OK', 200
        print('Incoming..')
        print(request.get_json())  # parse as JSON

    # GET request
    else:
        message = {
            'CCA0B0': np.random.randint(0,3000,100).tolist(),
            'CCA1B0': np.random.randint(0,3000,100).tolist(),
            'CCA0B1': np.random.randint(0,3000,100).tolist(),
            'CCA1B1': np.random.randint(0,3000,100).tolist(),

        }
        return jsonify(message)  # serialize and use JSON headers


@app.route('/getratesall', methods=['GET', 'POST'])
def getRatesAll():
    # POST request
    if request.method == 'POST':
        return 'OK', 200
        print('Incoming..')
        print(request.get_json())  # parse as JSON

    # GET request
    else:
        message = {
            'CA0': np.random.randint(0,30000,100).tolist(),
            'CA1': np.random.randint(0,30000,100).tolist(),
            'CB0': np.random.randint(0,30000,100).tolist(),
            'CB1': np.random.randint(0,30000,100).tolist(),

            'CCA0B0': np.random.randint(0,3000,100).tolist(),
            'CCA1B0': np.random.randint(0,3000,100).tolist(),
            'CCA0B1': np.random.randint(0,3000,100).tolist(),
            'CCA1B1': np.random.randint(0,3000,100).tolist(),

        }
        return jsonify(message)  # serialize and use JSON headers

@app.route('/getlastdetection', methods=['GET', 'POST'])
def getlastDetection():
    # POST request
    if request.method == 'POST':
        return 'OK', 200
        print('Incoming..')
        print(request.get_json())  # parse as JSON

    # GET request
    else:

        message = {
            "detection" : random.randint(0,3)
        }

        return jsonify(message)  # serialize and use JSON headers


@app.route('/getratesanddetection', methods=['GET', 'POST'])
def getRatesAndDetection():
    # POST request
    if request.method == 'POST':
        return 'OK', 200
        print('Incoming..')
        print(request.get_json())  # parse as JSON

    # GET request
    else:

        # TODO: connect channel index to most recent timestamp
        message = {
            'CA0': np.random.randint(0, 30000, 100).tolist(),
            'CA1': np.random.randint(0, 30000, 100).tolist(),
            'CB0': np.random.randint(0, 30000, 100).tolist(),
            'CB1': np.random.randint(0, 30000, 100).tolist(),

            'CCA0B0': np.random.randint(0, 3000, 100).tolist(),
            'CCA1B0': np.random.randint(0, 3000, 100).tolist(),
            'CCA0B1': np.random.randint(0, 3000, 100).tolist(),
            'CCA1B1': np.random.randint(0, 3000, 100).tolist(),

            "detection": random.randint(0, 3)
        }

        return jsonify(message)  # serialize and use JSON headers


@app.route('/getrotations', methods=['GET', 'POST'])
def getRotations():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json())  # parse as JSON
        return 'OK', 200

    # GET request
    else:
        message = {
            'p00': rEncoder.getPos00(),
            'p01': rEncoder.getPos01(),
            'p02': rEncoder.getPos02(),
        }
        #exportManager.setRotEncoderPositions(message)
        return jsonify(message)  # serialize and use JSON headers

@app.route('/getsensors', methods=['GET', 'POST'])
def getSensors():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json())  # parse as JSON
        return 'OK', 200

    # GET request
    else:

        message = {
            's01': random.randint(0,1000), # rEncoder.getSens01(), #TODO Change Back to rEndoder
            's02': random.randint(0,1000), # rEncoder.getSens02(),
        }
        return jsonify(message)  # serialize and use JSON headers

@app.route('/posttmp', methods=['GET', 'POST'])
def postTemp():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json(force=True))  # parse as JSON
        #exportManager.saveTmp(request.get_json(force=True))
        print('DummyExportTMP')
        return 'OK', 200

    # GET request
    else:
        message = "this is used to recieve the temporary data"
        return jsonify(message)  # serialize and use JSON headers

@app.route('/postexport', methods=['GET', 'POST'])
def postExport():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json(force=True))  # parse as JSON
        #exportManager.export(request.get_json(force=True))
        print('DummyExport')
        return 'OK', 200

    # GET request
    else:
        message = "this is used to recieve the export"
        return jsonify(message)  # serialize and use JSON headers



@app.route('/posteyetrack', methods=['GET', 'POST'])
def postEyeTrack():
    # POST request
    if request.method == 'POST':
        #print('Incoming..')
        #print(request.get_json(force=True))  # parse as JSON
        #exportManager.logEyeTrack(request.get_json(force=True))

        return 'OK', 200

    # GET request
    else:
        message = "this is used to recieve the export"
        return jsonify(message)  # serialize and use JSON headers



@app.route('/postqr', methods=['GET', 'POST'])
def postQR():
    # POST request
    if request.method == 'POST':
        print('Incoming..')
        print(request.get_json(force=True))  # parse as JSON
        #exportManager.logQRTrack(request.get_json(force=True))

        return 'OK', 200

    # GET request
    else:
        message = "this is used to recieve the export"
        return jsonify(message)  # serialize and use JSON headers




if __name__ == "__main__":
   #app.run(threaded=False)
   app.run(use_reloader=False, host="192.168.2.100", threaded=False)
