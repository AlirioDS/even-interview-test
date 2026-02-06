class Api::V1::ReleasesController < ApplicationController
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 100

  def index
    releases = Release.includes(:albums, artist_releases: :artist)
    releases = apply_filters(releases)
    releases = releases.order(release_date: :desc)

    total_count = releases.count

    page = [params[:page].to_i, 1].max
    per_page = [[params[:per_page].to_i, 1].max, MAX_PER_PAGE].min
    per_page = DEFAULT_PER_PAGE if params[:per_page].blank?

    paginated_releases = releases.offset((page - 1) * per_page).limit(per_page)
    total_pages = (total_count.to_f / per_page).ceil

    included = collect_included(paginated_releases)

    render json: {
      links: pagination_links(page, per_page, total_pages),
      data: paginated_releases.map { |release| release_resource(release) },
      included: included
    }
  end

  def show
    release = Release.includes(:albums, artist_releases: :artist).find(params[:id])
    included = collect_included([ release ])

    render json: {
      links: { self: api_v1_release_url(release) },
      data: release_resource(release),
      included: included
    }
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [{ status: "404", title: "Not Found", detail: "Release not found" }] }, status: :not_found
  end

  private

  def apply_filters(releases)
    case params[:filter]
    when "past"
      releases = releases.where("release_date < ?", Date.current)
    when "upcoming"
      releases = releases.where("release_date >= ?", Date.current)
    end

    releases = releases.where("release_date >= ?", params[:from]) if params[:from].present?
    releases = releases.where("release_date <= ?", params[:to]) if params[:to].present?
    releases = releases.where(release_type: params[:type]) if params[:type].present?
    releases = releases.where(label: params[:label]) if params[:label].present?

    releases
  end

  # JSON:API resource object for a release
  def release_resource(release)
    {
      type: "releases",
      id: release.id.to_s,
      attributes: {
        title: release.title,
        release_date: release.release_date,
        release_type: release.release_type,
        label: release.label,
        catalog_number: release.catalog_number,
        created_at: release.created_at,
        updated_at: release.updated_at
      },
      relationships: {
        albums: {
          links: {
            self: "#{api_v1_release_url(release)}/relationships/albums",
            related: "#{api_v1_release_url(release)}/albums"
          },
          data: release.albums.map { |a| { type: "albums", id: a.id.to_s } }
        },
        artists: {
          links: {
            self: "#{api_v1_release_url(release)}/relationships/artists",
            related: "#{api_v1_release_url(release)}/artists"
          },
          data: release.artist_releases.map { |ar| { type: "artists", id: ar.artist.id.to_s } }
        }
      },
      links: { self: api_v1_release_url(release) }
    }
  end

  # JSON:API resource object for an album (included)
  def album_resource(album)
    {
      type: "albums",
      id: album.id.to_s,
      attributes: {
        title: album.title,
        release_date: album.release_date,
        genre: album.genre,
        total_tracks: album.total_tracks,
        duration_seconds: album.duration_seconds
      },
      relationships: {
        release: {
          data: { type: "releases", id: album.release_id.to_s }
        }
      },
      links: { self: api_v1_release_url(album.release_id) }
    }
  end

  # JSON:API resource object for an artist (included)
  def artist_resource(artist, role: nil)
    resource = {
      type: "artists",
      id: artist.id.to_s,
      attributes: {
        name: artist.name,
        country: artist.country
      }
    }
    resource[:meta] = { role: role } if role
    resource
  end

  # Collect all unique included resources from a set of releases
  def collect_included(releases)
    included = []
    seen = Set.new

    releases.each do |release|
      release.albums.each do |album|
        key = "albums:#{album.id}"
        next if seen.include?(key)
        seen.add(key)
        included << album_resource(album)
      end

      release.artist_releases.each do |ar|
        key = "artists:#{ar.artist.id}"
        next if seen.include?(key)
        seen.add(key)
        included << artist_resource(ar.artist, role: ar.role)
      end
    end

    included
  end

  # Build JSON:API pagination links
  def pagination_links(page, per_page, total_pages)
    links = { self: build_page_url(page, per_page) }
    links[:first] = build_page_url(1, per_page)
    links[:last]  = build_page_url([total_pages, 1].max, per_page)
    links[:prev]  = build_page_url(page - 1, per_page) if page > 1
    links[:next]  = build_page_url(page + 1, per_page) if page < total_pages
    links
  end

  def build_page_url(page, per_page)
    query = request.query_parameters.merge("page" => page, "per_page" => per_page)
    "#{request.base_url}#{request.path}?#{query.to_query}"
  end
end
