import os
import matplotlib.pyplot as plt
from ast import literal_eval as make_tuple

myIndex = int(input("Plotindex: "))

x = []
y = []

currDir = os.path.dirname(__file__)

path = currDir + "/data/ältestesLw/ältestesLw%s.txt"% myIndex

with open(path) as data:
    data = data.read().split(";")
    data.pop(-1)
    for i in data:
        x.append(make_tuple(i)[0])
        y.append(make_tuple(i)[1])
    plt.plot(x,y)
    plt.xlabel("Jahre")
    plt.ylabel("Alter in Jahren")
    plt.show()
    
x = []
y = []

path = currDir + "/data/durchschnittsLw/durchschnittsLw%s.txt"% myIndex

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
