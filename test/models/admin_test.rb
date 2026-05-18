require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "normalizes email" do
    admin = Admin.new(email: "  Admin@BiDesk.Local  ", password: "password123")
    assert_equal "admin@bidesk.local", admin.email
  end

  test "authenticates with password" do
    admin = admins(:one)
    assert admin.authenticate("password123")
    assert_not admin.authenticate("wrong")
  end
end
