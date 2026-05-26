#!/usr/bin/env ruby

# Room Booking Module Validation Script
# This script validates that all room booking functionality is working correctly

puts "="*60
puts "ROOM BOOKING MODULE VALIDATION"
puts "="*60

# Test database connectivity and model loading
begin
  puts "\n1. Testing Model Loading..."
  
  models = [Room, RoomBooking, RoomPricing, RoomAvailability]
  models.each do |model|
    model.count # This will fail if model doesn't exist or has issues
    puts "  ✓ #{model.name} model loaded successfully"
  end
  
rescue => e
  puts "  ✗ Error loading models: #{e.message}"
  exit 1
end

# Test model associations
begin
  puts "\n2. Testing Model Associations..."
  
  # Test Room associations
  room = Room.new
  associations = [:site, :room_bookings, :room_pricing, :room_availability]
  associations.each do |assoc|
    if room.respond_to?(assoc)
      puts "  ✓ Room.#{assoc} association exists"
    else
      puts "  ✗ Room.#{assoc} association missing"
    end
  end
  
  # Test RoomBooking associations
  booking = RoomBooking.new
  associations = [:room, :user, :site]
  associations.each do |assoc|
    if booking.respond_to?(assoc)
      puts "  ✓ RoomBooking.#{assoc} association exists"
    else
      puts "  ✗ RoomBooking.#{assoc} association missing"
    end
  end
  
rescue => e
  puts "  ✗ Error testing associations: #{e.message}"
end

# Test model validations
begin
  puts "\n3. Testing Model Validations..."
  
  # Test Room validations
  room = Room.new
  room.valid?
  expected_errors = [:name, :room_number, :room_type, :base_price_per_night, :max_adults, :max_children, :site]
  expected_errors.each do |field|
    if room.errors[field].any?
      puts "  ✓ Room.#{field} validation working"
    else
      puts "  ✗ Room.#{field} validation missing"
    end
  end
  
  # Test RoomBooking validations
  booking = RoomBooking.new
  booking.valid?
  expected_errors = [:check_in_date, :check_out_date, :number_of_adults, :number_of_children, :guest_name, :guest_phone]
  expected_errors.each do |field|
    if booking.errors[field].any?
      puts "  ✓ RoomBooking.#{field} validation working"
    else
      puts "  ✗ RoomBooking.#{field} validation missing"
    end
  end
  
rescue => e
  puts "  ✗ Error testing validations: #{e.message}"
end

# Test enum values
begin
  puts "\n4. Testing Enum Values..."
  
  # Test Room enums
  if Room.respond_to?(:room_types) && Room.room_types.keys.include?('standard')
    puts "  ✓ Room.room_type enum working"
  else
    puts "  ✗ Room.room_type enum missing or incorrect"
  end
  
  if Room.respond_to?(:statuses) && Room.statuses.keys.include?('available')
    puts "  ✓ Room.status enum working"
  else
    puts "  ✗ Room.status enum missing or incorrect"
  end
  
  # Test RoomBooking enums
  if RoomBooking.respond_to?(:statuses) && RoomBooking.statuses.keys.include?('pending')
    puts "  ✓ RoomBooking.status enum working"
  else
    puts "  ✗ RoomBooking.status enum missing or incorrect"
  end
  
  if RoomBooking.respond_to?(:payment_statuses) && RoomBooking.payment_statuses.keys.include?('unpaid')
    puts "  ✓ RoomBooking.payment_status enum working"
  else
    puts "  ✗ RoomBooking.payment_status enum missing or incorrect"
  end
  
rescue => e
  puts "  ✗ Error testing enums: #{e.message}"
end

# Test model methods
begin
  puts "\n5. Testing Model Methods..."
  
  # Create test site if needed
  site = Site.first
  unless site
    puts "  ! Creating test site for validation..."
    company = Company.create!(name: "Test Company", email: "test@test.com", phone: "123456789")
    site = Site.create!(name: "Test Site", region: "Test", company: company)
  end
  
  # Create test room
  room = Room.create!(
    site: site,
    name: "Test Room",
    room_number: "TEST001",
    room_type: 'standard',
    base_price_per_night: 100.0,
    tax_percentage: 10.0,
    max_adults: 2,
    max_children: 1,
    status: 'available',
    active: true
  )
  
  # Test room methods
  methods = [:display_name, :capacity, :price_for_date, :total_price_for_stay, :available_on_dates?]
  methods.each do |method|
    if room.respond_to?(method)
      case method
      when :display_name
        result = room.display_name
        puts "  ✓ Room.#{method} returns: #{result}"
      when :capacity
        result = room.capacity
        puts "  ✓ Room.#{method} returns: #{result}"
      when :price_for_date
        result = room.price_for_date(Date.current)
        puts "  ✓ Room.#{method} returns: #{result}"
      when :total_price_for_stay
        result = room.total_price_for_stay(Date.current, Date.current + 2.days)
        puts "  ✓ Room.#{method} returns: #{result}"
      when :available_on_dates?
        result = room.available_on_dates?(Date.current, Date.current + 1.day)
        puts "  ✓ Room.#{method} returns: #{result}"
      end
    else
      puts "  ✗ Room.#{method} method missing"
    end
  end
  
  # Clean up test room
  room.destroy
  
rescue => e
  puts "  ✗ Error testing methods: #{e.message}"
end

# Test scopes
begin
  puts "\n6. Testing Model Scopes..."
  
  # Test Room scopes
  scopes = [:active, :by_site, :available_for_dates]
  scopes.each do |scope|
    if Room.respond_to?(scope)
      puts "  ✓ Room.#{scope} scope exists"
    else
      puts "  ✗ Room.#{scope} scope missing"
    end
  end
  
  # Test RoomBooking scopes
  scopes = [:active, :current, :by_site, :by_date_range]
  scopes.each do |scope|
    if RoomBooking.respond_to?(scope)
      puts "  ✓ RoomBooking.#{scope} scope exists"
    else
      puts "  ✗ RoomBooking.#{scope} scope missing"
    end
  end
  
rescue => e
  puts "  ✗ Error testing scopes: #{e.message}"
end

# Test controllers
begin
  puts "\n7. Testing Controller Files..."
  
  controllers = [
    'app/controllers/rooms_controller.rb',
    'app/controllers/room_bookings_controller.rb',
    'app/controllers/room_pricing_controller.rb',
    'app/controllers/room_availability_controller.rb'
  ]
  
  controllers.each do |controller_file|
    if File.exist?(controller_file)
      puts "  ✓ #{controller_file} exists"
    else
      puts "  ✗ #{controller_file} missing"
    end
  end
  
rescue => e
  puts "  ✗ Error checking controllers: #{e.message}"
end

# Test routes
begin
  puts "\n8. Testing Routes..."
  
  # This is a simple test - in a real app you'd use Rails.application.routes.recognize_path
  routes_file = File.read('config/routes.rb')
  
  route_patterns = [
    'resources :rooms',
    'resources :room_bookings',
    'resources :room_pricing',
    'resources :room_availability'
  ]
  
  route_patterns.each do |pattern|
    if routes_file.include?(pattern)
      puts "  ✓ #{pattern} route configured"
    else
      puts "  ✗ #{pattern} route missing"
    end
  end
  
rescue => e
  puts "  ✗ Error checking routes: #{e.message}"
end

# Test migrations
begin
  puts "\n9. Testing Migrations..."
  
  tables = ['rooms', 'room_bookings', 'room_pricing', 'room_availability']
  tables.each do |table|
    if ActiveRecord::Base.connection.table_exists?(table)
      puts "  ✓ #{table} table exists"
    else
      puts "  ✗ #{table} table missing - run migrations"
    end
  end
  
rescue => e
  puts "  ✗ Error checking migrations: #{e.message}"
end

# Test sample data loading
begin
  puts "\n10. Testing Sample Data Loading..."
  
  if File.exist?('db/seeds_room_booking.rb')
    puts "  ✓ Sample data seed file exists"
    puts "  → Run 'rails runner db/seeds_room_booking.rb' to load sample data"
  else
    puts "  ✗ Sample data seed file missing"
  end
  
rescue => e
  puts "  ✗ Error checking sample data: #{e.message}"
end

puts "\n" + "="*60
puts "VALIDATION COMPLETE"
puts "="*60

# Provide next steps
puts "\nNext Steps:"
puts "1. Run migrations if any tables are missing:"
puts "   rails db:migrate"
puts ""
puts "2. Load sample data:"
puts "   rails runner db/seeds_room_booking.rb"
puts ""
puts "3. Test the API endpoints using curl or Postman"
puts "   See docs/room_booking_api.md for endpoint documentation"
puts ""
puts "4. Check the README_ROOM_BOOKING.md for usage examples"
puts ""

puts "Room Booking Module validation completed!"
puts "="*60
