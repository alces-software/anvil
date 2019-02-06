require 'alces/anvil/s3_utils'

class DocumentsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    authorize! :read, @document
    redirect_to @document.signed_url
  end
end
