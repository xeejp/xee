defmodule Sendmail.Mailer do
  use Mailgun.Client,
      domain: Application.get_env(:sendmail, :mailgun_domain),
      key: Application.get_env(:sendmail, :mailgun_key)

  @from Application.get_env(:sendmail, :from_address)
  @to Application.get_env(:sendmail, :to_address)

def send_welcome_text_email(host_name) do
  send_email to: @to,
             from: @from,
             subject: "Welcome!",
             text: "New experiment was created by #{host_name}"
end

def send_newuser_email(id, name, ip, time) do
  send_email to: @to,
             from: @from,
             subject: "New user is now created",
             text: "ID: #{id}\nNAME: #{name}\nIP: #{ip}\nTIME: #{time}"
end

end