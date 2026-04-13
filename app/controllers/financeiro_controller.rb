class FinanceiroController < ApplicationController
  before_action :set_transacao, only: [:show, :edit, :update, :destroy]

  def index
    @transacoes = if params[:tipo].present?
      TransacaoFinanceira.where(tipo: params[:tipo]).recentes
    elsif params[:categoria].present?
      TransacaoFinanceira.por_categoria(params[:categoria]).recentes
    else
      TransacaoFinanceira.recentes
    end
    
    mes_atual = Date.current.month
    ano_atual = Date.current.year
    @receitas_mes = TransacaoFinanceira.receitas.por_mes(ano_atual, mes_atual).sum(:valor)
    @despesas_mes = TransacaoFinanceira.despesas.por_mes(ano_atual, mes_atual).sum(:valor)
    @saldo_mes = @receitas_mes - @despesas_mes
    
    @receitas_total = TransacaoFinanceira.receitas.sum(:valor)
    @despesas_total = TransacaoFinanceira.despesas.sum(:valor)
    @saldo_total = @receitas_total - @despesas_total
    
    @categorias = TransacaoFinanceira.distinct.pluck(:categoria).compact
  end

  def show
  end

  def new
    @transacao = TransacaoFinanceira.new
    @transacao.data = Date.current
  end

  def create
    @transacao = TransacaoFinanceira.new(transacao_params)
    if @transacao.save
      redirect_to financeiro_index_path, notice: "Transação registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transacao.update(transacao_params)
      redirect_to financeiro_index_path, notice: "Transação atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transacao.destroy
    redirect_to financeiro_index_path, notice: "Transação removida com sucesso!"
  end

  private

  def set_transacao
    @transacao = TransacaoFinanceira.find(params[:id])
  end

  def transacao_params
    params.require(:transacao_financeira).permit(:tipo, :descricao, :valor, :data, :categoria)
  end
end
