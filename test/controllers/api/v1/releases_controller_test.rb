require "test_helper"

class Api::V1::ReleasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = @user.generate_jwt_token
    @auth_headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "should return unauthorized without token" do
    get api_v1_releases_url
    assert_response :unauthorized
  end

  test "should get index with authentication" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("releases")
    assert_kind_of Array, json_response["releases"]
  end

  test "index should return releases with nested artists and albums" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]
    assert releases.length >= 1

    release = releases.first
    assert release.key?("id")
    assert release.key?("title")
    assert release.key?("release_date")
    assert release.key?("release_type")
    assert release.key?("label")
    assert release.key?("artists")
    assert release.key?("albums")
  end

  test "should get show with authentication" do
    release = releases(:ok_computer_release)
    get api_v1_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("release")
    assert_equal release.title, json_response["release"]["title"]
    assert_equal release.label, json_response["release"]["label"]
  end

  test "show should return 404 for non-existent release" do
    get api_v1_release_url(id: 999999), headers: @auth_headers
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Release not found", json_response["error"]
  end

  test "show should include artists with role" do
    release = releases(:ok_computer_release)
    get api_v1_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    artists = json_response["release"]["artists"]
    assert artists.any? { |a| a["name"] == "Radiohead" }
    assert artists.first.key?("role")
    assert artists.first.key?("country")
  end

  test "show should include albums with full details" do
    release = releases(:ok_computer_release)
    get api_v1_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    albums = json_response["release"]["albums"]
    assert albums.length >= 1

    album = albums.first
    assert album.key?("id")
    assert album.key?("title")
    assert album.key?("genre")
    assert album.key?("total_tracks")
    assert album.key?("duration_seconds")
  end

  # Filtering tests
  test "should filter past releases" do
    get api_v1_releases_url, params: { filter: "past" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    # All returned releases should have release_date before today
    releases.each do |release|
      assert Date.parse(release["release_date"]) < Date.current
    end
  end

  test "should filter upcoming releases" do
    # Create an upcoming release for testing
    upcoming = Release.create!(
      title: "Future Album",
      release_date: 1.month.from_now,
      release_type: "album",
      label: "Future Records",
      catalog_number: "FUT-001"
    )

    get api_v1_releases_url, params: { filter: "upcoming" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    # All returned releases should have release_date >= today
    releases.each do |release|
      assert Date.parse(release["release_date"]) >= Date.current
    end

    # Cleanup
    upcoming.destroy
  end

  test "should filter by date range" do
    get api_v1_releases_url,
        params: { from: "1990-01-01", to: "2000-12-31" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      release_date = Date.parse(release["release_date"])
      assert release_date >= Date.new(1990, 1, 1)
      assert release_date <= Date.new(2000, 12, 31)
    end
  end

  test "should filter by release type" do
    get api_v1_releases_url, params: { type: "album" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert_equal "album", release["release_type"]
    end
  end

  test "should filter by label" do
    get api_v1_releases_url, params: { label: "Columbia" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert_equal "Columbia", release["label"]
    end
  end

  test "should return releases ordered by release date descending" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    dates = releases.map { |r| Date.parse(r["release_date"]) }
    assert_equal dates.sort.reverse, dates
  end

  # Additional filter tests
  test "should combine multiple filters" do
    get api_v1_releases_url,
        params: { filter: "past", type: "album", label: "Columbia" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert Date.parse(release["release_date"]) < Date.current
      assert_equal "album", release["release_type"]
      assert_equal "Columbia", release["label"]
    end
  end

  test "should filter singles only" do
    get api_v1_releases_url, params: { type: "single" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert_equal "single", release["release_type"]
    end
  end

  test "should return empty array when no releases match filter" do
    get api_v1_releases_url,
        params: { label: "NonExistentLabel12345" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response["releases"]
  end

  test "should filter with only from date" do
    get api_v1_releases_url, params: { from: "2010-01-01" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert Date.parse(release["release_date"]) >= Date.new(2010, 1, 1)
    end
  end

  test "should filter with only to date" do
    get api_v1_releases_url, params: { to: "1980-12-31" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      assert Date.parse(release["release_date"]) <= Date.new(1980, 12, 31)
    end
  end

  test "should ignore invalid filter value and return all releases" do
    get api_v1_releases_url, params: { filter: "invalid_filter" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    # Should return all releases when filter is invalid
    assert json_response["releases"].length >= 1
  end

  test "should filter past releases and specific label combined" do
    get api_v1_releases_url,
        params: { filter: "past", label: "Parlophone" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    assert releases.any? { |r| r["title"] == "OK Computer" }
    releases.each do |release|
      assert Date.parse(release["release_date"]) < Date.current
      assert_equal "Parlophone", release["label"]
    end
  end

  test "should filter by date range and type combined" do
    get api_v1_releases_url,
        params: { from: "2013-01-01", to: "2013-12-31", type: "album" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    releases = json_response["releases"]

    releases.each do |release|
      release_date = Date.parse(release["release_date"])
      assert release_date >= Date.new(2013, 1, 1)
      assert release_date <= Date.new(2013, 12, 31)
      assert_equal "album", release["release_type"]
    end
  end

  test "past filter should not include today releases" do
    # Create a release for today
    today_release = Release.create!(
      title: "Today Release",
      release_date: Date.current,
      release_type: "album",
      label: "Today Records",
      catalog_number: "TODAY-001"
    )

    get api_v1_releases_url, params: { filter: "past" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    titles = json_response["releases"].map { |r| r["title"] }

    assert_not_includes titles, "Today Release"

    # Cleanup
    today_release.destroy
  end

  test "upcoming filter should include today releases" do
    # Create a release for today
    today_release = Release.create!(
      title: "Today Release",
      release_date: Date.current,
      release_type: "album",
      label: "Today Records",
      catalog_number: "TODAY-001"
    )

    get api_v1_releases_url, params: { filter: "upcoming" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    titles = json_response["releases"].map { |r| r["title"] }

    assert_includes titles, "Today Release"

    # Cleanup
    today_release.destroy
  end

  # Pagination tests
  test "should include pagination metadata in response" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("pagination")

    pagination = json_response["pagination"]
    assert pagination.key?("current_page")
    assert pagination.key?("per_page")
    assert pagination.key?("total_pages")
    assert pagination.key?("total_count")
    assert pagination.key?("has_next_page")
    assert pagination.key?("has_prev_page")
  end

  test "should use default pagination of 10 per page" do
    # Create enough releases to test pagination
    15.times do |i|
      Release.create!(
        title: "Pagination Test #{i}",
        release_date: Date.new(2020, 1, i + 1),
        release_type: "album",
        label: "Test Label",
        catalog_number: "TEST-#{i}"
      )
    end

    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 10, pagination["per_page"]
    assert_equal 1, pagination["current_page"]
    assert json_response["releases"].length <= 10

    # Cleanup
    Release.where("title LIKE ?", "Pagination Test%").destroy_all
  end

  test "should respect custom per_page parameter" do
    get api_v1_releases_url, params: { per_page: 2 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 2, pagination["per_page"]
    assert json_response["releases"].length <= 2
  end

  test "should navigate to specific page" do
    # Create enough releases to have multiple pages
    12.times do |i|
      Release.create!(
        title: "Page Test #{i}",
        release_date: Date.new(2020, 1, i + 1),
        release_type: "album",
        label: "Page Label",
        catalog_number: "PAGE-#{i}"
      )
    end

    # Get page 2 with 5 per page
    get api_v1_releases_url, params: { page: 2, per_page: 5 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 2, pagination["current_page"]
    assert_equal 5, pagination["per_page"]
    assert pagination["has_prev_page"]

    # Cleanup
    Release.where("title LIKE ?", "Page Test%").destroy_all
  end

  test "should cap per_page at maximum of 100" do
    get api_v1_releases_url, params: { per_page: 500 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 100, pagination["per_page"]
  end

  test "should handle per_page of 0 or negative" do
    get api_v1_releases_url, params: { per_page: 0 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    # Should use minimum of 1
    assert pagination["per_page"] >= 1
  end

  test "should handle page 0 or negative" do
    get api_v1_releases_url, params: { page: -1 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    # Should default to page 1
    assert_equal 1, pagination["current_page"]
  end

  test "should calculate total_pages correctly" do
    # Clear existing and create exact number
    Release.where("title LIKE ?", "Total Pages Test%").destroy_all

    7.times do |i|
      Release.create!(
        title: "Total Pages Test #{i}",
        release_date: Date.new(2021, 1, i + 1),
        release_type: "album",
        label: "Total Label",
        catalog_number: "TOTAL-#{i}"
      )
    end

    # With fixtures, we have more releases. Filter to just our test releases.
    get api_v1_releases_url, params: { per_page: 3, label: "Total Label" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    # 7 releases / 3 per page = 3 pages (ceil)
    assert_equal 7, pagination["total_count"]
    assert_equal 3, pagination["total_pages"]

    # Cleanup
    Release.where("title LIKE ?", "Total Pages Test%").destroy_all
  end

  test "should indicate has_next_page correctly" do
    5.times do |i|
      Release.create!(
        title: "Next Page Test #{i}",
        release_date: Date.new(2022, 1, i + 1),
        release_type: "album",
        label: "Next Label",
        catalog_number: "NEXT-#{i}"
      )
    end

    # Page 1 of 3 (5 releases, 2 per page)
    get api_v1_releases_url, params: { page: 1, per_page: 2, label: "Next Label" }, headers: @auth_headers
    json_response = JSON.parse(response.body)
    assert json_response["pagination"]["has_next_page"]

    # Last page
    get api_v1_releases_url, params: { page: 3, per_page: 2, label: "Next Label" }, headers: @auth_headers
    json_response = JSON.parse(response.body)
    assert_not json_response["pagination"]["has_next_page"]

    # Cleanup
    Release.where("title LIKE ?", "Next Page Test%").destroy_all
  end

  test "should indicate has_prev_page correctly" do
    3.times do |i|
      Release.create!(
        title: "Prev Page Test #{i}",
        release_date: Date.new(2023, 1, i + 1),
        release_type: "album",
        label: "Prev Label",
        catalog_number: "PREV-#{i}"
      )
    end

    # Page 1 should not have prev
    get api_v1_releases_url, params: { page: 1, per_page: 1, label: "Prev Label" }, headers: @auth_headers
    json_response = JSON.parse(response.body)
    assert_not json_response["pagination"]["has_prev_page"]

    # Page 2 should have prev
    get api_v1_releases_url, params: { page: 2, per_page: 1, label: "Prev Label" }, headers: @auth_headers
    json_response = JSON.parse(response.body)
    assert json_response["pagination"]["has_prev_page"]

    # Cleanup
    Release.where("title LIKE ?", "Prev Page Test%").destroy_all
  end

  test "pagination should work with filters" do
    6.times do |i|
      Release.create!(
        title: "Filter Pagination Test #{i}",
        release_date: Date.new(2019, 6, i + 1),
        release_type: "album",
        label: "Filter Pagination Label",
        catalog_number: "FP-#{i}"
      )
    end

    get api_v1_releases_url,
        params: { per_page: 2, label: "Filter Pagination Label" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    pagination = json_response["pagination"]

    assert_equal 6, pagination["total_count"]
    assert_equal 3, pagination["total_pages"]
    assert_equal 2, json_response["releases"].length

    # Cleanup
    Release.where("title LIKE ?", "Filter Pagination Test%").destroy_all
  end

  test "should return empty releases with correct pagination for out of range page" do
    get api_v1_releases_url, params: { page: 9999, per_page: 10 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)

    assert_equal [], json_response["releases"]
    assert_equal 9999, json_response["pagination"]["current_page"]
  end
end
