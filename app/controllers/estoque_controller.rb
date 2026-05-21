class EstoqueController < ApplicationController
  before_action :set_produto, only: [ :show, :edit, :update, :destroy, :ajustar_quantidade ]

  def index
    @produtos = Produto.lista_filtrada(params)
    @produtos_baixo_estoque = Produto.baixo_estoque
    @categorias = Produto.distinct.pluck(:categoria).compact
  end

  def show
  end

  def new
    @produto = Produto.new
  end

  def create
    @produto = Produto.new(produto_params)
    if respond_with_modal_save(
      success: @produto.save,
      redirect_path: estoque_path(@produto),
      notice: "Produto criado com sucesso!",
      tbody_id: "estoque_tbody",
      partial: "estoque/tbody",
      locals: { produtos: Produto.lista_filtrada(params) }
    )
      return
    end
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    if respond_with_modal_save(
      success: @produto.update(produto_params),
      redirect_path: estoque_path(@produto),
      notice: "Produto atualizado com sucesso!",
      tbody_id: "estoque_tbody",
      partial: "estoque/tbody",
      locals: { produtos: Produto.lista_filtrada(params) }
    )
      return
    end
    render :edit, status: :unprocessable_entity
  end

  def ajustar_quantidade
    delta = params[:delta].to_i
    unless delta.in?([ -1, 1 ])
      head :unprocessable_entity
      return
    end

    nova_quantidade = [ @produto.quantidade + delta, 0 ].max
    unless @produto.update(quantidade: nova_quantidade)
      head :unprocessable_entity
      return
    end

    @produtos_baixo_estoque = Produto.baixo_estoque
    filtros = params.permit(:busca, :categoria)

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = delta.positive? ? "Quantidade aumentada." : "Quantidade diminuída."
        render turbo_stream: estoque_quantidade_streams
      end
      format.html do
        redirect_to estoque_index_path(filtros), notice: delta.positive? ? "Quantidade aumentada." : "Quantidade diminuída."
      end
    end
  end

  def destroy
    session[:deleted_produto] = @produto.attributes.slice("nome", "categoria", "quantidade", "preco", "valor_minimo", "descricao")
    @produto.destroy
    set_undo_flash(undo_destroy_estoque_index_path)
    redirect_to estoque_index_path, notice: "Produto removido com sucesso!"
  end

  def undo_destroy
    data = restore_or_redirect(session_key: :deleted_produto, redirect_path: estoque_index_path)
    return unless data

    produto = Produto.new(data)
    if produto.save
      redirect_undo_success(estoque_index_path)
    else
      redirect_undo_failure(estoque_index_path)
    end
  end

  private

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(:nome, :categoria, :quantidade, :preco, :valor_minimo, :descricao)
  end

  def estoque_quantidade_streams
    [
      turbo_stream.replace(@produto, partial: "estoque/row", locals: { produto: @produto }),
      turbo_stream.update("estoque-alerta-critico", partial: "estoque/alerta_critico", locals: { produtos_baixo_estoque: @produtos_baixo_estoque }),
      turbo_stream.update("flash-messages", partial: "shared/flash")
    ]
  end
end
