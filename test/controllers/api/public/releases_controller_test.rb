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
    assert json_response.key?("data")
    assert json_response.key?("links")
    assert json_response.key?("included")
    assert json_response.key?("meta")
  end

  test "should return authenticated false without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal false, json_response["meta"]["authenticated"]
  end

  test "should get show without authentication" do
    release = releases(:ok_computer_release)
    get api_public_release_url(release)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("data")
    assert json_response.key?("meta")
    assert_equal false, json_response["meta"]["authenticated"]
  end

  test "should return basic release data without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    release = json_response["data"].first

    # Should have basic fields in attributes
    assert release.key?("id")
    assert_equal "releases", release["type"]
    assert release["attributes"].key?("title")
    assert release["attributes"].key?("release_date")
    assert release["attributes"].key?("release_type")
    assert release["attributes"].key?("label")
    assert release["relationships"].key?("artists")

    # Should NOT have private fields in attributes
    assert_not release["attributes"].key?("catalog_number")
    assert_not release["attributes"].key?("created_at")
    assert_not release["attributes"].key?("updated_at")
    # Should NOT have albums relationship
    assert_not release["relationships"].key?("albums")
  end

  test "should return basic artist data without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    artists = json_response["included"].select { |r| r["type"] == "artists" }
    assert artists.any?

    artist = artists.first

    # Should have basic fields
    assert artist.key?("id")
    assert artist["attributes"].key?("name")

    # Should NOT have private fields
    assert_not artist["attributes"].key?("country")
    assert_not artist.key?("meta")
  end

  # ==========================================
  # Authenticated Access Tests
  # ==========================================

  test "should return authenticated true with authentication" do
    get api_public_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal true, json_response["meta"]["authenticated"]
  end

  test "should return full release data with authentication" do
    get api_public_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    release = json_response["data"].first

    # Should have all fields including private ones
    assert release.key?("id")
    assert release["attributes"].key?("title")
    assert release["attributes"].key?("release_date")
    assert release["attributes"].key?("release_type")
    assert release["attributes"].key?("label")
    assert release["attributes"].key?("catalog_number")
    assert release["attributes"].key?("created_at")
    assert release["attributes"].key?("updated_at")
    assert release["relationships"].key?("artists")
    assert release["relationships"].key?("albums")
  end

  test "should return full artist data with authentication" do
    get api_public_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    artists = json_response["included"].select { |r| r["type"] == "artists" }
    assert artists.any?

    artist = artists.first

    # Should have all fields including private ones
    assert artist.key?("id")
    assert artist["attributes"].key?("name")
    assert artist["attributes"].key?("country")
    assert artist.key?("meta")
    assert artist["meta"].key?("role")
  end

  test "show should return authenticated true with authentication" do
    release = releases(:ok_computer_release)
    get api_public_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal true, json_response["meta"]["authenticated"]
  end

  test "show should return full data with authentication" do
    release = releases(:ok_computer_release)
    get api_public_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    release_data = json_response["data"]

    # Should have private fields
    assert release_data["attributes"].key?("catalog_number")
    assert release_data["relationships"].key?("albums")
  end

  # ==========================================
  # Filter Tests
  # ==========================================

  test "should filter past releases without authentication" do
    get api_public_releases_url, params: { filter: "past" }
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) < Date.current
    end
  end

  test "should filter by release type without authentication" do
    get api_public_releases_url, params: { type: "album" }
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert_equal "album", release["attributes"]["release_type"]
    end
  end

  test "should filter by label without authentication" do
    get api_public_releases_url, params: { label: "Columbia" }
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert_equal "Columbia", release["attributes"]["label"]
    end
  end

  # ==========================================
  # Pagination Tests
  # ==========================================

  test "should include pagination links without authentication" do
    get api_public_releases_url
    assert_response :success

    json_response = JSON.parse(response.body)
    links = json_response["links"]

    assert links.key?("self")
    assert links.key?("first")
    assert links.key?("last")
  end

  test "should respect per_page parameter without authentication" do
    get api_public_releases_url, params: { per_page: 2 }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["data"].length <= 2
  end

  # ==========================================
  # Error Handling Tests
  # ==========================================

  test "should return 404 for non-existent release" do
    get api_public_release_url(id: 999999)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
    assert_equal "Not Found", json_response["errors"].first["title"]
  end

  test "should handle invalid token gracefully" do
    invalid_headers = { "Authorization" => "Bearer invalid_token_here" }
    get api_public_releases_url, headers: invalid_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal false, json_response["meta"]["authenticated"]
  end
end
