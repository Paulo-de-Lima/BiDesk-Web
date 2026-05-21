class DashboardController < ApplicationController
  MESES_PT = %w[jan fev mar abr mai jun jul ago set out nov dez].freeze

  FLUXO_PERIODOS = {
    "semana"  => { label: "Últimas 4 semanas",   step: :semana, count: 4  },
    "mes6"    => { label: "Últimos 6 meses",     step: :mes,    count: 6  },
    "mes12"   => { label: "Últimos 12 meses",    step: :mes,    count: 12 },
    "ano2"    => { label: "Últimos 2 anos",      step: :ano,    count: 2  }
  }.freeze
  FLUXO_PERIODO_PADRAO = "mes6".freeze

  def index
    @ultima_atualizacao = Time.current

    @total_clientes = Cliente.count
    @total_produtos = Produto.count
    @produtos_baixo_estoque = Produto.baixo_estoque.count
    @manutencoes_pendentes = Manutencao.pendentes.count

    hoje = Date.current
    @receitas_mes = TransacaoFinanceira.receitas.por_mes(hoje.year, hoje.month).sum(:valor)
    @despesas_mes = TransacaoFinanceira.despesas.por_mes(hoje.year, hoje.month).sum(:valor)
    @saldo_mes = @receitas_mes - @despesas_mes

    mes_anterior = hoje.prev_month
    receitas_mes_anterior = TransacaoFinanceira.receitas.por_mes(mes_anterior.year, mes_anterior.month).sum(:valor)
    despesas_mes_anterior = TransacaoFinanceira.despesas.por_mes(mes_anterior.year, mes_anterior.month).sum(:valor)
    saldo_mes_anterior = receitas_mes_anterior - despesas_mes_anterior

    @variacao_receitas = pct_variacao(@receitas_mes, receitas_mes_anterior)
    @variacao_despesas = pct_variacao(@despesas_mes, despesas_mes_anterior)
    @variacao_saldo    = pct_variacao(@saldo_mes, saldo_mes_anterior)

    @fluxo_periodos    = FLUXO_PERIODOS
    @fluxo_periodo_key = FLUXO_PERIODOS.key?(params[:periodo]) ? params[:periodo] : FLUXO_PERIODO_PADRAO
    @fluxo_mensal      = fluxo_serie(FLUXO_PERIODOS[@fluxo_periodo_key])

    @despesas_por_categoria = TransacaoFinanceira
      .despesas
      .por_mes(hoje.year, hoje.month)
      .group(:categoria)
      .sum(:valor)
      .transform_values(&:to_f)
      .sort_by { |_, v| -v }
      .first(6)
      .to_h

    @receitas_por_categoria = TransacaoFinanceira
      .receitas
      .por_mes(hoje.year, hoje.month)
      .group(:categoria)
      .sum(:valor)
      .transform_values(&:to_f)
      .sort_by { |_, v| -v }
      .first(6)
      .to_h

    @status_manutencoes = {
      "Pendente"  => Manutencao.where(status: "pendente").count,
      "Concluída" => Manutencao.where(status: "concluida").count
    }

    @ultimas_transacoes = TransacaoFinanceira.recentes.limit(5)
    @ultimos_clientes = Cliente.recentes.limit(5)
    @manutencoes_recentes = Manutencao.recentes.limit(5)
  end

  private

  def pct_variacao(atual, anterior)
    atual = atual.to_f
    anterior = anterior.to_f
    return nil if anterior.zero? && atual.zero?
    return 100.0 if anterior.zero?
    ((atual - anterior) / anterior.abs) * 100.0
  end

  def fluxo_serie(periodo)
    hoje = Date.current
    case periodo[:step]
    when :semana
      semanas(periodo[:count], hoje)
    when :mes
      meses(periodo[:count], hoje)
    when :ano
      anos(periodo[:count], hoje)
    end
  end

  def semanas(n, hoje)
    fim = hoje.end_of_week(:monday)
    (0...n).map { |i| (fim - (n - 1 - i).weeks).beginning_of_week(:monday) }.map do |inicio_semana|
      fim_semana = inicio_semana.end_of_week(:monday)
      range = inicio_semana..[fim_semana, hoje].min
      receitas = TransacaoFinanceira.receitas.where(data: range).sum(:valor).to_f
      despesas = TransacaoFinanceira.despesas.where(data: range).sum(:valor).to_f
      {
        label: "#{inicio_semana.strftime('%d/%m')}",
        receitas: receitas,
        despesas: despesas,
        saldo: receitas - despesas
      }
    end
  end

  def meses(n, hoje)
    base = hoje.beginning_of_month
    (0...n).map { |i| base.prev_month(n - 1 - i) }.map do |inicio_mes|
      receitas = TransacaoFinanceira.receitas.por_mes(inicio_mes.year, inicio_mes.month).sum(:valor).to_f
      despesas = TransacaoFinanceira.despesas.por_mes(inicio_mes.year, inicio_mes.month).sum(:valor).to_f
      {
        label: "#{MESES_PT[inicio_mes.month - 1]}/#{inicio_mes.strftime('%y')}",
        receitas: receitas,
        despesas: despesas,
        saldo: receitas - despesas
      }
    end
  end

  def anos(n, hoje)
    # Cada ano vira 12 pontos (um por mês) para ainda permitir comparação
    base = hoje.beginning_of_month
    total_meses = n * 12
    (0...total_meses).map { |i| base.prev_month(total_meses - 1 - i) }.map do |inicio_mes|
      receitas = TransacaoFinanceira.receitas.por_mes(inicio_mes.year, inicio_mes.month).sum(:valor).to_f
      despesas = TransacaoFinanceira.despesas.por_mes(inicio_mes.year, inicio_mes.month).sum(:valor).to_f
      {
        label: "#{MESES_PT[inicio_mes.month - 1]}/#{inicio_mes.strftime('%y')}",
        receitas: receitas,
        despesas: despesas,
        saldo: receitas - despesas
      }
    end
  end
end
