defmodule Sendmail.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:sendmail, :mailgun_domain),
    key: Application.get_env(:sendmail, :mailgun_key)

  @from Application.get_env(:sendmail, :from_address)
  @to Application.get_env(:sendmail, :to_address)

  def send_new_user_email(id, name, ip, time) do
    subject = "New user is now created"
    text = "ID: #{id}\nNAME: #{name}\nIP: #{ip}\nTIME: #{time}"
    send_email(subject, text)
  end

  def send_new_experiment_email(id, user_name, ip, theme_name, theme_id, x_token) do
    subject = "New experiment is now created"
    text = "ID: #{id}\nNAME: #{user_name}\nIP: #{ip}\nTHEME NAME: #{theme_name}\nTHEME ID: #{theme_id}\nX_TOKEN: #{x_token}"
    send_email(subject, text)
  end

  defp send_email(subject, text) do
    unless is_nil(@to) or is_nil(@from) do
      send_email to: @to,
        from: @from,
        subject: subject,
        text: text
    end
  end
end
