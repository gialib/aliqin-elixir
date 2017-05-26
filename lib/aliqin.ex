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

  @doc """
  执行API
  ```
  sdk_key: SDK的Key，在config中配置sdk_key相关的参数，可以配置多个keys
  api_name_key: API的名称 eg. :sms_num_send
  params:
    * extend
  ```
  """
  def execute(sdk_key, api_name_key, params \\ %{}) do
    sdk_key = :"#{sdk_key}"
    app_key = "#{sdk_key}"

    app_secret = sdk_key |> get_sdk_config_by_key() |> Map.get(:app_secret)
    sign_method = "md5"
    api_name = @api_names |> Map.get(api_name_key)

    timestamp =
      Timex.now
      |> Timex.Timezone.convert("Asia/Shanghai")
      |> Timex.format!("%Y-%m-%d %H:%M:%S", :strftime)

    params =
      params
      |> Map.put(:app_key, app_key)
      |> Map.put(:sign_method, sign_method)
      |> Map.put(:timestamp, timestamp)
      |> Map.put(:format, "json")
      |> Map.put(:v, "2.0")
      |> Map.put(:method, api_name)

    sign = Util.md5_sign(app_secret, params)

    params = params |> Map.put(:sign, sign)

    IO.puts("app_secret: #{app_secret}")
    IO.puts("params: #{inspect(params)}")
    IO.puts("sign: #{sign}")

    Util.post!("http://gw.api.taobao.com/router/rest", encode_post_data(params))
  end

  def sdk_keys, do: @sdk_keys

  def get_sdk_config_by_key(key) do
    key = :"#{key}"

    if config = @sdk_keys |> Keyword.get(key) do
      config
    else
      raise(Aliqin.ConfigMissing, message: "sdk_config for #{key} missing")
    end
  end

  @doc """
  发送手机短信
  ```
  ## opts
  * sign_name(*)        # 签名名称
  * numbers(* List)     # 接收方的手机号
  * templdate_key(*)    # 模板的标识
  * sms_params(* Map)   # 自定义
  * extend              # 扩展参数
  ```
  """
  def sms_num_send!(sdk_key, opts \\ []) do
    templdate_key = :"#{Keyword.get(opts, :templdate_key)}"

    params = %{}

    params = params |> Map.put(:sms_type, "normal")

    params =
      if sign_name = Keyword.get(opts, :sign_name) do
        params |> Map.put(:sms_free_sign_name, sign_name)
      else
        params
      end

    # 参数
    params =
      if sms_params = Keyword.get(opts, :sms_params) do
        params |> Map.put(:sms_param, Poison.encode!(sms_params))
      else
        params
      end

    # 接收方的手机号码
    params =
      if numbers = Keyword.get(opts, :numbers) do
        numbers_string =
          numbers
          |> Enum.map(fn(number) ->
            String.trim(number)
          end)
          |> Enum.join(",")

        params |> Map.put(:rec_num, numbers_string)
      else
        params
      end

    params =
      if templdate_code = get_in(get_sdk_config_by_key(sdk_key), [:usages, :sms_num_send, :templdate_codes, templdate_key]) do
        params |> Map.put(:sms_template_code, templdate_code)
      else
        params
      end

    execute(sdk_key, :sms_num_send, params)
  end

  defp build_query_parameter(_, []), do: nil
  defp build_query_parameter(key, [head|tail]) do
    [build_query_parameter(key, head), build_query_parameter(key, tail)]
    |> Enum.reject(fn(x) -> x == nil end)
    |> Enum.join("&")
  end
  defp build_query_parameter(:q, value) do
    "q=#{URI.encode_www_form(value)}"
  end
  defp build_query_parameter(key, value) do
    [Atom.to_string(key), URI.encode_www_form("#{value}")] |> Enum.join("=")
  end

  def encode_post_data(params) do
    params
    |> Enum.map(fn({key, value}) -> build_query_parameter(key, value) end)
    |> Enum.join("&")
  end

end
