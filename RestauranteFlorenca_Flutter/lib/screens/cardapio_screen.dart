import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/favorito.dart';
import '../services/api_service.dart';

class CardapioScreen extends StatefulWidget {
  const CardapioScreen({super.key});

  @override
  State<CardapioScreen> createState() => _CardapioScreenState();
}

class _CardapioScreenState extends State<CardapioScreen> {
  final Map<String, int> _favoritosMap = {};
  bool _isLoadingFavs = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritosUsuario();
  }

  Future<void> _carregarFavoritosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) {
      setState(() => _isLoadingFavs = false);
      return;
    }

    try {
      final response = await ApiService.obterFavoritos(usuarioId);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        setState(() {
          _favoritosMap.clear();
          for (var item in list) {
            final fav = Favorito.fromJson(item);
            _favoritosMap[fav.pratoNome] = fav.id;
          }
        });
      }
    } catch (e) {
      // Ignora erro de conexao
    } finally {
      if (mounted) setState(() => _isLoadingFavs = false);
    }
  }

  Future<void> _alternarFavorito(String nome, double preco) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login novamente para salvar favoritos.')),
      );
      return;
    }

    if (_favoritosMap.containsKey(nome)) {
      final favId = _favoritosMap[nome]!;
      try {
        final response = await ApiService.removerFavorito(favId);
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() => _favoritosMap.remove(nome));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🤍 $nome removido dos favoritos.')),
          );
        }
      } catch (e) {
        // Erro
      }
    } else {
      try {
        final fav = Favorito(usuarioId: usuarioId, pratoNome: nome, preco: preco);
        final response = await ApiService.adicionarFavorito(fav);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = jsonDecode(response.body);
          final newFavId = body['id'] ?? 0;
          setState(() => _favoritosMap[nome] = newFavId);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❤️ $nome salvo nos Favoritos!')),
          );
        }
      } catch (e) {
        // Erro
      }
    }
  }

  Future<void> _adicionarAoCarrinho(String nome, double preco) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carrinhoJsonStr = prefs.getStringList('carrinho') ?? [];

    List<dynamic> carrinhoList = carrinhoJsonStr.map((str) => jsonDecode(str)).toList();
    carrinhoList.add({'nome': nome, 'preco': preco, 'qtd': 1});

    List<String> newCarrinhoJsonStr = carrinhoList.map((obj) => jsonEncode(obj)).toList();
    await prefs.setStringList('carrinho', newCarrinhoJsonStr);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nome adicionado à comanda!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardápio Digital')),
      body: _isLoadingFavs
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSecao('🥗 ENTRADAS', [
                  {'nome': 'Salada verde com molho especial', 'desc': 'Mix de folhas nobres, tomate cereja e molho especial da casa.', 'preco': 28.0},
                  {'nome': 'Bruschetta tradicional', 'desc': 'Pão rústico tostado, tomates frescos marinados no azeite e manjericão.', 'preco': 32.0},
                  {'nome': 'Porção de batata frita', 'desc': 'Crocantes e douradas, servidas com maionese artesanal.', 'preco': 35.0},
                ]),
                _buildSecao('🍝 PRATOS PRINCIPAIS (ITALIANOS)', [
                  {'nome': 'Spaghetti à carbonara', 'desc': 'Massa fresca, guanciale, pecorino romano e gema de ovo.', 'preco': 65.0},
                  {'nome': 'Spaghetti ao pesto', 'desc': 'Massa artesanal ao molho pesto de manjericão e nozes.', 'preco': 58.0},
                  {'nome': 'Spaghetti com Almôndegas', 'desc': 'Spaghetti ao molho sugo com almôndegas de carne selecionada.', 'preco': 62.0},
                  {'nome': 'Lasanha à bolonhesa', 'desc': 'Camadas intercaladas com ragù de carne e molho bechamel.', 'preco': 72.0},
                  {'nome': 'Lasanha ao molho branco', 'desc': 'Massa artesanal com molho bechamel cremoso e parmesão.', 'preco': 68.0},
                ]),
                _buildSecao('🥘 RISOTOS ESPECIAIS', [
                  {'nome': 'Risotto al Funghi', 'desc': 'Arroz arbóreo cremoso com cogumelos frescos e queijo parmesão.', 'preco': 68.0},
                  {'nome': 'Risotto al Limone con Gamberi', 'desc': 'Risoto de limão siciliano com camarões grelhados no azeite.', 'preco': 78.0},
                  {'nome': 'Risotto alla Milanese', 'desc': 'Risoto cremoso com açafrão italiano e tutano.', 'preco': 74.0},
                ]),
                _buildSecao('🇧🇷 MODA BRASILEIRA (CULINÁRIA PLURAL)', [
                  {'nome': 'Prato Executivo', 'desc': 'Arroz, feijão caseiro, proteína à escolha e acompanhamento.', 'preco': 45.0},
                  {'nome': 'Bife com fritas', 'desc': 'Contra-filé acebolado, arroz branco, feijão e batatas fritas.', 'preco': 52.0},
                  {'nome': 'Virado à paulista', 'desc': 'Tutu de feijão, bisteca, couve refogada, ovo frito e banana.', 'preco': 55.0},
                  {'nome': 'Baião de Dois', 'desc': 'Feijão fradinho com arroz, queijo coalho e carne seca.', 'preco': 58.0},
                  {'nome': 'Feijoada Completa', 'desc': 'Feijoada tradicional com pertences, couve, farofa e laranjas.', 'preco': 68.0},
                ]),
                _buildSecao('🍷 LEMBRANÇAS ITALIANAS (DRINKS)', [
                  {'nome': 'Negroni', 'desc': 'Gin, Vermoute tinto e Campari.', 'preco': 38.0},
                  {'nome': 'Campari', 'desc': 'Bitter italiano servido com gelo e fatia de laranja.', 'preco': 32.0},
                  {'nome': 'Aperol Spritz', 'desc': 'Prosecco, Aperol e água com gás.', 'preco': 36.0},
                  {'nome': 'Limonata', 'desc': 'Refrescante limonada com xarope artesanal.', 'preco': 22.0},
                  {'nome': 'Soda Italiana', 'desc': 'Soda artesanal flavors (Maçã Verde, Frutas Vermelhas).', 'preco': 18.0},
                ]),
                _buildSecao('🥤 BEBIDAS REFRESCANTES', [
                  {'nome': 'Coca-Cola Lata', 'desc': 'Lata 350ml gelada.', 'preco': 8.0},
                  {'nome': 'Guaraná Antarctica Lata', 'desc': 'Lata 350ml gelada.', 'preco': 8.0},
                  {'nome': 'Sprite Lata', 'desc': 'Lata 350ml gelada.', 'preco': 8.0},
                  {'nome': 'Sucos Naturais', 'desc': 'Sabores: Laranja, Maracujá, Limão ou Abacaxi com Hortelã.', 'preco': 14.0},
                  {'nome': 'Água Mineral', 'desc': 'Com gás ou Sem gás (500ml).', 'preco': 6.0},
                  {'nome': 'Cervejas Especiais', 'desc': 'Garrafa ou lata selecionada.', 'preco': 16.0},
                  {'nome': 'Caipirinha Tradicional', 'desc': 'Cachaça artesanal, limão e açúcar.', 'preco': 28.0},
                  {'nome': 'Vinhos Selecionados', 'desc': 'Taça de vinho tinto Chianti ou branco seco.', 'preco': 35.0},
                ]),
                _buildSecao('☕ BEBIDAS QUENTES', [
                  {'nome': 'Chás Especiais', 'desc': 'Opções: Erva-doce, Camomila ou Chá Preto.', 'preco': 10.0},
                  {'nome': 'Café Expresso', 'desc': 'Café expresso tirado na hora.', 'preco': 8.0},
                  {'nome': 'Café Calipso', 'desc': 'Café expresso com licor de cacau e chantilly.', 'preco': 22.0},
                  {'nome': 'Irish Coffee (Café Irlandês)', 'desc': 'Café quente, uísque irlandês e camada de creme.', 'preco': 26.0},
                ]),
                _buildSecao('🍨 SOBREMESAS', [
                  {'nome': 'Pudim Tradicional', 'desc': 'Pudim de leite condensado com calda de caramelo.', 'preco': 18.0},
                  {'nome': 'Mousse Especial', 'desc': 'Sabores: Maracujá, Chocolate ou Limão.', 'preco': 20.0},
                  {'nome': 'Sorvete Artesanal', 'desc': '2 bolas de sorvete de creme ou chocolate.', 'preco': 18.0},
                  {'nome': 'Tigela de Açaí Personalizável', 'desc': 'Açaí cremoso com frutas e granola.', 'preco': 26.0},
                  {'nome': 'Petit Gateau', 'desc': 'Bolinho de chocolate quente com sorvete de creme.', 'preco': 32.0},
                  {'nome': 'Torta Gelada de Morango', 'desc': 'Fatia de torta de morango cremoso.', 'preco': 24.0},
                  {'nome': 'Tiramisù Tradizionale', 'desc': 'Biscoito savoiardi, expresso e creme de mascarpone.', 'preco': 28.0},
                  {'nome': 'Gelato Italiano', 'desc': 'Autêntico gelato italiano de pistache ou fiordilatte.', 'preco': 22.0},
                  {'nome': 'Panna Cotta', 'desc': 'Panna cotta cremosa com calda de frutas vermelhas.', 'preco': 24.0},
                ]),
              ],
            ),
    );
  }

  Widget _buildSecao(String titulo, List<Map<String, dynamic>> pratos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
        ),
        ...pratos.map((p) => _buildPratoCard(p['nome'], p['desc'], p['preco'])),
      ],
    );
  }

  Widget _buildPratoCard(String nome, String desc, double preco) {
    final bool isFav = _favoritosMap.containsKey(nome);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nome, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('R\$ ${preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? FlorencaApp.florencaWine : Colors.grey,
                  ),
                  onPressed: () => _alternarFavorito(nome, preco),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: FlorencaApp.florencaOlive, foregroundColor: Colors.white),
                  onPressed: () => _adicionarAoCarrinho(nome, preco),
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('+ Comanda'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
