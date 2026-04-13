class DashboardController < ApplicationController
  def index
    @ultima_atualizacao = Time.current

    @total_clientes = Cliente.count
    @total_produtos = Produto.count
    @produtos_baixo_estoque = Produto.baixo_estoque.count
    @manutencoes_pendentes = Manutencao.pendentes.count
    
    mes_atual = Date.current.month
    ano_atual = Date.current.year
    @receitas_mes = TransacaoFinanceira.receitas.por_mes(ano_atual, mes_atual).sum(:valor)
    @despesas_mes = TransacaoFinanceira.despesas.por_mes(ano_atual, mes_atual).sum(:valor)
    @saldo_mes = @receitas_mes - @despesas_mes
    
    @ultimas_transacoes = TransacaoFinanceira.recentes.limit(5)
    @ultimos_clientes = Cliente.recentes.limit(5)
    @manutencoes_recentes = Manutencao.recentes.limit(5)
  end
end
