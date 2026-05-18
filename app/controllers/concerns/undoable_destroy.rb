# Armazena atributos na sessão após destroy e permite restaurar via POST undo_destroy.
module UndoableDestroy
  extend ActiveSupport::Concern

  private

  def set_undo_flash(undo_path)
    flash[:undo_path] = undo_path
  end

  def restore_or_redirect(session_key:, redirect_path:, failure_alert: "Não há exclusão para desfazer.")
    data = session.delete(session_key)
    unless data
      redirect_to redirect_path, alert: failure_alert
      return nil
    end
    data
  end

  def redirect_undo_failure(redirect_path, message = "Não foi possível desfazer a exclusão.")
    redirect_to redirect_path, alert: message
  end

  def redirect_undo_success(redirect_path, message = "Exclusão desfeita com sucesso!")
    redirect_to redirect_path, notice: message
  end
end
