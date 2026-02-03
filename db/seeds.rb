# Create default users for development and testing

# Admin user
admin = User.find_or_create_by(email_address: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.role = 'admin'
end

# Editor user
editor = User.find_or_create_by(email_address: 'editor@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Editor'
  user.last_name = 'User'
  user.role = 'editor'
end

# Regular user
regular_user = User.find_or_create_by(email_address: 'user@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Regular'
  user.last_name = 'User'
  user.role = 'user'
end

puts "✅ Seed data created successfully!"
puts "📧 Admin: admin@example.com (password: password123)"
puts "📧 Editor: editor@example.com (password: password123)"
puts "📧 User: user@example.com (password: password123)"
