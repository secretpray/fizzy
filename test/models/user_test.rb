require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "create" do
    user = User.create! \
      account: accounts("37s"),
      name: "Victor Cooper",
      email_address: "victor@hey.com",
      password: "secret123456"

    assert_equal accounts("37s"), user.account
    assert_equal user, User.authenticate_by(email_address: "victor@hey.com", password: "secret123456")
  end

  test "creation gives access to all_access buckets" do
    user = User.create! \
      account: accounts("37s"),
      name: "Victor Cooper",
      email_address: "victor@hey.com",
      password: "secret123456"

    assert_equal [ buckets(:writebook) ], user.buckets
  end

  test "deactivate" do
    assert_changes -> { users(:jz).active? }, from: true, to: false do
      users(:jz).deactivate
    end
  end

  test "initials" do
    assert_equal "JF", User.new(name: "jason fried").initials
    assert_equal "DHH", User.new(name: "David Heinemeier Hansson").initials
    assert_equal "ÉLH", User.new(name: "Éva-Louise Hernández").initials
  end
end
