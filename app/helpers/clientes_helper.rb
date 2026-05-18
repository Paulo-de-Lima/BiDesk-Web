module ClientesHelper
  def clientes_filtros_ativos?
    params[:com_email] == "1" || (params[:ordenar].present? && params[:ordenar] != "recentes")
  end

  def clientes_export_params
    request.query_parameters.slice("busca", "ordenar", "com_email").tap do |q|
      q["com_email"] = "1" if params[:com_email] == "1"
    end
  end
end
