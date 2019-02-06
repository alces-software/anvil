class Document < ApplicationRecord
  delegate :upload_from_path, :signed_url, to: :handler

  belongs_to :site

  def url
    Rails.application.routes.url_helpers
      .document_url(id, host: Thread.current[:host])
  end

  private
  def handler
    @handler ||= DocumentHandler.new(self)
  end
end
