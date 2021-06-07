import time
import os
import json
import numpy

class ExportManager():
    def __init__(self, groupName: str,type: str, exportPath: str):
        self.groupName = groupName
        self.exportPath = exportPath
        if (not os.path.exists(self.exportPath)): os.mkdir(self.exportPath)
        self.exportPath = os.path.join(self.exportPath, type)
        if (not os.path.exists(self.exportPath)): os.mkdir(self.exportPath)
        self.exportPath = os.path.join(self.exportPath, groupName)
        if (not os.path.exists(self.exportPath)): os.mkdir(self.exportPath)
        self.exportPathTmp = os.path.join(self.exportPath, "tmp")
        if (not os.path.exists(self.exportPathTmp)): os.mkdir(self.exportPathTmp)

        self.eyeTrackFolder = os.path.join(self.exportPath, "eyeTrackLog")
        if (not os.path.exists(self.eyeTrackFolder)): os.mkdir(self.eyeTrackFolder)

        self.eyeTrackFilePath = self.eyeTrackFolder + "/"+groupName + "_EyeTrackLog_"
        self.eyeTrackFileNumber = 0
        self.eyeTrackFileEnding = ".txt"
        self.fileSizeLimit = 1024 * 1024 * 50 ## last number gives mB
        self.CheckEyeTrackLog()

    #def saveTmp(self, jsonObj:str): ## SAme as save TMP, Quick Hotfix, because in wrong funtion in Unity is called
    def export(self, jsonObj:str):
        import numpy as np

        try:
            js_Dict = json.loads(jsonObj)
        except:
            js_Dict = jsonObj

        #Check dictionary for correct keys
        if ("h" in js_Dict): # Workaround for specific case in formatting
            js_Dict = js_Dict["h"]
            print(js_Dict)

        if (not "Exercise" in js_Dict ) or (not "Subexercise" in js_Dict)\
                or (not "xAxis" in js_Dict) or (not "yAxis1" in js_Dict):
            print("Keys not correctly specified in Json File")
            return

        # setup/check directories
        currpath = os.path.join(self.exportPath,js_Dict["Exercise"])
        if (not os.path.exists(currpath)): os.mkdir(currpath)
        currpath = os.path.join(currpath, js_Dict["Subexercise"])
        if (not os.path.exists(currpath)): os.mkdir(currpath)
        currpath = os.path.join(currpath, "tmp")
        if (not os.path.exists(currpath)): os.mkdir(currpath)


        # read data from json object and put into list
        data = []
        data.append(js_Dict["xAxis"])

        for i in range(10):
            if "yAxis{:}".format(i) in js_Dict:
                data.append(js_Dict["yAxis{:}".format(i)])

        # create Timestamp for filename of last data
        current_time = time.localtime()
        tmpStamp = time.strftime('%Y-%m-%d_%H-%M-%S', current_time)

        # remove oldes file, only 20 files should be in a tmp folder,  numpy module is used for saving
        files = os.listdir(currpath)
        if (len(files)>19):
            os.remove(os.path.join(currpath,files[0]))


        np.savetxt(currpath +"/"+ tmpStamp+".txt",np.array(data))

    def saveTmp(self, jsonObj:str):
        import numpy as np

        try:
            js_Dict = json.loads(jsonObj)
        except:
            js_Dict = jsonObj

        #Check dictionary for correct keys
        if ("h" in js_Dict): # Workaround for specific case in formatting
            js_Dict = js_Dict["h"]
            print(js_Dict)

        if (not "Exercise" in js_Dict ) or (not "Subexercise" in js_Dict)\
                or (not "xAxis" in js_Dict) or (not "yAxis1" in js_Dict):
            print("Keys not correctly specified in Json File")
            return

        # setup/check directories
        currpath = os.path.join(self.exportPath,js_Dict["Exercise"])
        if (not os.path.exists(currpath)): os.mkdir(currpath)
        currpath = os.path.join(currpath, js_Dict["Subexercise"])
        if (not os.path.exists(currpath)): os.mkdir(currpath)
        currpath = os.path.join(currpath, "tmp")
        if (not os.path.exists(currpath)): os.mkdir(currpath)


        # read data from json object and put into list
        data = []
        data.append(js_Dict["xAxis"])

        for i in range(10):
            if "yAxis{:}".format(i) in js_Dict:
                data.append(js_Dict["yAxis{:}".format(i)])

        # create Timestamp for filename of last data
        current_time = time.localtime()
        tmpStamp = time.strftime('%Y-%m-%d_%H-%M-%S', current_time)

        # remove oldes file, only 20 files should be in a tmp folder,  numpy module is used for saving
        files = os.listdir(currpath)
        if (len(files)>19):
            os.remove(os.path.join(currpath,files[0]))


        np.savetxt(currpath +"/"+ tmpStamp+".txt",np.array(data))




    def DepRexport(self, jsonObj:str):
        import numpy as np
        try:
            js_Dict = json.loads(jsonObj)
        except:
            js_Dict = jsonObj
        # Check dictionary for correct keys
        if ("h" in js_Dict): # Workaround for specific case in formatting
            js_Dict = js_Dict["h"]
            print(js_Dict)

        if (not "Exercise" in js_Dict )or (not "Subexercise" in js_Dict) \
                or (not "FileName" in js_Dict)\
                or (not "xAxis" in js_Dict) or (not "yAxis1" in js_Dict):
            print("Keys not correctly specified in Json File")
            return

        # setup/check directories
        currpath = os.path.join(self.exportPath,js_Dict["Exercise"])
        if not os.path.exists(currpath): os.mkdir(currpath)
        currpath = os.path.join(currpath, js_Dict["Subexercise"])
        if not os.path.exists(currpath): os.mkdir(currpath)

        # read data from json object and put into list
        data = []
        data.append(js_Dict["xAxis"])
        for i in range(10):
            if "yAxis{:}".format(i) in js_Dict:
                data.append(js_Dict["yAxis{:}".format(i)])

        # Check if file already exists, if yes a number is added to the filename limit at 100 files, numpy module is used for saving
        if not os.path.isfile(os.path.join(currpath, js_Dict["FileName"])+".txt"):
            np.savetxt(os.path.join(currpath, js_Dict["FileName"])+".txt", np.array(data))
        else:
            for i in range(100):
                if not os.path.isfile(os.path.join(currpath, js_Dict["FileName"])+"_{:02d}.txt".format(i)):
                    np.savetxt(os.path.join(currpath, js_Dict["FileName"])+"_{:02d}.txt".format(i), np.array(data))
                    break


    def CheckEyeTrackLog(self,):
        isFile = os.path.isfile(self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding)
        header = "#Year;Month;Day;Hour;Min;Sec;mSec;dirX;dirY;dirZ;orgX;orgY;orgZ;targX;targY;targZ;target;\
                dataValid;calibValid;lowContiguity;scene;exercise;subExercise;\n"

        limitExceded = False
        if (not isFile):
            eyeTrackLog = open( self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding, "x")
            eyeTrackLog.write(header)
            eyeTrackLog.close()
        else:
            eyeTrackLog = open(self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding, "a")
            if (eyeTrackLog.tell() > self.fileSizeLimit): limitExceded = True
            eyeTrackLog.close()

            while (limitExceded): # Recursion of above, only with incrementing file number

                self.eyeTrackFileNumber += 1
                isFile = os.path.isfile(self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding)
                if (not isFile):
                    eyeTrackLog = open(self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding, "x")
                    eyeTrackLog.write(header)
                    eyeTrackLog.close()
                    limitExceded = False
                else:
                    eyeTrackLog = open(self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding, "a")
                    if (eyeTrackLog.tell() <= self.fileSizeLimit): limitExceded = False
                    eyeTrackLog.close()



    def logEyeTrack(self, jsonObj:str):
        self.CheckEyeTrackLog()
        try:
            js_Dict = json.loads(jsonObj)
        except:
            js_Dict = jsonObj

        #Check dictionary for correct keys
        if ("h" in js_Dict): # Workaround for specific case in formatting
            js_Dict = js_Dict["h"]
            print(js_Dict)

        if (not "dataValid" in js_Dict ) or (not "calibValid" in js_Dict)\
                or (not "time" in js_Dict) or (not "directionX" in js_Dict):
            print("Keys not correctly specified in Json File")
            return
        eyeTrackLog = open(self.eyeTrackFilePath + str(self.eyeTrackFileNumber) + self.eyeTrackFileEnding, "a")
        timeDayString = "{:};{:};{:};".format(js_Dict["timeYear"], js_Dict["timeMonth"],
                                              js_Dict["timeDay"])
        timeClockString = "{:};{:};{:};{:};".format(js_Dict["timeHour"], js_Dict["timeMin"],
                                                    js_Dict["timeSec"], js_Dict["timeMilliSec"])
        dirString = "{:};{:};{:};".format(js_Dict["directionX"],js_Dict["directionY"],js_Dict["directionZ"])
        originString = "{:};{:};{:};".format(js_Dict["originX"],js_Dict["originY"],js_Dict["originZ"])
        targetString = "{:};{:};{:};".format(js_Dict["targetX"],js_Dict["targetY"],js_Dict["targetZ"])
        calibrationString = "{:};{:};".format(js_Dict["dataValid"],js_Dict["calibValid"])
        sceneString = "{:};{:};{:};{:};".format(js_Dict["isLowContiguity"], js_Dict["scene"], js_Dict["exercise"], \
                                                js_Dict["subExercise"], )

        writeLine = timeDayString + timeClockString + dirString + originString + targetString + calibrationString + \
                    sceneString + "\n"
        eyeTrackLog.write(writeLine)

        '''
        eyeTrackLog.write( "{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};{:};".format(js_Dict["time"],\
                               js_Dict["directionX"],js_Dict["directionY"],js_Dict["directionZ"],\
                               js_Dict["originX"],js_Dict["originY"],js_Dict["originZ"], \
                               js_Dict["targetX"],js_Dict["targetY"],js_Dict["targetZ"], \
                               js_Dict["targetName"],js_Dict["dataValid"],\
                               js_Dict["calibValid"],js_Dict["isLowContiguity"],\
                               js_Dict["scene"],js_Dict["exercise"],\
                               js_Dict["subExercise"],\
                               ) +"\n")
        '''
        eyeTrackLog.close()


if __name__ == '__main__':
    exportWeb3D = ExportManager("BA-A-01_Test","Web3D","c:/ExportMiReQu/" )
    exportMR = ExportManager("BA-A-01_Test", "MR", "c:/ExportMiReQu/")


    tstJsonExport = '{"Exercise":"Hauptversuch", "Subexercise":"Aufgabe1"' \
                 ',"FileName": "TstName"'\
                 ',"xAxis": [0,1,2,3,4]' \
                 ',"yAxis1": [0.0,10.0,20.0,30.0,40.0]' \
                 ',"yAxis2": [0.0,12.0,22.0,32.0,42.0]' \
                 ',"yAxis3": [0.0,13.0,23.0,33.0,43.0]' \
                 ' }'


    exportMR.saveTmp(tstJsonExport)