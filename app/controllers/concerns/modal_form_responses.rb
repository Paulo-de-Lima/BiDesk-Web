module ModalFormResponses
  extend ActiveSupport::Concern

  MODAL_FRAME = "resource_modal"

  included do
    helper_method :modal_frame_request?
  end

  private

  def modal_frame_request?
    turbo_frame_request_id == MODAL_FRAME
  end

  def respond_with_modal_save(success:, redirect_path:, notice:, tbody_id:, partial:, locals:)
    return false unless success

    respond_to do |format|
      format.html { redirect_to redirect_path, notice: notice }
      format.turbo_stream do
        flash.now[:notice] = notice
        render turbo_stream: modal_success_streams(
          tbody_id: tbody_id,
          partial: partial,
          locals: locals
        )
      end
    end
    true
  end

  def modal_success_streams(tbody_id:, partial:, locals:)
    [
      turbo_stream.update(MODAL_FRAME, ""),
      turbo_stream.replace(tbody_id, partial: partial, locals: locals),
      turbo_stream.update("flash-messages", partial: "shared/flash")
    ]
  end
end
