require "test_helper"

class Api::Public::ReleasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = @user.generate_jwt_token
    @auth_headers = { "Authorization" => "Bearer #{@token}" }
  end

  # ==========================================
  # Public Access Tests (No Authentication)
  # ==========================================

  test "should get index without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("releases")
    assert json_response.key?("pagination")
    assert json_response.key?("is_private")
  end

  test "should return is_private false without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal false, json_response["is_private"]
  end

  test "should get show without authentication" do
    release = releases(:ok_computer_release)
    get api_public_release_url(release)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("release")
    assert json_response.key?("is_private")
    assert_equal false, json_response["is_private"]
  end

  test "should return basic release data without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    release = json_response["releases"].first

    # Should have basic fields
    assert release.key?("id")
    assert release.key?("title")
    assert release.key?("release_date")
    assert release.key?("release_type")
    assert release.key?("label")
    assert release.key?("artists")

    # Should NOT have private fields
    assert_not release.key?("catalog_number")
    assert_not release.key?("albums")
    assert_not release.key?("created_at")
    assert_not release.key?("updated_at")
  end

  test "should return basic artist data without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    release = json_response["releases"].find { |r| r["artists"].any? }
    artist = release["artists"].first

    # Should have basic fields
    assert artist.key?("id")
    assert artist.key?("name")

    # Should NOT have private fields
    assert_not artist.key?("country")
    assert_not artist.key?("role")
  end

  # ==========================================
  # Authenticated Access Tests
  # ==========================================

  test "should return is_private true with authentication" do
    get api_public_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal true, json_response["is_private"]
  end

  test "should return full release data with authentication" do
    get api_public_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    release = json_response["releases"].first

    # Should have all fields including private ones
    assert release.key?("id")
    assert release.key?("title")
    assert release.key?("release_date")
    assert release.key?("release_type")
    assert release.key?("label")
    assert release.key?("catalog_number")
    assert release.key?("albums")
    assert release.key?("created_at")
    assert release.key?("updated_at")
    assert release.key?("artists")
  end

  test "should return full artist data with authentication" do
    get api_public_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    release = json_response["releases"].find { |r| r["artists"].any? }
    artist = release["artists"].first

    # Should have all fields including private ones
    assert artist.key?("id")
    assert artist.key?("name")
    assert artist.key?("country")
    assert artist.key?("role")
  end

  test "show should return is_private true with authentication" do
    release = releases(:ok_computer_release)
    get api_public_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal true, json_response["is_private"]
  end

  test "show should return full data with authentication" do
    release = releases(:ok_computer_release)
    get api_public_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    release_data = json_response["release"]

    # Should have private fields
    assert release_data.key?("catalog_number")
    assert release_data.key?("albums")
  end

  # ==========================================
  # Filter Tests
  # ==========================================

  test "should filter past releases without authentication" do
    get api_public_releases_url, params: { filter: "past" }
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert Date.parse(release["release_date"]) < Date.current
    end
  end

  test "should filter by release type without authentication" do
    get api_public_releases_url, params: { type: "album" }
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert_equal "album", release["release_type"]
    end
  end

  test "should filter by label without authentication" do
    get api_public_releases_url, params: { label: "Columbia" }
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert_equal "Columbia", release["label"]
    end
  end

  # ==========================================
  # Pagination Tests
  # ==========================================

  test "should include pagination without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert pagination.key?("current_page")
    assert pagination.key?("per_page")
    assert pagination.key?("total_pages")
    assert pagination.key?("total_count")
  end

  test "should respect per_page parameter without authentication" do
    get api_public_releases_url, params: { per_page: 2 }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["releases"].length <= 2
    assert_equal 2, json_response["pagination"]["per_page"]
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "should return 404 for non-existent release" do
    get api_public_release_url(id: 999999)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Release not found", json_response["error"]
  end

  test "should handle invalid token gracefully" do
    invalid_headers = { "Authorization" => "Bearer invalid_token_here" }
    get api_public_releases_url, headers: invalid_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    # Should still work but as unauthenticated
    assert_equal false, json_response["is_private"]
  end
end
