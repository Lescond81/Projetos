import numpy as np
import numpy.linalg as la
import math

# funções

def segmentos_cruzam(p1, p2, p3, p4):
    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    d1 = cross(p3, p4, p1)
    d2 = cross(p3, p4, p2)
    d3 = cross(p1, p2, p3)
    d4 = cross(p1, p2, p4)
    if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
        return True
    return False

def verificar_cruzamentos(nos, barras):
    cruzamentos = []
    for i in range(len(barras)):
        for j in range(i + 1, len(barras)):
            a1, b1 = barras[i]
            a2, b2 = barras[j]
            if a1 in (a2, b2) or b1 in (a2, b2):
                continue
            p1 = (nos[a1][0], nos[a1][1])
            p2 = (nos[b1][0], nos[b1][1])
            p3 = (nos[a2][0], nos[a2][1])
            p4 = (nos[b2][0], nos[b2][1])
            if segmentos_cruzam(p1, p2, p3, p4):
                cruzamentos.append(f"Barra {i} cruza com Barra {j}")
        return cruzamentos
    

# CÁLCULO DE TRELIÇA!!!
def solve(dados: dict):
    def resolver_trelica(nos, barras, vinculos, forcas):
        N, M = len(nos), len(barras)
        n_reacoes = sum([2 if v["tipo"] == "pino" else 1 for v in vinculos])
        graus_de_lib = 2 * N

        if graus_de_lib != M + n_reacoes:
            return {"erro": "Treliça instável"}
        
        A = np.zeros((graus_de_lib, M + n_reacoes))
        b = np.zeros(graus_de_lib)

        for col, (a, j) in enumerate(barras):
            dx = nos[j][0] - nos[a][0]
            dy = nos[j][1] - nos[a][1]
            L = np.sqrt(dx**2 + dy**2)

            A[2*a, col] = dx/L
            A[2*a+1, col] = dy/L
            A[2*j, col] = -dx/L
            A[2*j+1, col] = -dy/L

        for f in forcas:
            no = f["no"]
            b[2*no] = f["fx"]
            b[2*no+1] = f["fy"]

        col = M
        for v in vinculos: 
            no = v["no"]
            if v["tipo"] == "pino":
                A[2*no, col] = 1; A[2*no+1, col+1] = 1; col += 2
            else:
                A[2*no+1, col] = 1; col += 1

        x = np.linalg.solve(A,b)
        return {"status": "sucesso", "resultados": x.tolist()}

    try:
        nos = dados["nos"]
        barras = dados["barras"]
        forcas = dados["forcas"]

        if "vinculos" in dados:
            vinculos = dados["vinculos"]
        else:
            vinculos = []   # cria lista vazia

        nos_lista = [[n["x"], n["y"]] for n in nos]
        barras_lista = [[b["start"], b["end"]] for b in barras]

        cruzamentos = verificar_cruzamentos(nos_lista, barras_lista)
        if cruzamentos: 
            return {"erro": "Cruzamento destacado", "detalhes": cruzamentos}
        
        forcas_lista = []

        for f in forcas: 
            if "fx" in f:
                valor_fx = f["fx"]
            else:
                valor_fx = 0

            if "fy" in f:
                valor_fy = f["fy"]
            else:
                valor_fy = 0

            nova_forca = {"no": f["no"], "fx": valor_fx, "fy": valor_fy}
            forcas_lista.append(nova_forca)

        # chama o cálculo :)
        return resolver_trelica(nos_lista, barras_lista, vinculos, forcas_lista)
    

    except KeyError:
        return {"erro": "Você esqueceu de enviar um campo obrigatório!!!"}
    except TypeError:
        return {"erro": "Você mandou um dado no formato errado!!!"}
    except:
        return {"erro": "Aconteceu um erro desconhecido."}