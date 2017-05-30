defmodule Aliqin.SmsAPI do

  ## ## https://api.alidayu.com/docs/api.htm?spm=a3142.7395905.4.6.2sEFoj&apiId=25450

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
  def num_send!(sdk_key, opts \\ []) do
    templdate_key = :"#{Keyword.get(opts, :templdate_key)}"

    params = %{
      sms_type: "normal"
    }

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
      if templdate_code = get_in(Aliqin.get_sdk_config(sdk_key), [:usages, :sms_num_send, :templdate_codes, templdate_key]) do
        params |> Map.put(:sms_template_code, templdate_code)
      else
        params
      end

    Aliqin.execute(sdk_key, :sms_num_send, params) |> Aliqin.Util.decode!
  end

end
