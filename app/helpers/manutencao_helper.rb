module ManutencaoHelper
  MANUTENCAO_STATUS_OPCOES = [
    [ "Pendente", "pendente" ],
    [ "Concluída", "concluida" ]
  ].freeze

  def manutencao_status_opcoes
    MANUTENCAO_STATUS_OPCOES
  end

  def manutencao_filtros_ativos?
    params[:busca].present? || params[:status].present? || params[:equipamento].present?
  end

  def manutencao_filtros_painel_ativos?
    params[:status].present? || params[:equipamento].present?
  end

  def manutencao_status_label(status)
    { "pendente" => "Pendente", "concluida" => "Concluída" }[status] || status.to_s.humanize
  end

  def produto_options_para_manutencao(produtos)
    produtos.map { |p| [ "#{p.nome} (#{p.quantidade} em estoque)", p.id ] }
  end
end
