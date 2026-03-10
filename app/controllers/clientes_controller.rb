class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :edit, :update, :destroy]

  def index
    @clientes = if params[:busca].present?
      Cliente.buscar(params[:busca])
    else
      Cliente.recentes
    end
  end

  def show
  end

  def new
    @cliente = Cliente.new
  end

  def create
    @cliente = Cliente.new(cliente_params)
    if @cliente.save
      redirect_to @cliente, notice: "Cliente criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cliente.update(cliente_params)
      redirect_to @cliente, notice: "Cliente atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cliente.destroy
    redirect_to clientes_path, notice: "Cliente removido com sucesso!"
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:nome, :telefone, :email, :observacoes)
  end
end
