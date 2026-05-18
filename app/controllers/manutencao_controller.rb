class ManutencaoController < ApplicationController
  before_action :set_manutencao, only: [ :show, :edit, :update, :destroy ]

  def index
    @manutencoes = Manutencao.lista_filtrada(params)

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
    if respond_with_modal_save(
      success: @manutencao.save,
      redirect_path: manutencao_path(@manutencao),
      notice: "Manutenção registrada com sucesso!",
      tbody_id: "manutencao_tbody",
      partial: "manutencao/tbody",
      locals: { manutencoes: Manutencao.lista_filtrada(params) }
    )
      return
    end
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    if respond_with_modal_save(
      success: @manutencao.update(manutencao_params),
      redirect_path: manutencao_path(@manutencao),
      notice: "Manutenção atualizada com sucesso!",
      tbody_id: "manutencao_tbody",
      partial: "manutencao/tbody",
      locals: { manutencoes: Manutencao.lista_filtrada(params) }
    )
      return
    end
    render :edit, status: :unprocessable_entity
  end

  def destroy
    session[:deleted_manutencao] = @manutencao.attributes.slice("equipamento", "descricao", "data", "custo", "status", "observacoes")
    @manutencao.destroy
    set_undo_flash(undo_destroy_manutencao_index_path)
    redirect_to manutencao_index_path, notice: "Manutenção removida com sucesso!"
  end

  def undo_destroy
    data = restore_or_redirect(session_key: :deleted_manutencao, redirect_path: manutencao_index_path,
                              failure_alert: "Não há manutenção para desfazer.")
    return unless data

    manutencao = Manutencao.new(data)
    if manutencao.save
      redirect_undo_success(manutencao_index_path)
    else
      redirect_undo_failure(manutencao_index_path)
    end
  end

  private

  def set_manutencao
    @manutencao = Manutencao.find(params[:id])
  end

  def manutencao_params
    params.require(:manutencao).permit(:equipamento, :descricao, :data, :custo, :status, :observacoes)
  end
end
