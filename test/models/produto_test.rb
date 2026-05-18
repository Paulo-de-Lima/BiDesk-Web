require "test_helper"

class ProdutoTest < ActiveSupport::TestCase
  test "buscar ignora maiúsculas e minúsculas" do
    Produto.create!(nome: "Sal", categoria: "Alimentos", quantidade: 10, preco: 1, valor_minimo: 2)

    assert_includes Produto.buscar("sal"), Produto.find_by!(nome: "Sal")
    assert_includes Produto.buscar("SAL"), Produto.find_by!(nome: "Sal")
  end

  test "lista_filtrada combina busca e categoria" do
    sal = Produto.create!(nome: "Sal refinado", categoria: "Temperos", quantidade: 10, preco: 1, valor_minimo: 2)
    Produto.create!(nome: "Pimenta", categoria: "Temperos", quantidade: 5, preco: 2, valor_minimo: 1)

    resultados = Produto.lista_filtrada({ busca: "sal refinado", categoria: "Temperos" })
    assert_equal [ sal ], resultados.to_a
  end
end
