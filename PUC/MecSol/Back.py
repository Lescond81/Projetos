import numpy as np
import numpy.linalg as la
import math

# funções

def cosseno_diretor_x(i, j, nos):
    dx = nos[j][0] - nos[i][0]
    dy = nos[j][1] - nos[i][1]
    L = math.hypot(dx, dy)
    if L == 0:
        return 0
    return dx /L

def cosseno_diretor_y(i, j, nos):
    dx = nos[j][0] - nos[i][0]
    dy = nos[j][1] - nos[i][1]
    L = math.hypot(dx, dy)
    if L == 0:
        return 0
    return dy / L

# nós
n_nos = int(input("Número de nós:"))
nos    = []
for i in range(n_nos):
    x = float(input(f"x do nó {i}: "))
    y = float(input(f"y do nó {i}: "))
    nos.append([x, y])

# barras
n_barras = int(input("\nNúmero de barras: "))
barras = []

# 

def Pontos():
    A = []
    B = []
    C = []
    D = []
    E = []
    F = []
    G = []
    H = []
    I = []
    J = []
    K = []
    L = []
    M = []
    N = []
    O = []
    P = []
    Q = []
    R = []
    S = []
    T = []
    U = []
    V = []
    W = []
    X = []
    Y = []
    Z = []
 
    letras = (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z)

Pontos()

def Forcas_ext():
    FA = []
    FB = []
    FC = []
    FD = []
    FE = []
    FF = []
    FG = []
    FH = []
    FI = []
    FJ = []
    FK = []
    FL = []
    FM = []
    FN = []
    FO = []
    FP = []
    FQ = []
    FR = []
    FS = []
    FT = []
    FU = []
    FV = []
    FW = []
    FX = []
    FY = []
    FZ = []
 
    F_ext = (FA, FB, FC, FD, FE, FF, FG, FH, FI, FJ, FK, FL, FM, FN, FO, FP, FQ, FR, FS, FT, FU, FV, FW, FX, FY, FZ)

Forcas_ext()

print(F_ext[0])

for i in range(len(F_ext)):
    F_ext[i] = [A, 10, 30]
    #if F_ext[i] != 0:
        #temp = F_ext[i][2]*math.cos(F_ext[i][3])
    break

print(F_ext[0])