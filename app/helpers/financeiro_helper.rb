module FinanceiroHelper
  def financeiro_filtros_ativos?
    params[:tipo].present? || params[:categoria].present?
  end
end
