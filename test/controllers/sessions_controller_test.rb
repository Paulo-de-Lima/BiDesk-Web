require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login page" do
    get login_path
    assert_response :success
  end

  test "sign in with valid credentials" do
    post login_path, params: { email: admins(:one).email, password: "password123" }
    assert_redirected_to dashboard_path
  end

  test "sign in with invalid credentials" do
    post login_path, params: { email: admins(:one).email, password: "wrong" }
    assert_response :unprocessable_entity
  end
end
