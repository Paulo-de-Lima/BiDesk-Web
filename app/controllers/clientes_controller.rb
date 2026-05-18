class ClientesController < ApplicationController
  before_action :set_cliente, only: [ :show, :edit, :update, :destroy ]

  def index
    @clientes = Cliente.lista_filtrada(params)

    respond_to do |format|
      format.html
      format.csv do
        send_data clientes_csv(Cliente.lista_filtrada(params)),
                  filename: "clientes-#{Date.current.strftime('%Y%m%d')}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  def show
  end

  def new
    @cliente = Cliente.new
  end

  def create
    @cliente = Cliente.new(cliente_params)
    if respond_with_modal_save(
      success: @cliente.save,
      redirect_path: @cliente,
      notice: "Cliente criado com sucesso!",
      tbody_id: "clientes_tbody",
      partial: "clientes/tbody",
      locals: { clientes: Cliente.lista_filtrada(params) }
    )
      return
    end

    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    if respond_with_modal_save(
      success: @cliente.update(cliente_params),
      redirect_path: @cliente,
      notice: "Cliente atualizado com sucesso!",
      tbody_id: "clientes_tbody",
      partial: "clientes/tbody",
      locals: { clientes: Cliente.lista_filtrada(params) }
    )
      return
    end

    render :edit, status: :unprocessable_entity
  end

  def destroy
    session[:deleted_cliente] = {
      "cliente" => @cliente.attributes.slice("nome", "telefone", "email", "observacoes"),
      "mesas" => @cliente.mesas_de_bilhar.map { |m| m.attributes.slice("ordem", "numeracao", "registros") }
    }
    @cliente.destroy
    set_undo_flash(undo_destroy_clientes_path)
    redirect_to clientes_path, notice: "Cliente removido com sucesso!"
  end

  def undo_destroy
    payload = restore_or_redirect(session_key: :deleted_cliente, redirect_path: clientes_path)
    return unless payload

    Cliente.transaction do
      cliente = Cliente.create!(payload["cliente"])
      Array(payload["mesas"]).each { |attrs| cliente.mesas_de_bilhar.create!(attrs) }
      redirect_undo_success(clientes_path)
    end
  rescue ActiveRecord::RecordInvalid
    redirect_undo_failure(clientes_path)
  end

  private

  def set_cliente
    scope = Cliente.all
    scope = scope.includes(:mesas_de_bilhar) if action_name == "show"
    @cliente = scope.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:nome, :telefone, :email, :observacoes)
  end

  def clientes_csv(clientes)
    bom = "\uFEFF"
    bom + CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << [ "Nome", "Telefone", "Email" ]
      clientes.each do |cliente|
        csv << [ cliente.nome, cliente.telefone, cliente.email ]
      end
    end
  end
end
