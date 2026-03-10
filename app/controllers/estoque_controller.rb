class EstoqueController < ApplicationController
  before_action :set_produto, only: [:show, :edit, :update, :destroy]

  def index
    @produtos = if params[:busca].present?
      Produto.buscar(params[:busca])
    elsif params[:categoria].present?
      Produto.por_categoria(params[:categoria])
    else
      Produto.all.order(:nome)
    end
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
    if @produto.save
      redirect_to estoque_path(@produto), notice: "Produto criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @produto.update(produto_params)
      redirect_to estoque_path(@produto), notice: "Produto atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
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
