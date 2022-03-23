import numpy as np
import matplotlib.pyplot as plt
import json


def convert_toJson(fileNameNPY,fileNameJsoN):
    ## Convertiert das numpy array zum JsoN format, das ist aber nicht die Form die der Export haben sollte

    import json
    data = np.load(fileNameNPY,allow_pickle=True)#[1:,:]

    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            if (type(data[i,j])==np.ndarray): data[i,j] = data[i,j].tolist()
            if (type(data[i,j])==np.float64): data[i,j] = float(data[i,j])


    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            print (type(data[i,j]))

    dict = {"data":data.tolist()}

    json = json.dumps(dict)
    f = open(fileNameJsoN,"w")
    f.write(json)
    f.close()

def load_Json(fileNameJsoN):
    import json
    json = json.load(open(fileNameJsoN,"r"))

    return json



def calc_Sparameter(array):
    sumCC = np.zeros(16)
    #print (array.shape)

    # Summe der Zählraten, mit 10 dividiert um die counts zu erhalten
    for i in range(16):
        sumCC[i] = np.sum(array[i+1,-1])/10

    CAB   = (sumCC[0]+sumCC[1]-sumCC[2]-sumCC[3])/(sumCC[0]+sumCC[1]+sumCC[2]+sumCC[3])
    CABS  = (sumCC[4]+sumCC[5]-sumCC[6]-sumCC[7])/(sumCC[4]+sumCC[5]+sumCC[6]+sumCC[7])
    CASBS = (sumCC[8]+sumCC[9]-sumCC[10]-sumCC[11])/(sumCC[8]+sumCC[9]+sumCC[10]+sumCC[11])
    CASB  = (sumCC[12]+sumCC[13]-sumCC[14]-sumCC[15])/(sumCC[12]+sumCC[13]+sumCC[14]+sumCC[15])

    return abs(CAB-CABS+CASBS+CASB)


if __name__ == '__main__':
    #convert_toJson("20210319_sParameter.npy","20210319_sParameter.json")
    data_asList = load_Json("20210319_sParameter.json")["data"]

    data_asArray = np.array(data_asList)

    print("S = {:}".format(calc_Sparameter(data_asArray)))




