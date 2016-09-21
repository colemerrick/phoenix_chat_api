defmodule PhoenixChat.OrganizationControllerTest do
  use PhoenixChat.ConnCase

  alias PhoenixChat.{Organization, Repo}
  @valid_attrs %{website: "http://www.foo.com", owner_id: 1}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, organization_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    create_user!(%{id: 1})
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    org = Repo.insert!(changeset)

    conn = get conn, organization_path(conn, :show, org)
    response = json_response(conn, 200)["data"]
    assert %{"public_key" => _, "owner_id" => 1, "website" => "http://www.foo.com",
      "id" => _} = response
  end

  test "does not show resource instead throws error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, organization_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    create_user!(%{id: 1})
    conn = post conn, organization_path(conn, :create), organization: @valid_attrs

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Organization, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, organization_path(conn, :create), organization: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    create_user!(%{id: 1})
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    org = Repo.insert!(changeset)

    new_attrs = %{website: "http://www.bar.com"}
    conn = put conn, organization_path(conn, :update, org), organization: new_attrs

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Organization, new_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    create_user!(%{id: 1})
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    org  = Repo.insert!(changeset)
    conn = put conn, organization_path(conn, :update, org), organization: %{website: nil}

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    create_user!(%{id: 1})
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    org  = Repo.insert!(changeset)
    conn = delete conn, organization_path(conn, :delete, org)

    assert response(conn, 204)
    refute Repo.get(Organization, org.id)
  end
  # use PhoenixChat.ConnCase

  # alias PhoenixChat.Organization
  # @valid_attrs %{public_key: "some content", website: "some content"}
  # @invalid_attrs %{}

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, organization_path(conn, :index)
  #   assert json_response(conn, 200)["data"] == []
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   organization = Repo.insert! %Organization{}
  #   conn = get conn, organization_path(conn, :show, organization)
  #   assert json_response(conn, 200)["data"] == %{"id" => organization.id,
  #     "public_key" => organization.public_key,
  #     "website" => organization.website,
  #     "owner_id" => organization.owner_id}
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, organization_path(conn, :show, -1)
  #   end
  # end

  # test "creates and renders resource when data is valid", %{conn: conn} do
  #   conn = post conn, organization_path(conn, :create), organization: @valid_attrs
  #   assert json_response(conn, 201)["data"]["id"]
  #   assert Repo.get_by(Organization, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, organization_path(conn, :create), organization: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   organization = Repo.insert! %Organization{}
  #   conn = put conn, organization_path(conn, :update, organization), organization: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(Organization, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   organization = Repo.insert! %Organization{}
  #   conn = put conn, organization_path(conn, :update, organization), organization: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   organization = Repo.insert! %Organization{}
  #   conn = delete conn, organization_path(conn, :delete, organization)
  #   assert response(conn, 204)
  #   refute Repo.get(Organization, organization.id)
  # end
end
