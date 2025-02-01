require 'sinatra'
require 'sqlite3'
require 'securerandom'

# Create the database if it doesn't exist
DB = SQLite3::Database.new 'urls.db'
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS urls (
    id INTEGER PRIMARY KEY,
    long_url TEXT NOT NULL,
    short_code TEXT UNIQUE NOT NULL
  );
SQL

# Homepage
get '/' do
  erb :index
end

# Generate a short URL
post '/shorten' do
  long_url = params[:long_url]
  short_code = SecureRandom.hex(3) # Generates a short 6-character identifier

  # Store in DB
  DB.execute("INSERT INTO urls (long_url, short_code) VALUES (?, ?)", [long_url, short_code])

  "Shortened URL: <a href='/#{short_code}'>http://localhost:4567/#{short_code}</a>"
end

# Redirect to the original URL
get '/:short_code' do
  short_code = params[:short_code]
  row = DB.execute("SELECT long_url FROM urls WHERE short_code = ?", [short_code]).first

  if row
    redirect row[0]
  else
    "Short URL not found!"
  end
end

# Run Sinatra Server
run! if __FILE__ == $0
