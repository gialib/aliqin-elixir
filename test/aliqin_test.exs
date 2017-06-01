defmodule AliqinTest do
  use ExUnit.Case

  alias Aliqin

  # 测试签名错误的情况
  test "sms_num_send! fail" do
    {:ok, response_body} =
      Aliqin.sms_num_send!(">>>>app_key<<<<", [
        sign_name: "签名",
        templdate_key: :regiester_verify_code,
        numbers: ["13100000000"],
        sms_params: %{
          code: "938402",
          product: "签名"
        }
      ])

    assert get_in(response_body, ["error_response", "code"]) == 29
    assert get_in(response_body, ["error_response", "msg"]) == "Invalid app Key"
    assert get_in(response_body, ["error_response", "sub_code"]) == "isv.appkey-not-exists"
  end

  test "sms_num_send! with mock success" do

  end
end
