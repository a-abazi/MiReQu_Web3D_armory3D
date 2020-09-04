import serial
import time

class rotEncoderInterface():

    def __init__(self,  comPort:str):
        self.ser = serial.Serial(comPort, 9600)
        time.sleep(.01)
        self.ser.write("<check>".encode("utf8"))
        print("arduino at USB port " +comPort+" is " + self.posRead())
        time.sleep(.01)

    def getPos(self):
        self.ser.write("<get00>".encode("utf8"))
        return int(self.posRead())

    def posRead(self):
        b = self.ser.readline()
        string_n = b.decode()  # decode byte string into Unicode
        string = string_n.rstrip()  # remove \n and \r
        return  string  # convert string to float

    def close(self):
        self.ser.close()


if __name__ == '__main__':
    rEncoder = rotEncoderInterface("COM5")
    for i in range(100):
        print(rEncoder.getPos())
        time.sleep(0.1)
    rEncoder.close()