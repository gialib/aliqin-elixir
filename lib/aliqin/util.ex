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
  发送一个POSt网络请求
  """
  def post!(url, body, opts \\ []) do
    headers =
      opts
      |> Map.new
      |> Map.merge(Map.new(@default_headers))
      |> Map.to_list

    HTTPoison.post!(url, body, headers, Keyword.drop(opts, [:headers]))
  end

end
