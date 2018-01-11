```console
$ rails g controller home index
$ rails g devise:install
$ rails g devise User
$ rake db:migrate
$ rails s -b 0.0.0.0
```

```html
<!--application.html.erb-->
<body>
  
<!--만약에 유저가 로그인 하면,-->
<%if user_signed_in?%>
<!-- 1. 이메일을 출력하고 로그아웃 버튼을 만든다 -->
  <%=current_user.email%>
  <%=link_to "로그아웃", destroy_user_session_path, method: :delete%>

<%else%>
<!-- 2. 로그인 버튼을 만든다 -->
  <%=link_to "로그인",new_user_session_path%>
  <%=link_to "회원가입",new_user_registration_path%>
<%end%>

</body>
```





developers.facebook.com



https://github.com/mkdynamic/omniauth-facebook

`/auth/facebook?display=popup` or `/auth/facebook?scope=email`.

이런식으로 요청 보내면 

Auth Hash 받을 수 있음



https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview





config/initializers/devise.rb에 github을 facebook으로 변경

```ruby
config.omniauth :facebook, "APP_ID", "APP_SECRET"
```



```console
$bundle exec figaro install
```

      create  config/application.yml
      append  .gitignore
applicaton.yml을 git에서 알지 못하게 해줌. 보안?





config/application.yml

```yml
facebook_app_id: '515040398881558'
facebook_app_secret: '5aae1507fad5180b7c1efc3b7cf7725a'
```

환경변수 설정?

그리고 config/initializers/devise.rb

```ruby
config.omniauth :facebook, ENV['facebook_app_id'], ENV['facebook_app_secret'], scope: 'email'
```

"APP_ID"자리에 환경변수를 활용해서 넣어줌



[devise wiki](https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview)에서

`devise :omniauthable, omniauth_providers: %i[facebook] `

랑
`devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' } `

찾아서 추가

```ruby
#user.rb
devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers: [:facebook]

```

```ruby
#routes.rb
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

[facebook developer](https://developers.facebook.com/apps/515040398881558/fb-login/)

앱- 설정-유효한OAuth리디렉션 URI에 아래 주소 추가 

http://localhost:3000/users/auth/facebook/callback

확인은

localhost:3000/users/sign_in



Configuring controllers

```consoel
$rails g devise:controllers users
```

```ruby
#controllers/users/omniauth_callbacks_controller.rb
def facebook
    p request.env['omniauth.auth']
    redirect_to root_path
  end
```

```console
$ rails g model Service user:references provider uid access_token access_token_secret refresh_token expires_at:datetime auth:text
$ rake db:migrate
```

user.rb에 

```ruby
has_many :services
```



```ruby
#app/controllers/users/omniauth_callbacks_controller.rb
  def auth
    request.env['omniauth.auth']

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
```

