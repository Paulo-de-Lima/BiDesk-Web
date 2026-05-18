module ManutencaoHelper
  def manutencao_filtros_ativos?
    params[:status].present? || params[:equipamento].present?
  end
end
