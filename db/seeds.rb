# ===========================================
# Seeds for Rails API Boilerplate
# ===========================================
# Run with: docker compose exec rails-api bin/rails db:seed

puts "🌱 Starting seed data creation..."

# ===========================================
# Users
# ===========================================
puts "\n👤 Creating users..."

admin = User.find_or_create_by(email_address: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.role = 'admin'
end

editor = User.find_or_create_by(email_address: 'editor@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Editor'
  user.last_name = 'User'
  user.role = 'editor'
end

regular_user = User.find_or_create_by(email_address: 'user@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Regular'
  user.last_name = 'User'
  user.role = 'user'
end

puts "   ✓ Created #{User.count} users"

# ===========================================
# Artists
# ===========================================
puts "\n🎤 Creating artists..."

artists_data = [
  { name: 'Radiohead', bio: 'English rock band formed in Abingdon, Oxfordshire, in 1985.', country: 'UK', formed_year: 1985 },
  { name: 'Daft Punk', bio: 'French electronic music duo formed in Paris in 1993.', country: 'France', formed_year: 1993 },
  { name: 'The Beatles', bio: 'English rock band formed in Liverpool in 1960.', country: 'UK', formed_year: 1960 },
  { name: 'Pink Floyd', bio: 'English rock band formed in London in 1965.', country: 'UK', formed_year: 1965 },
  { name: 'Nirvana', bio: 'American rock band formed in Aberdeen, Washington, in 1987.', country: 'USA', formed_year: 1987 },
  { name: 'Kraftwerk', bio: 'German electronic band formed in Düsseldorf in 1970.', country: 'Germany', formed_year: 1970 },
  { name: 'David Bowie', bio: 'English singer-songwriter and actor.', country: 'UK', formed_year: 1962 },
  { name: 'Queen', bio: 'British rock band formed in London in 1970.', country: 'UK', formed_year: 1970 },
  { name: 'Led Zeppelin', bio: 'English rock band formed in London in 1968.', country: 'UK', formed_year: 1968 },
  { name: 'Kendrick Lamar', bio: 'American rapper and songwriter from Compton, California.', country: 'USA', formed_year: 2003 }
]

artists = artists_data.map do |data|
  Artist.find_or_create_by(name: data[:name]) do |artist|
    artist.bio = data[:bio]
    artist.country = data[:country]
    artist.formed_year = data[:formed_year]
  end
end

puts "   ✓ Created #{Artist.count} artists"

# ===========================================
# Releases
# ===========================================
puts "\n💿 Creating releases..."

releases_data = [
  # Radiohead
  { title: 'OK Computer', release_date: '1997-05-21', release_type: 'album', label: 'Parlophone', catalog_number: '7243 8 55229 2 8' },
  { title: 'Kid A', release_date: '2000-10-02', release_type: 'album', label: 'Parlophone', catalog_number: '7243 5 27753 2 3' },
  { title: 'In Rainbows', release_date: '2007-10-10', release_type: 'album', label: 'XL Recordings', catalog_number: 'XLCD324' },

  # Daft Punk
  { title: 'Random Access Memories', release_date: '2013-05-17', release_type: 'album', label: 'Columbia', catalog_number: '88883716862' },
  { title: 'Discovery', release_date: '2001-03-12', release_type: 'album', label: 'Virgin', catalog_number: '7243 8 10252 2 4' },
  { title: 'Get Lucky', release_date: '2013-04-19', release_type: 'single', label: 'Columbia', catalog_number: '88883713442' },

  # The Beatles
  { title: 'Abbey Road', release_date: '1969-09-26', release_type: 'album', label: 'Apple Records', catalog_number: 'PCS 7088' },
  { title: 'Sgt. Peppers Lonely Hearts Club Band', release_date: '1967-05-26', release_type: 'album', label: 'Parlophone', catalog_number: 'PMC 7027' },

  # Pink Floyd
  { title: 'The Dark Side of the Moon', release_date: '1973-03-01', release_type: 'album', label: 'Harvest', catalog_number: 'SHVL 804' },
  { title: 'The Wall', release_date: '1979-11-30', release_type: 'album', label: 'Harvest', catalog_number: 'SHDW 411' },

  # Nirvana
  { title: 'Nevermind', release_date: '1991-09-24', release_type: 'album', label: 'DGC Records', catalog_number: 'DGCD-24425' },
  { title: 'In Utero', release_date: '1993-09-13', release_type: 'album', label: 'DGC Records', catalog_number: 'DGCD-24607' },
  { title: 'Smells Like Teen Spirit', release_date: '1991-09-10', release_type: 'single', label: 'DGC Records', catalog_number: 'DGCS7-19050' },

  # Kraftwerk
  { title: 'Trans-Europe Express', release_date: '1977-03-25', release_type: 'album', label: 'Kling Klang', catalog_number: '1C 064-82 306' },
  { title: 'The Man-Machine', release_date: '1978-05-19', release_type: 'album', label: 'Kling Klang', catalog_number: '1C 058-32 843' },

  # David Bowie
  { title: 'The Rise and Fall of Ziggy Stardust and the Spiders from Mars', release_date: '1972-06-16', release_type: 'album', label: 'RCA Records', catalog_number: 'SF 8287' },
  { title: 'Heroes', release_date: '1977-10-14', release_type: 'album', label: 'RCA Records', catalog_number: 'PL 12522' },
  { title: 'Blackstar', release_date: '2016-01-08', release_type: 'album', label: 'ISO/Columbia', catalog_number: '88875173862' },

  # Queen
  { title: 'A Night at the Opera', release_date: '1975-11-21', release_type: 'album', label: 'EMI', catalog_number: 'EMTC 103' },
  { title: 'Bohemian Rhapsody', release_date: '1975-10-31', release_type: 'single', label: 'EMI', catalog_number: 'EMI 2375' },

  # Led Zeppelin
  { title: 'Led Zeppelin IV', release_date: '1971-11-08', release_type: 'album', label: 'Atlantic', catalog_number: 'SD 7208' },
  { title: 'Physical Graffiti', release_date: '1975-02-24', release_type: 'album', label: 'Swan Song', catalog_number: 'SS 2-200' },

  # Kendrick Lamar
  { title: 'To Pimp a Butterfly', release_date: '2015-03-15', release_type: 'album', label: 'Top Dawg/Aftermath/Interscope', catalog_number: 'B0022735-02' },
  { title: 'DAMN.', release_date: '2017-04-14', release_type: 'album', label: 'Top Dawg/Aftermath/Interscope', catalog_number: 'B0026350-02' },
  { title: 'Mr. Morale & The Big Steppers', release_date: '2022-05-13', release_type: 'album', label: 'pgLang/Top Dawg/Aftermath/Interscope', catalog_number: 'B0035417-02' },

  # Upcoming releases (for testing upcoming filter)
  { title: 'Future Sounds Vol. 1', release_date: (Date.current + 30.days).to_s, release_type: 'album', label: 'Future Records', catalog_number: 'FUT-2024-001' },
  { title: 'Tomorrow EP', release_date: (Date.current + 60.days).to_s, release_type: 'single', label: 'Future Records', catalog_number: 'FUT-2024-002' }
]

releases = releases_data.map do |data|
  Release.find_or_create_by(title: data[:title], catalog_number: data[:catalog_number]) do |release|
    release.release_date = data[:release_date]
    release.release_type = data[:release_type]
    release.label = data[:label]
  end
end

puts "   ✓ Created #{Release.count} releases"

# ===========================================
# Artist-Release Associations
# ===========================================
puts "\n🔗 Creating artist-release associations..."

# Helper to find artist and release
def find_artist(name)
  Artist.find_by(name: name)
end

def find_release(title)
  Release.find_by(title: title)
end

associations = [
  # Radiohead
  { artist: 'Radiohead', release: 'OK Computer', role: 'primary' },
  { artist: 'Radiohead', release: 'Kid A', role: 'primary' },
  { artist: 'Radiohead', release: 'In Rainbows', role: 'primary' },

  # Daft Punk
  { artist: 'Daft Punk', release: 'Random Access Memories', role: 'primary' },
  { artist: 'Daft Punk', release: 'Discovery', role: 'primary' },
  { artist: 'Daft Punk', release: 'Get Lucky', role: 'primary' },

  # The Beatles
  { artist: 'The Beatles', release: 'Abbey Road', role: 'primary' },
  { artist: 'The Beatles', release: 'Sgt. Peppers Lonely Hearts Club Band', role: 'primary' },

  # Pink Floyd
  { artist: 'Pink Floyd', release: 'The Dark Side of the Moon', role: 'primary' },
  { artist: 'Pink Floyd', release: 'The Wall', role: 'primary' },

  # Nirvana
  { artist: 'Nirvana', release: 'Nevermind', role: 'primary' },
  { artist: 'Nirvana', release: 'In Utero', role: 'primary' },
  { artist: 'Nirvana', release: 'Smells Like Teen Spirit', role: 'primary' },

  # Kraftwerk
  { artist: 'Kraftwerk', release: 'Trans-Europe Express', role: 'primary' },
  { artist: 'Kraftwerk', release: 'The Man-Machine', role: 'primary' },

  # David Bowie
  { artist: 'David Bowie', release: 'The Rise and Fall of Ziggy Stardust and the Spiders from Mars', role: 'primary' },
  { artist: 'David Bowie', release: 'Heroes', role: 'primary' },
  { artist: 'David Bowie', release: 'Blackstar', role: 'primary' },

  # Queen
  { artist: 'Queen', release: 'A Night at the Opera', role: 'primary' },
  { artist: 'Queen', release: 'Bohemian Rhapsody', role: 'primary' },

  # Led Zeppelin
  { artist: 'Led Zeppelin', release: 'Led Zeppelin IV', role: 'primary' },
  { artist: 'Led Zeppelin', release: 'Physical Graffiti', role: 'primary' },

  # Kendrick Lamar
  { artist: 'Kendrick Lamar', release: 'To Pimp a Butterfly', role: 'primary' },
  { artist: 'Kendrick Lamar', release: 'DAMN.', role: 'primary' },
  { artist: 'Kendrick Lamar', release: 'Mr. Morale & The Big Steppers', role: 'primary' }
]

associations.each do |assoc|
  artist = find_artist(assoc[:artist])
  release = find_release(assoc[:release])

  if artist && release
    ArtistRelease.find_or_create_by(artist: artist, release: release) do |ar|
      ar.role = assoc[:role]
    end
  end
end

puts "   ✓ Created #{ArtistRelease.count} artist-release associations"

# ===========================================
# Albums
# ===========================================
puts "\n📀 Creating albums..."

albums_data = [
  # Radiohead
  { title: 'OK Computer', release_title: 'OK Computer', genre: 'Alternative Rock', total_tracks: 12, duration_seconds: 3325 },
  { title: 'Kid A', release_title: 'Kid A', genre: 'Electronic/Experimental', total_tracks: 10, duration_seconds: 2981 },
  { title: 'In Rainbows', release_title: 'In Rainbows', genre: 'Alternative Rock', total_tracks: 10, duration_seconds: 2558 },

  # Daft Punk
  { title: 'Random Access Memories', release_title: 'Random Access Memories', genre: 'Electronic/Disco', total_tracks: 13, duration_seconds: 4476 },
  { title: 'Discovery', release_title: 'Discovery', genre: 'Electronic/House', total_tracks: 14, duration_seconds: 3607 },

  # The Beatles
  { title: 'Abbey Road', release_title: 'Abbey Road', genre: 'Rock', total_tracks: 17, duration_seconds: 2820 },
  { title: 'Sgt. Peppers Lonely Hearts Club Band', release_title: 'Sgt. Peppers Lonely Hearts Club Band', genre: 'Rock/Psychedelic', total_tracks: 13, duration_seconds: 2394 },

  # Pink Floyd
  { title: 'The Dark Side of the Moon', release_title: 'The Dark Side of the Moon', genre: 'Progressive Rock', total_tracks: 10, duration_seconds: 2580 },
  { title: 'The Wall', release_title: 'The Wall', genre: 'Progressive Rock', total_tracks: 26, duration_seconds: 4862 },

  # Nirvana
  { title: 'Nevermind', release_title: 'Nevermind', genre: 'Grunge/Alternative', total_tracks: 12, duration_seconds: 2547 },
  { title: 'In Utero', release_title: 'In Utero', genre: 'Grunge/Alternative', total_tracks: 12, duration_seconds: 2491 },

  # Kraftwerk
  { title: 'Trans-Europe Express', release_title: 'Trans-Europe Express', genre: 'Electronic/Synth', total_tracks: 6, duration_seconds: 2542 },
  { title: 'The Man-Machine', release_title: 'The Man-Machine', genre: 'Electronic/Synth', total_tracks: 6, duration_seconds: 2205 },

  # David Bowie
  { title: 'The Rise and Fall of Ziggy Stardust', release_title: 'The Rise and Fall of Ziggy Stardust and the Spiders from Mars', genre: 'Glam Rock', total_tracks: 11, duration_seconds: 2312 },
  { title: 'Heroes', release_title: 'Heroes', genre: 'Art Rock/Electronic', total_tracks: 10, duration_seconds: 2507 },
  { title: 'Blackstar', release_title: 'Blackstar', genre: 'Art Rock/Jazz', total_tracks: 7, duration_seconds: 2504 },

  # Queen
  { title: 'A Night at the Opera', release_title: 'A Night at the Opera', genre: 'Rock/Opera', total_tracks: 12, duration_seconds: 2586 },

  # Led Zeppelin
  { title: 'Led Zeppelin IV', release_title: 'Led Zeppelin IV', genre: 'Hard Rock', total_tracks: 8, duration_seconds: 2554 },
  { title: 'Physical Graffiti', release_title: 'Physical Graffiti', genre: 'Hard Rock/Blues', total_tracks: 15, duration_seconds: 5280 },

  # Kendrick Lamar
  { title: 'To Pimp a Butterfly', release_title: 'To Pimp a Butterfly', genre: 'Hip-Hop/Jazz', total_tracks: 16, duration_seconds: 4780 },
  { title: 'DAMN.', release_title: 'DAMN.', genre: 'Hip-Hop', total_tracks: 14, duration_seconds: 3296 },
  { title: 'Mr. Morale & The Big Steppers', release_title: 'Mr. Morale & The Big Steppers', genre: 'Hip-Hop', total_tracks: 18, duration_seconds: 4548 }
]

albums_data.each do |data|
  release = find_release(data[:release_title])

  if release
    Album.find_or_create_by(title: data[:title], release: release) do |album|
      album.release_date = release.release_date
      album.genre = data[:genre]
      album.total_tracks = data[:total_tracks]
      album.duration_seconds = data[:duration_seconds]
    end
  end
end

puts "   ✓ Created #{Album.count} albums"

# ===========================================
# Summary
# ===========================================
puts "\n" + "=" * 50
puts "✅ Seed data created successfully!"
puts "=" * 50
puts "\n📊 Summary:"
puts "   • Users: #{User.count}"
puts "   • Artists: #{Artist.count}"
puts "   • Releases: #{Release.count}"
puts "   • Albums: #{Album.count}"
puts "   • Artist-Release associations: #{ArtistRelease.count}"
puts "\n👤 Test accounts:"
puts "   📧 Admin: admin@example.com (password: password123)"
puts "   📧 Editor: editor@example.com (password: password123)"
puts "   📧 User: user@example.com (password: password123)"
puts "\n🔑 To get a JWT token, POST to /api/v1/auth/login with:"
puts '   { "email": "admin@example.com", "password": "password123" }'
