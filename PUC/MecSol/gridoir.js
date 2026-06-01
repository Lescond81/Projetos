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
  // Cria uma constante com o valor digitado
  const inputValue = inputElement.value;
  console.log(inputValue); 
});

let D = board.create('point',[inputValue, inputValue], {name: 'D'});