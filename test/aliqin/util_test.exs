defmodule Aliqin.UtilTest do
  use ExUnit.Case

  alias Aliqin.Util

  @original_params [
    method: "taobao.item.seller.get",
    fields: "num_iid,title,nick,price,num",
    app_key: "12345678",
    session: "test",
    num_iid: 11223344,
    timestamp: "2016-01-01 12:00:00",
    format: "json",
    v: "2.0",
    sign_method: "md5"
  ]

  @sorted_params [
    app_key: "12345678",
    fields: "num_iid,title,nick,price,num",
    format: "json",
    method: "taobao.item.seller.get",
    num_iid: 11223344,
    session: "test",
    sign_method: "md5",
    timestamp: "2016-01-01 12:00:00",
    v: "2.0"
  ]

  test "sort_params ok" do
    assert Util.sort_params(@original_params) == @sorted_params
  end

  test "join_params OK" do
    assert Util.join_params(@sorted_params) == "app_key12345678fieldsnum_iid,title,nick,price,numformatjsonmethodtaobao.item.seller.getnum_iid11223344sessiontestsign_methodmd5timestamp2016-01-01 12:00:00v2.0"
  end

  test "generate_md5_sign OK" do
    assert Util.generate_md5_sign("helloworld", Util.join_params(@sorted_params)) == "66987CB115214E59E6EC978214934FB8"
  end

  test "md5_sign OK" do
    assert Util.md5_sign("helloworld", @original_params) == "66987CB115214E59E6EC978214934FB8"
  end
end
