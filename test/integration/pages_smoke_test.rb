require "test_helper"

class PagesSmokeTest < ActionDispatch::IntegrationTest
  setup do
    post login_path, params: { email: admins(:one).email, password: "password123" }
    assert_redirected_to dashboard_path
    follow_redirect!
  end

  %w[
    /clientes
    /clientes/new
    /estoque
    /estoque/new
    /financeiro
    /financeiro/new
    /manutencao
    /manutencao/new
  ].each do |path|
    test "GET #{path} succeeds" do
      get path
      assert_response :success, "expected #{path} to render"
    end
  end

  test "clientes CSV export" do
    get clientes_path(format: :csv)
    assert_response :success
    assert_match %r{\Atext/csv}, response.media_type
    assert_includes response.body, "Nome"
  end
end
