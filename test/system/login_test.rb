require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  test "visiting login" do
    visit login_path
    assert_selector "h1", text: "FAÇA LOGIN"
    assert_selector "h2", text: /BiDesk/
    assert_button "ENTRAR"
  end
end
