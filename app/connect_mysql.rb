require 'mysql2'

client = Mysql2::Client.new(
  host: 'localhost',
  username: 'satyam',
  password: 'satyam1234',
  database: 'tasklist'
)

# Test the connection
results = client.query('SELECT VERSION()')
results.each do |row|
  puts row
end
