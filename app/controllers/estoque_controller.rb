class EstoqueController < ApplicationController
  before_action :set_produto, only: [ :show, :edit, :update, :destroy ]

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

  def destroy
    @produto.destroy
    redirect_to estoque_index_path, notice: "Produto removido com sucesso!"
  end

  private

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(:nome, :categoria, :quantidade, :preco, :valor_minimo, :descricao)
  end
end
