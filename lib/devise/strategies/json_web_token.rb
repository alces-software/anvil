#
# Based on code taken from
# http://zacstewart.com/2015/05/14/using-json-web-tokens-to-authenticate-javascript-front-ends-on-rails.html
#
require 'json_web_token'

module Devise
  module Strategies
    class JsonWebToken < Base
      def valid?
        !request.headers['Authorization'].nil?
      end

      def authenticate!
        if claims and user = User.find_by_id(claims.fetch('user_id'))
          success! user
        else
          fail!
        end
      end

      private

      def claims
        auth_header = request.headers['Authorization']
        return nil unless auth_header.present?

        token = auth_header.split(' ').last
        return nil unless token.present?

        ::JsonWebToken.decode(token)
      rescue
        nil
      end
    end
  end
end
