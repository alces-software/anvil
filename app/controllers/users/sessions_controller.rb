#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file is part of Alces FlightDeck.
#
# All rights reserved, see LICENSE.txt.
#==============================================================================
class Users::SessionsController < Devise::SessionsController
  include ActionController::MimeResponds
  clear_respond_to
  respond_to :json
end
