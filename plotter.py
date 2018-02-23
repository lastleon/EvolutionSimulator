import os
import matplotlib.pyplot as plt
from ast import literal_eval as make_tuple

myIndex = int(input("Plotindex: "))

x = []
y = []

currDir = os.path.dirname(__file__)

path = currDir + "/data/ältestesLw/ältestesLw%s.txt"% myIndex

try:
    with open(path) as data:
        data = data.read().split(";")
        data.pop(-1)

        lastID = -1;
        
        for i in data:
            xCoordinate = make_tuple(i)[0]
            yCoordinate = make_tuple(i)[1]
            
            
            
            x.append(make_tuple(i)[0])
            y.append(make_tuple(i)[1])

              
        plt.plot(x,y)
        plt.xlabel("Jahre")
        plt.ylabel("Alter in Jahren")
        plt.show()
except:
    pass

x = []
y = []

path = currDir + "/data/durchschnittsLw/durchschnittsLw%s.txt"% myIndex

try:
    with open(path) as data:
        data = data.read().split(";")
        data.pop(-1)
        for i in data:
            x.append(make_tuple(i)[0])
            y.append(make_tuple(i)[1])
        plt.plot(x,y)
        plt.xlabel("Jahre")
        plt.ylabel("Durchschnittsalter in Jahren")
        plt.show()
except:
    pass

x = []
y = []

path = currDir + "/data/durchschnittsFitnessLw/durchschnittsFitnessLw%s.txt"% myIndex

try:
    with open(path) as data:
        data = data.read().split(";")
        data.pop(-1)
        for i in data:
            x.append(make_tuple(i)[0])
            y.append(make_tuple(i)[1])
        plt.plot(x,y)
        plt.xlabel("Jahre")
        plt.ylabel("Durchschnittsfitness")
        plt.show()
except:
    pass

x = []
y1 = []
y2 =[]

path = currDir + "/data/todeUndGeburtenLw/todeUndGeburtenLw%s.txt"% myIndex

try:
    with open(path) as data:
        data = data.read().split(";")
        data.pop(-1)
        for i in data:
            x.append(make_tuple(i)[0])
            y1.append(make_tuple(i)[1])
            y2.append(make_tuple(i)[2])
        plt.plot(x,y1,"r-")
        plt.plot(x,y2,"g-")
        plt.xlabel("Jahre")
        plt.ylabel("Tode und Geburten")
        plt.show()
except:
    pass

def plotIDs(dataTuple, currentPlot):
    print("calleds")
    currentPlot.plot(dataTuple[0], dataTuple[1], "bx", markersize=4)
    
