module FinanceiroHelper
  def financeiro_filtros_ativos?
    params[:busca].present? || params[:tipo].present? || params[:categoria].present?
  end

  def financeiro_filtros_painel_ativos?
    params[:tipo].present? || params[:categoria].present?
  end
end
