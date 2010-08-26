require File.dirname(__FILE__) + '/../test_helper'

class PublishedControllerTest < ActionController::IntegrationTest 

  fixtures :all

  def setup
  end

  def test_index
    ActionController::IntegrationTest::reset_auth
    get "/published"
    assert_response 401

    prepare_request_with_user "tom", "thunder"
    get "/published"
    assert_response :success
  end

  def test_binary_view
    ActionController::IntegrationTest::reset_auth
    get "/published/kde4/openSUSE_11.3/i586/kdelibs-3.2.1-1.5.i586.rpm"
    assert_response 401

    prepare_request_with_user "tom", "thunder"
    get "/published/kde4/openSUSE_11.3/i586/kdelibs-3.2.1-1.5.i586.rpm"
    assert_response 400 #does not exist
  end
  # FIXME: this needs to be extended, when we have added binaries and bs_publisher to the test suite

end