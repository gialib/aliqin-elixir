defmodule Aliqin.ConfigMissing do
  defexception [:message]

  alias Aliqin.ConfigMissing

  def exception([message: message]) do
    %ConfigMissing{message: message}
  end

end
