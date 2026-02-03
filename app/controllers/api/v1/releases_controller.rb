class Api::V1::ReleasesController < ApplicationController
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 100

  def index
    releases = Release.includes(:albums, artist_releases: :artist)
    releases = apply_filters(releases)
    releases = releases.order(release_date: :desc)

    # Get total count before pagination
    total_count = releases.count

    # Apply pagination
    page = [params[:page].to_i, 1].max
    per_page = [[params[:per_page].to_i, 1].max, MAX_PER_PAGE].min
    per_page = DEFAULT_PER_PAGE if params[:per_page].blank?

    paginated_releases = releases.offset((page - 1) * per_page).limit(per_page)
    total_pages = (total_count.to_f / per_page).ceil

    render json: {
      releases: paginated_releases.map { |release| release_json(release) },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_count: total_count,
        has_next_page: page < total_pages,
        has_prev_page: page > 1
      }
    }
  end

  def show
    release = Release.includes(:albums, artist_releases: :artist).find(params[:id])
    render json: { release: release_json(release) }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Release not found" }, status: :not_found
  end

  private

  def apply_filters(releases)
    # Filter by past/upcoming
    case params[:filter]
    when "past"
      releases = releases.where("release_date < ?", Date.current)
    when "upcoming"
      releases = releases.where("release_date >= ?", Date.current)
    end

    # Filter by date range
    releases = releases.where("release_date >= ?", params[:from]) if params[:from].present?
    releases = releases.where("release_date <= ?", params[:to]) if params[:to].present?

    # Filter by release type
    releases = releases.where(release_type: params[:type]) if params[:type].present?

    # Filter by label
    releases = releases.where(label: params[:label]) if params[:label].present?

    releases
  end

  def release_json(release)
    {
      id: release.id,
      title: release.title,
      release_date: release.release_date,
      release_type: release.release_type,
      label: release.label,
      catalog_number: release.catalog_number,
      created_at: release.created_at,
      updated_at: release.updated_at,
      albums: release.albums.map { |album| album_json(album) },
      artists: release.artist_releases.map { |ar| artist_with_role_json(ar) }
    }
  end

  def album_json(album)
    {
      id: album.id,
      title: album.title,
      release_date: album.release_date,
      genre: album.genre,
      total_tracks: album.total_tracks,
      duration_seconds: album.duration_seconds
    }
  end

  def artist_with_role_json(artist_release)
    {
      id: artist_release.artist.id,
      name: artist_release.artist.name,
      country: artist_release.artist.country,
      role: artist_release.role
    }
  end
end
