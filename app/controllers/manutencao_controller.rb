class ManutencaoController < ApplicationController
  before_action :set_manutencao, only: [ :show, :edit, :update, :destroy ]
  before_action :set_produtos, only: [ :new, :create, :edit, :update ]

  def index
    @manutencoes = Manutencao.lista_filtrada(params)

    @pendentes = Manutencao.pendentes.count
    @concluidas = Manutencao.concluidas.count
    @equipamentos = Manutencao.distinct.pluck(:equipamento).compact
  end

  def show
    return if modal_frame_request?

    redirect_to manutencao_index_path
  end

  def new
    @manutencao = Manutencao.new
    @manutencao.data = Date.current
    @manutencao.status = "pendente"
    2.times { @manutencao.itens_manutencao.build }
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
    preparar_itens_em_branco
    render :new, status: :unprocessable_entity
  end

  def edit
    @manutencao.itens_manutencao.build
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
    @manutencao.itens_manutencao.build
    render :edit, status: :unprocessable_entity
  end

  def destroy
    session[:deleted_manutencao] = {
      "manutencao" => @manutencao.attributes.slice("equipamento", "descricao", "data", "custo", "status", "observacoes"),
      "itens" => @manutencao.itens_manutencao.map { |item|
        item.attributes.slice("produto_id", "quantidade", "preco_unitario")
      }
    }
    @manutencao.destroy
    set_undo_flash(undo_destroy_manutencao_index_path)
    redirect_to manutencao_index_path, notice: "Manutenção removida com sucesso!"
  end

  def undo_destroy
    payload = restore_or_redirect(session_key: :deleted_manutencao, redirect_path: manutencao_index_path,
                                  failure_alert: "Não há manutenção para desfazer.")
    return unless payload

    attrs = payload["manutencao"] || payload
    itens = payload["itens"] || []

    manutencao = Manutencao.new(attrs)
    saved = false
    Manutencao.transaction do
      saved = manutencao.save
      raise ActiveRecord::Rollback unless saved

      itens.each do |item_attrs|
        manutencao.itens_manutencao.create!(item_attrs)
      end
    end

    if saved
      redirect_undo_success(manutencao_index_path)
    else
      redirect_undo_failure(manutencao_index_path)
    end
  rescue ActiveRecord::RecordInvalid
    redirect_undo_failure(manutencao_index_path, "Não foi possível restaurar a manutenção (verifique o estoque).")
  end

  private

  def set_manutencao
    @manutencao = Manutencao.includes(itens_manutencao: :produto).find(params[:id])
  end

  def set_produtos
    @produtos = Produto.order(:nome)
  end

  def preparar_itens_em_branco
    return if @manutencao.itens_manutencao.any?(&:new_record?)

    2.times { @manutencao.itens_manutencao.build }
  end

  def manutencao_params
    params.require(:manutencao).permit(
      :equipamento, :descricao, :data, :custo, :status, :observacoes,
      itens_manutencao_attributes: [ :id, :produto_id, :quantidade, :_destroy ]
    )
  end
end
