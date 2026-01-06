# db/seeds.rb

puts "Seeding database..."

# Create the Super Admin if they don't exist
admin = User.find_or_initialize_by(email: 'admin@example.com')

admin.assign_attributes(
  name: 'Super Admin',
  role: :admin,
  password: 'SASadmin25*',
  password_confirmation: 'SASadmin25*'
)

admin.confirmed_at = Time.current

admin.save!

puts "✅ Admin user ready: admin@example.com"
puts "Password: SASadmin25*"
puts "🧹 Database is clean. Please add real products via the Admin Panel."
