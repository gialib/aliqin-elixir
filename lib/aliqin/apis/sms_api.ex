defmodule Aliqin.SmsAPI do

  ## ## https://api.alidayu.com/docs/api.htm?spm=a3142.7395905.4.6.2sEFoj&apiId=25450

  require Logger

  @doc """
  发送手机短信
  ```
  ## opts
  * sign_name(*)        # 签名名称
  * numbers(* List)     # 接收方的手机号
  * templdate_key(*)    # 模板的标识
  * sms_params(* Map)   # 自定义
  * extend              # 扩展参数
  ## return
  * 成功
    {
      :ok,
      %{
        "alibaba_aliqin_fc_sms_num_send_response" => %{
          "request_id" => "2el3seggq8bk",
          "result" => %{
            "err_code" => "0",
            "model" => "107841060691^1110524204993",
            "success" => true
          }
        }
      }
    }
  * 失败: 频率过高
    {
      :ok,
      %{
        "error_response" => %{
          "code" => 15,
          "msg" => "Remote service error",
          "request_id" => "10cgrzyb02x1i",
          "sub_code" => "isv.BUSINESS_LIMIT_CONTROL",
          "sub_msg" => "触发业务流控"
        }
      }
    }
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

    response = Aliqin.execute(sdk_key, :sms_num_send, params) |> Aliqin.Util.decode!

    final_response =
      case response do
        {:ok, response_body} ->
          case response_body do
            %{"alibaba_aliqin_fc_sms_num_send_response" => %{"request_id" => request_id, "result" => %{"err_code" => "0", "model" => request_model, "success" => true}}} ->
              {:ok, %{request_id: request_id, request_model: request_model}}
            %{"error_response" => %{"code" => error_code, "msg" => error_message, "request_id" => request_id}} ->
              {:error, %{error_key: :send_fail, error_message: error_message, request_id: request_id, error_code: error_code}}
            _ ->
              {:error, %{error_key: :unknown_error, response_body: response_body}}
          end
        {:error, error_key} -> {:error, %{error_key: error_key}}
      end

    case final_response do
      {:ok, response_body} -> Logger.info(inspect([__MODULE__, :num_send!, :ok, response_body]))
      {:error, error_key} -> Logger.error(inspect([__MODULE__, :num_send!, :fail, error_key]))
    end

    final_response
  end

end
