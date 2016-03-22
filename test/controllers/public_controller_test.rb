require 'test_helper'

class PublicControllerTest < ActionController::TestCase
  test "should get landing" do
    get :landing
    assert_response :success
  end

end
