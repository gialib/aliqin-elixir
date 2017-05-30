defmodule Aliqin.Util do
  @moduledoc """
  工具库
  """

  # 缺省的头部
  @default_headers [
    {"User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3047.0 Safari/537.36"},
    {"Content-Type", "application/x-www-form-urlencoded"}
  ]

  @doc """
  对参数数据进行签名
  """
  def md5_sign(secret, params \\ []) do
    # 检查排序
    params = params |> sort_params()

    # 将参数名和参数值串在一起
    joined_params = params |> join_params()

    # 使用MD5进行加密
    generate_md5_sign(secret, joined_params)
  end

  @doc """
  按ASCII顺序排序
  """
  def sort_params(params \\ []) do
    params |> Enum.sort_by(fn({key, _value}) -> "#{key}" end)
  end

  @doc """
  拼接参数名与参数值
  """
  def join_params(params \\ []) do
    params
    |> Enum.map(fn({key, value}) ->
      "#{key}#{value}"
    end)
    |> Enum.join()
  end

  @doc """
  生成签名
  """
  def generate_md5_sign(secret, joined_params) do
    :crypto.hash(:md5, "#{secret}#{joined_params}#{secret}")
    |> Base.encode16(case: :upper)
  end

  @doc """
  发送一个POST网络请求
  """
  def post!(url, body, opts \\ []) do
    headers =
      opts
      |> Map.new
      |> Map.merge(Map.new(@default_headers))
      |> Map.to_list

    HTTPoison.post(url, body, headers, Keyword.drop(opts, [:headers]))
  end

  @doc """
  对返回的结构进行解析
  """
  def decode!(poison_result) do
    case poison_result do
      {:ok, %HTTPoison.Response{body: response_body, headers: _headers, status_code: 200}} ->
        {:ok, Poison.decode!(response_body)}
      {:ok, %HTTPoison.Response{body: _response_body, headers: _headers, status_code: status_code}} ->
        {:error, :"error_#{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, :"error_#{reason}"}
      _ ->
        {:error, :unknow_error}
    end
  end

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

    app_secret = sdk_key |> Aliqin.get_sdk_config() |> Map.get(:app_secret)
    sign_method = "md5"
    api_name = Aliqin.api_names |> Map.get(api_name_key)

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

    sign = md5_sign(app_secret, params)

    params = params |> Map.put(:sign, sign)

    post!("http://gw.api.taobao.com/router/rest", encode_post_data(params))
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
