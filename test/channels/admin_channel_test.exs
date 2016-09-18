defmodule PhoenixChat.AdminChannelTest do
  use PhoenixChat.ChannelCase

  alias PhoenixChat.{AdminChannel, LobbyList}

  setup do
    on_exit fn ->
      :ets.delete_all_objects(LobbyList)
    end
  end

  test "joining admin:active_users as admin" do
    LobbyList.insert("foo")
    LobbyList.insert("bar")

    {:ok, %{lobby_list: lobby_list}, _socket} =
      socket("user_id", %{user_id: 1})
      |> subscribe_and_join(AdminChannel, "admin:active_users")

    assert length(lobby_list) == 2
    assert_push "lobby_list", %{uuid: 1}
    assert_push "presence_state", %{}
    assert_push "presence_diff", %{joins: %{"1" => %{}}}
  end

  test "non-admin users do not receive the 'lobby_list' event on join" do
    {:ok, %{lobby_list: _}, _} =
      socket("user_id", %{user_id: nil, uuid: 5})
      |> subscribe_and_join(AdminChannel, "admin:active_users")

    refute_push "lobby_list", %{}
  end

end