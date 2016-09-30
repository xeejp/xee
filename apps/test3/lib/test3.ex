defmodule Test3 do
  use XeeThemeScript

  def script_type do
    :message
  end

  def init do
    {:ok, %{data: %{host: [], participant: %{}, messages: %{}}}}
  end

  def join(%{participant: participant} = state, id) do
    unless Map.has_key?(participant, id) do
      state = %{state | participant: Map.put(participant, id, [])}
    end
    {:ok, %{data: state}}
  end

  def handle_received(%{host: host} = state, received) do
    data = %{state | host: List.insert_at(host, -1, received)}
    {:ok, %{data: data, host: data.host}}
  end

  def handle_received(%{participant: participant} = state, received, id) do
    data = %{state | participant: %{participant | id => List.insert_at(Map.get(participant, id, []), -1, received)}}
    {:ok, %{data: data, participant: %{id => data.participant[id]}}}
  end

  def handle_message(state, message, token) do
    %{messages: messages} = state
    data = %{state | messages: Map.put(messages, token, List.insert_at(Map.get(messages, token, []), -1, message))}
    {:ok, %{data: data, host: data.messages, experiment: %{token => %{message: data.messages[token]}}}}
  end
end
