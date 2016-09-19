defmodule PhoenixChat.MessageTest do
  use PhoenixChat.ModelCase

  alias PhoenixChat.Message

  @valid_attrs %{body: "some content", from: "some content", room: "some content", timestamp: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    %{errors: errors} = Message.changeset(%Message{}, @invalid_attrs)
    assert {:body, {"can't be blank", []}} in errors
    assert {:timestamp, {"can't be blank", []}} in errors
    assert {:room, {"can't be blank", []}} in errors
  end

  test "query that returns latest messages of a given room" do
    first  = Ecto.DateTime.from_erl({{2016, 5, 23}, {12, 30, 12}})
    second = Ecto.DateTime.from_erl({{2016, 5, 24}, {12, 30, 12}})
    third  = Ecto.DateTime.from_erl({{2016, 5, 25}, {12, 30, 12}})
    Repo.insert!(%Message{room: "1", body: "test", timestamp: first})
    Repo.insert!(%Message{room: "1", body: "test", timestamp: second})
    Repo.insert!(%Message{room: "1", body: "test", timestamp: third})
    Repo.insert!(%Message{room: "2", body: "test", timestamp: Ecto.DateTime.utc()})

    messages = Message.latest_room_messages("1", 2) |> Repo.all
    assert length(messages) == 2

    [msg1 | [msg2]] = messages
    assert Ecto.DateTime.compare(msg2.timestamp, second) == :eq
    assert Ecto.DateTime.compare(msg1.timestamp, msg2.timestamp) == :gt
    assert {10, :integer} in Message.latest_room_messages("1").limit.params
  end

end
