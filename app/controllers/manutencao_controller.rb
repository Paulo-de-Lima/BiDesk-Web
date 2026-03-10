class ManutencaoController < ApplicationController
  before_action :set_manutencao, only: [:show, :edit, :update, :destroy]

  def index
    @manutencoes = if params[:status].present?
      Manutencao.where(status: params[:status]).recentes
    elsif params[:equipamento].present?
      Manutencao.por_equipamento(params[:equipamento]).recentes
    else
      Manutencao.recentes
    end
    
    @pendentes = Manutencao.pendentes.count
    @em_andamento = Manutencao.em_andamento.count
    @concluidas = Manutencao.concluidas.count
    @equipamentos = Manutencao.distinct.pluck(:equipamento).compact
  end

  def show
  end

  def new
    @manutencao = Manutencao.new
    @manutencao.data = Date.current
    @manutencao.status = "pendente"
  end

  def create
    @manutencao = Manutencao.new(manutencao_params)
    if @manutencao.save
      redirect_to manutencao_path(@manutencao), notice: "Manutenção registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @manutencao.update(manutencao_params)
      redirect_to manutencao_path(@manutencao), notice: "Manutenção atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @manutencao.destroy
    redirect_to manutencao_index_path, notice: "Manutenção removida com sucesso!"
  end

  private

  def set_manutencao
    @manutencao = Manutencao.find(params[:id])
  end

  def manutencao_params
    params.require(:manutencao).permit(:equipamento, :descricao, :data, :custo, :status, :observacoes)
  end
end
