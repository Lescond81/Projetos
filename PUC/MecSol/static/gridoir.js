// Parte para digitar no html e adicionar um ponto no gráfico
const button = document.getElementById('Butao');
const inputElement = document.getElementById('Funcao');
const Conectar = document.getElementById('connect');
const Aplicar = document.getElementById('ap_forca');
const Apoio = document.getElementById('Ap_apoio');
let nos = []; // Vetor com os valores dos nós
let barras = []; // Vetor com a conexão entre os nós
let forcas = []; // Vetor com as forças
let suporte = []; // Vetor com os suportes

// Botão para dar submit no valor digitado
button.addEventListener('click', () => {
    const x =
      Number(
        document.getElementById("x").value
      );

    const y =
      Number(
        document.getElementById("y").value
      );

    let pointo =
      board.create(
        'point',
        [x, y],
        {
            name:
                nos.length
        }
      );
    nos.push({
        id: nos.length,
        x,
        y,
        object: pointo
      });
});

// Função para conectar 2 pontos entre si
function conectar(id1, id2){

    if(
        !nos[id1] ||
        !nos[id2]
    ){
        alert(
            "Ponto inexistente"
        );

        return;
    }

    if(id1 === id2){

        alert(
            "Não conecte um ponto nele mesmo"
        );

        return;
    }

    const ponto1 =
        nos[id1];

    const ponto2 =
        nos[id2];

    const barra =
        board.create(
            "segment",
            [
                ponto1.object,
                ponto2.object
            ]
        );

    barras.push({
        start: id1,
        end: id2,
        object: barra
    });

}

Conectar.addEventListener('click', () => {
      const prim =
        Number(
            document.getElementById("prim").value
        );

      const seg =
        Number(
            document.getElementById("seg").value
        );

    conectar(prim,seg);
});

// Função para as forlas(fuciona)
function aplicarForca(
    noId,
    modul,
    direcao
){

    const node =
        nos[noId];

    let dx = 0;
    let dy = 0;

    if(direcao==="up")
        dy = modul;

    if(direcao==="down")
        dy = -modul;

    if(direcao==="right")
        dx = modul;

    if(direcao==="left")
        dx = -modul;

    const end =
        board.create(
            "point",
            [
                node.x + dx/100,
                node.y + dy/100
            ],
            {
                visible:true
            }
        );

    board.create(
        "arrow",
        [
            end,
            node.object
        ]
    );
}

Aplicar.addEventListener('click', () => {
      let ponto =
      Number(
        document.getElementById("ponto").value
      );

      let modulo =
      Number(
        document.getElementById("modulo").value
      );

      let dir =
      Number(
        document.getElementById("direcao").value
      );

    aplicarForca(ponto,modulo,dir);
      
});

// Função para criar um pino trianglar
function criarPino(noId){

    const p =nos[noId];

    board.create(
        "segment",
        [
            [p.x-0.3,p.y-0.4],
            [p.x,p.y]
        ]
    );

    board.create(
        "segment",
        [
            [p.x+0.3,p.y-0.4],
            [p.x,p.y]
        ]
    );

    board.create(
        "segment",
        [
            [p.x-0.3,p.y-0.4],
            [p.x+0.3,p.y-0.4]
        ]
    );
};

// Função para criar um rolete(por acaso triangular tambem...)
function criarRolete(noId){

    const r =nos(noId);

    board.create(
        "circle",
        [
            [nos[nodeId].x-0.15,
             nos[nodeId].y-0.6],
            0.05
        ]
    );

    board.create(
        "circle",
        [
            [nos[nodeId].x+0.15,
             nos[nodeId].y-0.6],
            0.05
        ]
    );
};

// Aplicar o apoio
Apoio.addEventListener('click', () => {
    let nos=
    Number(
        document.getElementById("pApoio").value
    );
    let tipo=
        document.getElementById("tipo").value

    if(tipo==="pino")
        criarPino(nos); 
    if(tipo==="rolete")
        criarRolete(nos);

});
