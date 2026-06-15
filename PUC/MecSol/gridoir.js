var A = board.create('point', [2, 1], {name: 'A'});
var f = board.create(
    'functiongraph',
    [(x) => 0.5 * x ** 2 - 2 * x],
    {strokeWidth: 3}
);

// Parte para digitar no html e adicionar um ponto no gráfico
const button = document.getElementById('Butao');
const inputElement = document.getElementById('Funcao');

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
    board.create(
        'point',
        [x, y]
    );
});

