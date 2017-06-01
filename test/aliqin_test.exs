defmodule AliqinTest do
  use ExUnit.Case

  alias Aliqin

  # 测试签名错误的情况
  test "sms_num_send! fail" do
    {:error, response} =
      Aliqin.sms_num_send!(">>>>app_key<<<<", [
        sign_name: "签名",
        templdate_key: :regiester_verify_code,
        numbers: ["13100000000"],
        sms_params: %{
          code: "938402",
          product: "签名"
        }
      ])

    {:error, %{error_code: 29, error_key: :send_fail, error_message: "Invalid app Key", request_id: "z2ak7m069sah"}}

    assert Map.take(response, [:error_code, :error_key, :error_message]) == %{
      error_code: 29,
      error_key: :send_fail,
      error_message: "Invalid app Key"
    }
  end

  test "sms_num_send! with mock success" do

  end
end
