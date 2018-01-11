# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]
  def auth
    request.env['omniauth.auth']

    # redirect_to root_path
    #<OmniAuth::AuthHash credentials=#<OmniAuth::AuthHash
    # expires=true
    # expires_at=1520820926
    # token="EAAHUbTAFMxYBALMT2vVkizZCzl4IfeLuoExo93xMwyhYYBh0mQdWlhBkdmU7DodgLn7OQuarM5f8DvVQelEKqQUggjalnquB4voNG7pqLIRiK8P4liCwuH49UAZCLgJhE49ZAIwlxFnpk6lGaEeLchZByqel9nPEqn2vIC928QZDZD">
    # extra=<OmniAuth::AuthHash
    # raw_info=<OmniAuth::AuthHash
    # id="10216119707771244"
    #name="Hanmaro Kwon">>
    # info=<OmniAuth::AuthHash::InfoHash image="http://graph.facebook.com/v2.6/10216119707771244/picture"
    # name="Hanmaro Kwon">
    # provider="facebook"
    # uid="10216119707771244">
  end
  def facebook
    p request.env['omniauth.auth']
    # binding.pry
    #auth hash는 위에 있는 주석
    #만약 유저가 facebook을 통해 회원강비을 한적이 있으면?
    service = Service.where(provider: auth.provider, uid: auth.uid).first
    if service.present?
      #유저를 가져오면된다
      user=service.user #service가 belongss_to_uid이므로 그 서비스가 가지고 있는 유저를 가지고 온다
    #아니면?
      service.update(expires_at: Time.at(auth.credentials.expires_at),
      access_token: auth.credentials.token)
      # 토큰을 발급받을 때 마다 만료되는 시간이 있는데 그걸 계속 갱신해주는거
      
    else
      #유저를 생성하면서, 서비스에 facebook 정보를 담아 놓는다.
      # user = User.create(email: auth.info.email, password: Devise.friendly_token[0,20])
      user = User.create(email: 'maro7913@nate.com', password: Devise.friendly_token[0,20])
      user.services.create(provider: auth.provider, uid: auth.uid, expires_at: Time.at(auth.credentials.expires_at),
      access_token: auth.credentials.token)
      #Service.new랑 같은데 user_id column에 user id 값이 들어감
    end
      sign_in_and_redirect user
  end
  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
