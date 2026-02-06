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
    assert json_response.key?("data")
    assert json_response.key?("links")
    assert json_response.key?("included")
    assert_kind_of Array, json_response["data"]
  end

  test "index should return releases in JSON:API format with relationships" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]
    assert data.length >= 1

    release = data.first
    assert_equal "releases", release["type"]
    assert release.key?("id")
    assert release.key?("attributes")
    assert release.key?("relationships")
    assert release.key?("links")

    attributes = release["attributes"]
    assert attributes.key?("title")
    assert attributes.key?("release_date")
    assert attributes.key?("release_type")
    assert attributes.key?("label")

    assert release["relationships"].key?("artists")
    assert release["relationships"].key?("albums")
  end

  test "should get show with authentication" do
    release = releases(:ok_computer_release)
    get api_v1_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("data")
    assert_equal "releases", json_response["data"]["type"]
    assert_equal release.title, json_response["data"]["attributes"]["title"]
    assert_equal release.label, json_response["data"]["attributes"]["label"]
  end

  test "show should return 404 for non-existent release" do
    get api_v1_release_url(id: 999999), headers: @auth_headers
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
    assert_equal "Not Found", json_response["errors"].first["title"]
  end

  test "show should include artists in included" do
    release = releases(:ok_computer_release)
    get api_v1_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    artists = json_response["included"].select { |r| r["type"] == "artists" }
    assert artists.any? { |a| a["attributes"]["name"] == "Radiohead" }
  end

  test "show should include albums in included" do
    release = releases(:ok_computer_release)
    get api_v1_release_url(release), headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    albums = json_response["included"].select { |r| r["type"] == "albums" }
    assert albums.length >= 1

    album = albums.first
    assert album.key?("id")
    assert album["attributes"].key?("title")
    assert album["attributes"].key?("genre")
    assert album["attributes"].key?("total_tracks")
    assert album["attributes"].key?("duration_seconds")
  end

  # Filtering tests
  test "should filter past releases" do
    get api_v1_releases_url, params: { filter: "past" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) < Date.current
    end
  end

  test "should filter upcoming releases" do
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
    data = json_response["data"]

    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) >= Date.current
    end

    upcoming.destroy
  end

  test "should filter by date range" do
    get api_v1_releases_url,
        params: { from: "1990-01-01", to: "2000-12-31" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      release_date = Date.parse(release["attributes"]["release_date"])
      assert release_date >= Date.new(1990, 1, 1)
      assert release_date <= Date.new(2000, 12, 31)
    end
  end

  test "should filter by release type" do
    get api_v1_releases_url, params: { type: "album" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert_equal "album", release["attributes"]["release_type"]
    end
  end

  test "should filter by label" do
    get api_v1_releases_url, params: { label: "Columbia" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert_equal "Columbia", release["attributes"]["label"]
    end
  end

  test "should return releases ordered by release date descending" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    dates = data.map { |r| Date.parse(r["attributes"]["release_date"]) }
    assert_equal dates.sort.reverse, dates
  end

  # Additional filter tests
  test "should combine multiple filters" do
    get api_v1_releases_url,
        params: { filter: "past", type: "album", label: "Columbia" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) < Date.current
      assert_equal "album", release["attributes"]["release_type"]
      assert_equal "Columbia", release["attributes"]["label"]
    end
  end

  test "should filter singles only" do
    get api_v1_releases_url, params: { type: "single" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert_equal "single", release["attributes"]["release_type"]
    end
  end

  test "should return empty array when no releases match filter" do
    get api_v1_releases_url,
        params: { label: "NonExistentLabel12345" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response["data"]
  end

  test "should filter with only from date" do
    get api_v1_releases_url, params: { from: "2010-01-01" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) >= Date.new(2010, 1, 1)
    end
  end

  test "should filter with only to date" do
    get api_v1_releases_url, params: { to: "1980-12-31" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) <= Date.new(1980, 12, 31)
    end
  end

  test "should ignore invalid filter value and return all releases" do
    get api_v1_releases_url, params: { filter: "invalid_filter" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["data"].length >= 1
  end

  test "should filter past releases and specific label combined" do
    get api_v1_releases_url,
        params: { filter: "past", label: "Parlophone" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    assert data.any? { |r| r["attributes"]["title"] == "OK Computer" }
    data.each do |release|
      assert Date.parse(release["attributes"]["release_date"]) < Date.current
      assert_equal "Parlophone", release["attributes"]["label"]
    end
  end

  test "should filter by date range and type combined" do
    get api_v1_releases_url,
        params: { from: "2013-01-01", to: "2013-12-31", type: "album" },
        headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    data = json_response["data"]

    data.each do |release|
      release_date = Date.parse(release["attributes"]["release_date"])
      assert release_date >= Date.new(2013, 1, 1)
      assert release_date <= Date.new(2013, 12, 31)
      assert_equal "album", release["attributes"]["release_type"]
    end
  end

  test "past filter should not include today releases" do
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
    titles = json_response["data"].map { |r| r["attributes"]["title"] }

    assert_not_includes titles, "Today Release"

    today_release.destroy
  end

  test "upcoming filter should include today releases" do
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
    titles = json_response["data"].map { |r| r["attributes"]["title"] }

    assert_includes titles, "Today Release"

    today_release.destroy
  end

  # Pagination tests
  test "should include pagination links in response" do
    get api_v1_releases_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("links")

    links = json_response["links"]
    assert links.key?("self")
    assert links.key?("first")
    assert links.key?("last")
  end

  test "should use default pagination of 10 per page" do
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

    assert json_response["data"].length <= 10

    Release.where("title LIKE ?", "Pagination Test%").destroy_all
  end

  test "should respect custom per_page parameter" do
    get api_v1_releases_url, params: { per_page: 2 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)

    assert json_response["data"].length <= 2
  end

  test "should navigate to specific page" do
    12.times do |i|
      Release.create!(
        title: "Page Test #{i}",
        release_date: Date.new(2020, 1, i + 1),
        release_type: "album",
        label: "Page Label",
        catalog_number: "PAGE-#{i}"
      )
    end

    get api_v1_releases_url, params: { page: 2, per_page: 5 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    links = json_response["links"]

    assert links.key?("prev")

    Release.where("title LIKE ?", "Page Test%").destroy_all
  end

  test "should cap per_page at maximum of 100" do
    get api_v1_releases_url, params: { per_page: 500 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    # per_page=100 should appear in the self link
    assert_match(/per_page=100/, json_response["links"]["self"])
  end

  test "should handle per_page of 0 or negative" do
    get api_v1_releases_url, params: { per_page: 0 }, headers: @auth_headers
    assert_response :success
    # Should not error out
  end

  test "should handle page 0 or negative" do
    get api_v1_releases_url, params: { page: -1 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    # Should default to page 1 in the self link
    assert_match(/page=1/, json_response["links"]["self"])
  end

  test "should calculate total_pages correctly via links" do
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

    get api_v1_releases_url, params: { per_page: 3, label: "Total Label" }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    links = json_response["links"]

    # 7 releases / 3 per page = 3 pages -> last page should be page 3
    assert_match(/page=3/, links["last"])
    assert links.key?("next")

    Release.where("title LIKE ?", "Total Pages Test%").destroy_all
  end

  test "should include next link when not on last page" do
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
    assert json_response["links"].key?("next")

    # Last page
    get api_v1_releases_url, params: { page: 3, per_page: 2, label: "Next Label" }, headers: @auth_headers
    json_response = JSON.parse(response.body)
    assert_not json_response["links"].key?("next")

    Release.where("title LIKE ?", "Next Page Test%").destroy_all
  end

  test "should include prev link when not on first page" do
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
    assert_not json_response["links"].key?("prev")

    # Page 2 should have prev
    get api_v1_releases_url, params: { page: 2, per_page: 1, label: "Prev Label" }, headers: @auth_headers
    json_response = JSON.parse(response.body)
    assert json_response["links"].key?("prev")

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

    assert_equal 2, json_response["data"].length
    assert json_response["links"].key?("next")

    Release.where("title LIKE ?", "Filter Pagination Test%").destroy_all
  end

  test "should return empty data for out of range page" do
    get api_v1_releases_url, params: { page: 9999, per_page: 10 }, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)

    assert_equal [], json_response["data"]
  end
end
