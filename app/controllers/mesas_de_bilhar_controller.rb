class MesasDeBilharController < ApplicationController
  before_action :set_cliente
  before_action :set_mesa, only: [ :edit, :update, :destroy ]

  def new
    @mesa = @cliente.mesas_de_bilhar.build
  end

  def create
    @mesa = @cliente.mesas_de_bilhar.build(mesa_params)
    if respond_with_modal_save(
      success: @mesa.save,
      redirect_path: clientes_path,
      notice: "Mesa de bilhar cadastrada com sucesso.",
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
      success: @mesa.update(mesa_params),
      redirect_path: clientes_path,
      notice: "Mesa atualizada com sucesso.",
      tbody_id: "clientes_tbody",
      partial: "clientes/tbody",
      locals: { clientes: Cliente.lista_filtrada(params) }
    )
      return
    end
    render :edit, status: :unprocessable_entity
  end

  def destroy
    session[:deleted_mesa] = {
      "cliente_id" => @cliente.id,
      "mesa" => @mesa.attributes.slice("ordem", "numeracao", "registros")
    }
    @mesa.destroy
    set_undo_flash(undo_destroy_cliente_mesas_path(@cliente))
    redirect_to @cliente, notice: "Mesa removida."
  end

  def undo_destroy
    payload = restore_or_redirect(session_key: :deleted_mesa, redirect_path: clientes_path)
    return unless payload

    cliente = Cliente.find_by(id: payload["cliente_id"])
    unless cliente
      return redirect_undo_failure(clientes_path, "Cliente não encontrado para restaurar a mesa.")
    end

    if cliente.mesas_de_bilhar.create(payload["mesa"])
      redirect_undo_success(cliente_path(cliente))
    else
      redirect_undo_failure(cliente_path(cliente))
    end
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:cliente_id])
  end

  def set_mesa
    @mesa = @cliente.mesas_de_bilhar.find(params[:id])
  end

  def mesa_params
    params.require(:mesa_de_bilhar).permit(:ordem, :numeracao, :registros)
  end
end
