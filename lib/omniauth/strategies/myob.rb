require "omniauth/strategies/oauth2"

module OmniAuth
  module Strategies
    class Myob < OmniAuth::Strategies::OAuth2

      option :name, 'myob'

      option :client_options, {
        :site          => 'https://secure.myob.com',
        :authorize_url => '/oauth2/account/authorize',
        :token_url     => '/oauth2/v1/authorize',
      }

      option :authorize_params, {
        'scope' => 'CompanyFile'
      }

      uid {
        get_from_raw('Id')
      }

      info do
        {
          'name'     => get_from_raw('Name'),
          'uri'      => get_from_raw('Uri')
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def get_from_raw(param)
        if raw_info.length > 0
          return raw_info[0][param].to_s
        else
          return ""
        end
      end
      
      def raw_info
        @raw_info ||= MultiJson.load(access_token.get('https://api.myob.com/accountright/', {:headers => headers}).body)
      end

      private

      def headers
        @headers ||= {
          'x-myobapi-key'     => options.client_id,
          'x-myobapi-cftoken' => '',
          'x-myobapi-version' => 'v2',
        }
      end

    end
  end
end
