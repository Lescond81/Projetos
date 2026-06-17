
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
      Number( document.getElementById("x").value);

    const y =
      Number(document.getElementById("y").value);

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

// Função para as forças(fuciona)
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
        dy = -modul;

    if(direcao==="down")
        dy = modul;

    if(direcao==="right")
        dx = -modul;

    if(direcao==="left")
        dx = modul;

    const scale = 1;
    const end =
        board.create(
            "point",
            [
                node.x + (dx !== 0? Math.sign(dx) * scale: 0),
                node.y + (dy !== 0? Math.sign(dy) * scale: 0)
            ],
            {
                visible:false
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
        document.getElementById("direcao").value;

    aplicarForca(ponto,modulo,dir);

    let fx = 0, fy = 0;
    if (dir === "up") fy = modulo
    if (dir === "down") fy = -modulo
    if (dir === "left") fx = modulo
    if (dir === "right") fx = -modulo

    forcas.push({ no: ponto, fx, fy});
      
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

    const r =nos[noId];

    board.create(
        "circle",
        [
            [nos[noId].x-0.15,
             nos[noId].y-0.6],
            0.05
        ]
    );

    board.create(
        "circle",
        [
            [nos[noId].x+0.15,
             nos[noId].y-0.6],
            0.05
        ]
    );
};

// Aplicar o apoio
Apoio.addEventListener('click', () => {
    let pApoio=
    Number(
        document.getElementById("pApoio").value
    );
    let tipo=
        document.getElementById("tipo").value

    if(tipo==="pino")
        criarPino(pApoio); 
    if(tipo==="rolete")
        criarRolete(pApoio);

    suporte.push({ no: pApoio, tipo});

});

//resumo
document.getElementById("resumo").addEventListener("click", () => {
    let html = "";

    // nos
    html += "<h4>Nós</h4>";
    if(nos.length === 0) html += "<p>Nenhum nó adicionado</p>";
    nos.forEach(n => {
        html += `<p>Nó ${n.id}: (${n.x}, ${n.y})</p>`;
    });

    // barras
    html += "<h4>Barras</h4>";
    if(barras.length === 0) html += "<p>Nenhuma barra adicionada</p>";
    barras.forEach((b, i) => {
        html += `<p>Barra ${i}: Nó ${b.start} → Nó ${b.end}</p>`;
    });

    // forças
    html += "<h4>Forças</h4>";
    if(forcas.length === 0) html += "<p>Nenhuma força aplicada</p>";
    forcas.forEach((f, i) => {
        const seta = { up:"↑", down:"↓", left:"←", right:"→" };
        html += `<p>Força ${i}: Nó ${f.no} — fx: ${f.fx}N, fy: ${f.fy}N</p>`;
    });

    // apoios
    html += "<h4>Suportes</h4>";
    if(suporte.length === 0) html += "<p>Nenhum suporte adicionado</p>";
    suporte.forEach((s, i) => {
        html += `<p>Suporte ${i}: Nó ${s.no} — ${s.tipo}</p>`;
    });

    document.getElementById("conteudo-modal").innerHTML = html;
    document.getElementById("modal").style.display = "block";
    document.getElementById("overlay").style.display = "block";
});

// fechando modal
document.getElementById("fechar").addEventListener("click", () => {
    document.getElementById("modal").style.display = "none";
    document.getElementById("overlay").style.display = "none";
});


document.querySelector(".Calcular").addEventListener("click", async() => {
    const Response = await fetch("http://127.0.0.1:5000/Back", {
    method: 'POST',
    headers: {"Content-type": 'application/JSON'},
    body: JSON.stringify({nos, barras, suporte, forcas})
});

const resultado = await Response.json();

if (resultado.erro){
    alert ("Erro " + resultado.erro);
} else {
    alert ("Resultados " + resultado.resultados.join(", "));
}
})


