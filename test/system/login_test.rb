require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  test "visiting login" do
    visit login_path
    assert_selector "h1", text: "BiDesk"
  end
end
