RSpec.shared_context "shared_context" do

  let(:id_token) { "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJENTVCQ0RGRDdEQzQzQTZCQUNENDI2RTZFQzFFMThBRUMzQ0UzNzVSUzI1NiIsInR5cCI6IkpXVCIsIng1dCI6InZWVzgzOWZjUTZhNnpVSnVic0hoaXV3ODQzVSJ9.eyJuYmYiOjE2ODE5MTg0MDQsImV4cCI6MTY4MTkxODcwNCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NTAwMSIsImF1ZCI6InJ1YnkiLCJub25jZSI6IjBiZTg0ODMwOGI3YzJjYWY4MGYzMGY1NWRlNDJkOWI0IiwiaWF0IjoxNjgxOTE4NDA0LCJhdF9oYXNoIjoiQWg2Q2x5RkxnXzQ4b2pqTzlvVzYydyIsInNfaGFzaCI6ImVib1MzcUdBQ05aXzhsNENrNjg3NVEiLCJzaWQiOiI3RDIwRUU5NDIwMjk5NTEwREFCRTJDN0YyRDA3RDNBNiIsInN1YiI6IjgxODcyNyIsImF1dGhfdGltZSI6MTY4MTkxODI3MCwiaWRwIjoibG9jYWwiLCJhbXIiOlsicHdkIl19.KbTPG5A9Hxc7PpABnx3JqJyJ_2etRDalT07HEf64Vxplo9lSdUdkZGEOBGsxEHg8BOJ0J16FqtGT55Nm1oWVlwdPFcjd03d0diwLfV2kt-5t_UKQwGixI0AgqyDutlIuaCAWYx6puFjU1KUwWXPKWdUCYF25AEyP2om8L5rro9cpDXng62svC9jMPTluLM35RGpiEQljbV94j_TOih5pli6ewN6mJRsVPnHm8XkpPCJUlSrRxCW8NoCULw5Ra1NO6fS0M8lRE3XDVjlpv_Ngo_wHh-kzYLo7mbxmGMsUEVgUZPEn-t5WLwduOD0P69Y09Hxz4On9Sa4RoCcR70e1zw" }
  let(:token) { "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJENTVCQ0RGRDdEQzQzQTZCQUNENDI2RTZFQzFFMThBRUMzQ0UzNzVSUzI1NiIsInR5cCI6ImF0K2p3dCIsIng1dCI6InZWVzgzOWZjUTZhNnpVSnVic0hoaXV3ODQzVSJ9.eyJuYmYiOjE2ODE5MTg0MDQsImV4cCI6MTY4MTkyMjAwNCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NTAwMSIsImNsaWVudF9pZCI6InJ1YnkiLCJzdWIiOiI4MTg3MjciLCJhdXRoX3RpbWUiOjE2ODE5MTgyNzAsImlkcCI6ImxvY2FsIiwianRpIjoiRUUyNEIzOTM5MkRENTQyMzRGNzU3OEQyQTgyQ0FFRTQiLCJzaWQiOiI3RDIwRUU5NDIwMjk5NTEwREFCRTJDN0YyRDA3RDNBNiIsImlhdCI6MTY4MTkxODQwNCwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsImFtciI6WyJwd2QiXX0.nVbtDeRhSqgHdlqjKh2aksKab0rFLwdOSChGowt4iclbqSSXUDTD0dYkpS78UFCljIPlsp5buApmHd0Uvi7Z69wg4215J19tIY9YJBq2ZJFaFfJ1asOVOHU9RVSt8gBv07cYrABiolcioSBDt5f-2W8dt-4Ly5y_HB4XXLmFXAGiUDVuksun9E6tIsFALcc_BJ9X3NGgEYfXlbQSgopgv2un6CM8ctriPnCcin3129HCne-dnP9Xs_OAzojQXs_I8JtQePkMiNlbpwDIbYsu7DqxhkkUdISwpvQ2iF1cTURn1wyxapboz77AaLSLH_jP80aFC2LO-IcCvn6-dXaLmg" }
  let(:nickname) { "alice" }
  let(:params) { {
    provider: "openid_connect", uid: "818727", name: "Alice Smith", oauth_signature: "4c584a62431cce70563fa6eabcc6e8f4", avatar_url: nil,
    raw_data: { provider: "openid_connect", uid: "818727", info: { name: "Alice Smith", email: email, email_verified: true, nickname: nil, first_name: "Alice",
                                                                   last_name: "Smith", gender: nil, image: nil, phone: nil, urls: { website: "http://alice.com" } },
                credentials: { id_token: id_token, token: token, refresh_token: nil, expires_in: 3600, scope: "openid profile email" },
                extra: { raw_info: { name: "Alice Smith", given_name: "Alice", family_name: "Smith", email: email, email_verified: true, website: "http://alice.com",
                                     providername: "POSTE", providersubject: "spid_code", sub: "818727", nbf: 1681918404, exp: 1681918704, iss: "https://localhost:5001",
                                     aud: "ruby", nonce: "0be848308b7c2caf80f30f55de42d9b4", iat: 1681918404, at_hash: "Ah6ClyFLg_48ojjO9oW62w", s_hash: "eboS3qGACNZ_8l4Ck6875Q",
                                     sid: "7D20EE9420299510DABE2C7F2D07D3A6", auth_time: 1681918270, idp: "local", amr: ["pwd"] } } } } }

  let(:tenant) { Decidim::Pua.tenants.first }
  let(:hostname) { "http://192.168.1.11/" }
  let(:host) { URI(hostname).host }
  let(:email) { "alicesmith@email.com" }
  let(:current_organization) { create :pua_organization, host: host }
  let(:admin) { create :user, :admin, organization: current_organization }
  let(:user) { create :user, organization: current_organization, email: email }
  let(:identity) { create :openid_identity, user: user }
  let(:state) { "c7d8e69125f289799237f4659642d748" }
  let(:callback_params) { {
    code: "9C096B8602267A0A7CA6F6C656A4A060EFC0145833112627D1B70AC7BF429CDE",
    scope: "openid profile email",
    state: state,
    session_state: "oHI82SYEtcz0pbEme22WSUvSUoeCBPDfSELkCeg3IAs.5B9BB8A4D3E7FB05FA10FA49B8C4064E"
  } }

  let(:env) { {
    "rack.session" => { "omniauth.state" => state },
    "rack.session.options" => {},
    'rack.input' => {},
    "decidim.current_organization" => current_organization,
  }
  }

  def stub_login
    mock_json :get, "https://localhost:5001/.well-known/openid-configuration", "discovery"
    mock_json :post, "https://localhost:5001/connect/token", "connect", params: {
      scope: "openid profile email",
      grant_type: 'authorization_code',
      code: "9C096B8602267A0A7CA6F6C656A4A060EFC0145833112627D1B70AC7BF429CDE",
      redirect_uri: "http://192.168.1.11:3000/users/auth/openid_connect/callback"
    }
    mock_json :get, "https://localhost:5001/.well-known/openid-configuration/jwks", "jwks"
    mock_json :get, "https://localhost:5001/connect/userinfo", "userinfo"
    allow_any_instance_of(OpenIDConnect::ResponseObject::IdToken).to receive(:verify!).and_return true
  end

  def make_login
    stub_login
    get "/users/auth/openid_connect/callback", { params: callback_params, env: env }
  end

  def post_registration(nickname = nil)
    post "/users/auth/openid_connect/create", { params: { user: params.merge(raw_data: params.dig(:raw_data).to_json).merge(nickname ? { nickname: nickname } : {}  ) }, env: env }
  end

  def visit_settings_account
    get '/account'
  end

  def make_logout
    # "eyJhbGciOiJSUzI1NiIsImtpZCI6IkJENTVCQ0RGRDdEQzQzQTZCQUNENDI2RTZFQzFFMThBRUMzQ0UzNzVSUzI1NiIsInR5cCI6IkpXVCIsIng1dCI6InZWVzgzOWZjUTZhNnpVSnVic0hoaXV3ODQzVSJ9.eyJuYmYiOjE2ODIwODY4NjcsImV4cCI6MTY4MjA4NzE2NywiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NTAwMSIsImF1ZCI6InJ1YnkiLCJub25jZSI6ImU5MzQ0OGQ3OGVlYjJkOTdkNjViMzI2ZTk1ZjkwMzZmIiwiaWF0IjoxNjgyMDg2ODY3LCJhdF9oYXNoIjoidDZZLXdNX2dTMHRFNzF0dHdZM1k3ZyIsInNfaGFzaCI6IkNyaUwxenh0Y3RNR2xlZlZuTkowX2ciLCJzaWQiOiJBRjZGRkEwQzA3RjRCRkUzQ0ExQzYyQzdBRjUwQkJCNyIsInN1YiI6IjgxODcyNyIsImF1dGhfdGltZSI6MTY4MjA4Njg1OSwiaWRwIjoibG9jYWwiLCJhbXIiOlsicHdkIl19.2tTan1My1P500VdST18FCbySSgpl2nLnd4-in1QBPzN7adFwYfAiNFCBCc3FKfaEXOEyxfN4RJpDEfOOHEEngru9VvqMnmfSDMytruaJJKpUTlHIyNLPFTtrLNQB35rc52cFMGX59fKfddElG1QHyruiyz4Mhd8UjCbdr831kWbXBc6j7D-T6fzVa9qwdEtuc_Rnp_aLjfFcC4ujV5kskG2aYZ2jAqWESdgfSksNacMmPaq0mdovivPp1orQ7qHOh5-p4wZdv2Ddu8yOpopks4RYj1QAYNt813lC4RFgSCAOjImrI7zNI8OBu0M_LX3GErnnjfRfQP9OIYj5jki9Zw"
    mock_json :get, "https://localhost:5001/.well-known/openid-configuration", "discovery"
    mock_json :get, "https://localhost:5001/connect/endsession", "endsession", params: {
      post_logout_redirect_uri: "http%3A%2F%2F192.168.1.11%3A3000%2Fusers%2Fauth%2Fopenid_connect%2Flogout",
      id_token_hint: id_token
    }
    delete "/users/sign_out"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("#{hostname}users/auth/#{tenant.name}/oidc_logout")
    get "/users/auth/#{tenant.name}/logout"
  end

  def visit_authorization_page
    get "/new"
  end
end