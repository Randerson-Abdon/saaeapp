class ProdutosModel {
  final String id;
  final String nome;
  final String imagem;
  final String categoria;
  final double valor;
  final double desconto;
  final double avaliacoes;

  ProdutosModel(
      {this.id,
      this.nome,
      this.imagem,
      this.categoria,
      this.valor,
      this.desconto,
      this.avaliacoes});
}

final produtos = [
  ProdutosModel(
    id: '1',
    nome: 'X-Tudo',
    imagem: 'assets/images/01.png',
    categoria: 'Sanduíches',
    valor: 50,
    desconto: 3,
    avaliacoes: 5,
  ),
  ProdutosModel(
    id: '2',
    nome: 'Pizza Calabresa',
    imagem: 'assets/images/02.png',
    categoria: 'Pizza',
    valor: 25,
    desconto: 2,
    avaliacoes: 4,
  ),
];
