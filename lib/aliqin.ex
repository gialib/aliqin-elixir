defmodule Aliqin do
  @moduledoc """
  阿里大于的SDK, elixir版本
  """

  alias Aliqin.Util

  @sdk_keys Application.get_env(:aliqin, :sdk_keys)

  @api_names %{
    sms_num_send: "alibaba.aliqin.fc.sms.num.send",
    sms_num_query: "alibaba.aliqin.fc.sms.num.query"
  }

  def api_names, do: @api_names

  def sdk_keys, do: @sdk_keys

  def get_sdk_config(key) do
    key = :"#{key}"

    if config = @sdk_keys |> Keyword.get(key) do
      config
    else
      raise(Aliqin.ConfigMissing, message: "sdk_config for #{key} missing")
    end
  end

  defdelegate execute(sdk_key, api_name_key, params \\ %{}), to: Util, as: :execute

  defdelegate sms_num_send!(sdk_key, opts \\ []), to: Aliqin.SmsAPI, as: :num_send!

end
