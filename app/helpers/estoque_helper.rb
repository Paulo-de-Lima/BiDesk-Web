module EstoqueHelper
  def estoque_filtros_ativos?
    params[:busca].present? || params[:categoria].present?
  end
end
