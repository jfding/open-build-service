require File.expand_path(File.dirname(__FILE__) + "/..") + "/test_helper"

class IssueTrackersControllerTest < ActionController::IntegrationTest
  def test_should_get_index
    ActionController::IntegrationTest::reset_auth
    # Get all issue trackers
    get '/issue_trackers'
    assert_response :success
    assert_not_nil assigns(:issue_trackers)
  end

  def test_create_and_update_new_trackers
    # Create a new issue tracker
    issue_tracker_xml = <<-EOF
    <issue-tracker>
      <name>test</name>
      <description>My test issue tracker</description>
      <regex>test#\d+test</regex>
      <kind>bugzilla</kind>
      <user>obsbugbot</user>
      <password>secret</password>
      <url>http://example.com</url>
      <show-url>http://example.com/@@@</show-url>
    </issue-tracker>
    EOF
    ActionController::IntegrationTest::reset_auth
    post '/issue_trackers', issue_tracker_xml
    assert_response 401
    prepare_request_with_user "adrian", "so_alone"
    post '/issue_trackers', issue_tracker_xml
    assert_response 403
    prepare_request_with_user "king", "sunflower"
    post '/issue_trackers', issue_tracker_xml
    assert_response :success

    # Show the newly created issue tracker
    get '/issue_trackers/test'
    assert_response :success
    assert_tag :tag => "name", :content => "test"
    assert_tag :tag => "description", :content => "My test issue tracker"
    assert_tag :tag => "regex", :content => "test#\d+test"
    assert_tag :tag => "kind", :content => "bugzilla"
    assert_tag :tag => "url", :content => "http://example.com"
    assert_tag :tag => "show-url", :content => "http://example.com/@@@"
    assert_no_tag :tag => "password"
    get '/issue_trackers/test.json'
    assert_response :success

#FIXME: check backend data

    # Update that issue tracker
    issue_tracker_xml = <<-EOF
    <issue-tracker>
      <name>test</name>
      <description>My even better test issue tracker</description>
      <regex>tester#\d+</regex>
      <kind>cve</kind>
      <url>http://test.com</url>
      <show-url>http://test.com/@@@</show-url>
    </issue-tracker>
    EOF
    prepare_request_with_user "adrian", "so_alone"
    put '/issue_trackers/test', issue_tracker_xml
    assert_response 403
    prepare_request_with_user "king", "sunflower"
    put '/issue_trackers/test', issue_tracker_xml
    assert_response :success
    get '/issue_trackers/test'
    assert_response :success
    assert_tag :tag => "name", :content => "test"
    assert_tag :tag => "description", :content => "My even better test issue tracker"
    assert_tag :tag => "regex", :content => "tester#\d+"
    assert_tag :tag => "kind", :content => "cve"
    assert_tag :tag => "url", :content => "http://test.com"
    assert_tag :tag => "show-url", :content => "http://test.com/@@@"
    assert_no_tag :tag => "password"

    # Delete that issue tracker again
    prepare_request_with_user "adrian", "so_alone"
    delete '/issue_trackers/test'
    assert_response 403
    prepare_request_with_user "king", "sunflower"
    delete '/issue_trackers/test'
    assert_response :success
  end

  def test_get_issues_in_text
    ActionController::IntegrationTest::reset_auth
    text = <<EOF
@@ -1,4 +1,12 @@
 -------------------------------------------------------------------
+Fri Nov  4 08:33:52 UTC 2011 - lijewski.stefan@gmail.com
+
+- fix possible overflow and DOS in pam_env (bnc#724480)
+  CVE-2011-3148, CVE-2011-3149
+- fix pam_xauth not checking return value of setuid (bnc#631802)
+  CVE-2010-3316
+  blabla bnc#666
+
  +-------------------------------------------------------------------
   Thu Nov 27 15:56:51 CET 2008 - mc@suse.de
 
 - enhance the man page for limits.conf (bnc#448314)")
-  bnc#12345, bnc#666
EOF
    get '/issue_trackers/issues_in', :text => text
    assert_response 401
    prepare_request_with_user "adrian", "so_alone"
    get '/issue_trackers/issues_in', :text => text
    assert_response :success
    assert_tag :tag => "issue_tracker", :content => "bnc"
    assert_tag :tag => "issue_tracker", :content => "cve"
    assert_tag :tag => "long_name", :content => "bnc#724480"
    assert_tag :tag => "name", :content => "448314"
    assert_tag :tag => "name", :content => "631802"
    assert_tag :tag => "name", :content => "724480"
    assert_tag :tag => "name", :content => "CVE-2011-3148"
    assert_tag :tag => "name", :content => "CVE-2011-3149"
    assert_tag :tag => "name", :content => "CVE-2010-3316"
    assert_tag :tag => "long_name", :content => "bnc#12345"
    assert_tag :tag => "long_name", :content => "bnc#666"
    assert_no_tag :tag => "password"

    get '/issue_trackers/issues_in', :text => text, :diff_mode => true
    assert_response :success
    assert_no_tag :tag => "name", :content => "448314"
    assert_tag :tag => "name", :content => "631802"
    assert_tag :tag => "name", :content => "724480"
    assert_tag :tag => "name", :content => "CVE-2011-3148"
    assert_tag :tag => "name", :content => "CVE-2011-3149"
    assert_tag :tag => "name", :content => "CVE-2010-3316"
    assert_tag :tag => "long_name", :content => "bnc#12345"
    assert_no_tag :tag => "long_name", :content => "bnc#666"
    assert_no_tag :tag => "password"
  end
end
