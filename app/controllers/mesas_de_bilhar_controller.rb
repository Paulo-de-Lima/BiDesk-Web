class MesasDeBilharController < ApplicationController
  before_action :set_cliente
  before_action :set_mesa, only: [:edit, :update, :destroy]

  def new
    @mesa = @cliente.mesas_de_bilhar.build
  end

  def create
    @mesa = @cliente.mesas_de_bilhar.build(mesa_params)
    if @mesa.save
      redirect_to @cliente, notice: "Mesa de bilhar cadastrada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @mesa.update(mesa_params)
      redirect_to @cliente, notice: "Mesa atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @mesa.destroy
    redirect_to @cliente, notice: "Mesa removida."
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
