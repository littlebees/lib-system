class MyDeviseFailureApp < Devise::FailureApp
  def http_auth_body
    return super unless request_format == :json
    {
      sucess: false,
      msg: i18n_message
    }.to_json
  end
end