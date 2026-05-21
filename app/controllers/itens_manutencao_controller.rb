class ItensManutencaoController < ApplicationController
  before_action :set_manutencao
  before_action :set_item, only: [ :edit, :update, :destroy ]
  before_action :set_produtos, only: [ :new, :create, :edit ]

  def new
    @item = @manutencao.itens_manutencao.build
  end

  def create
    @item = @manutencao.itens_manutencao.build(item_params)
    if respond_with_modal_save(
      success: @item.save,
      redirect_path: manutencao_index_path,
      notice: "Produto adicionado à manutenção.",
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
      success: @item.update(item_params),
      redirect_path: manutencao_index_path,
      notice: "Item de estoque atualizado.",
      tbody_id: "manutencao_tbody",
      partial: "manutencao/tbody",
      locals: { manutencoes: Manutencao.lista_filtrada(params) }
    )
      return
    end
    render :edit, status: :unprocessable_entity
  end

  def destroy
    session[:deleted_item_manutencao] = {
      "manutencao_id" => @manutencao.id,
      "item" => @item.attributes.slice("produto_id", "quantidade", "preco_unitario")
    }
    @item.destroy
    set_undo_flash(undo_destroy_manutencao_itens_path(@manutencao))
    redirect_to manutencao_index_path, notice: "Produto removido da manutenção."
  end

  def undo_destroy
    payload = restore_or_redirect(session_key: :deleted_item_manutencao, redirect_path: manutencao_index_path)
    return unless payload

    manutencao = Manutencao.find_by(id: payload["manutencao_id"])
    unless manutencao
      return redirect_undo_failure(manutencao_index_path, "Manutenção não encontrada para restaurar o item.")
    end

    if manutencao.itens_manutencao.create(payload["item"])
      redirect_undo_success(manutencao_index_path)
    else
      redirect_undo_failure(manutencao_index_path, "Não foi possível restaurar o item (estoque insuficiente ou produto duplicado).")
    end
  end

  private

  def set_manutencao
    @manutencao = Manutencao.find(params[:manutencao_id])
  end

  def set_item
    @item = @manutencao.itens_manutencao.find(params[:id])
  end

  def set_produtos
    @produtos = Produto.order(:nome)
  end

  def item_params
    params.require(:item_manutencao).permit(:produto_id, :quantidade)
  end
end
