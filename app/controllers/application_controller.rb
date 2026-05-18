class ApplicationController < ActionController::Base
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Authenticatable
  include ModalFormResponses

  helper_method :current_admin
end
