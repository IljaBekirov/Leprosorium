require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new('./db/leprosorium.db')
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE if not exists Posts (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	created_date	DATE,
	content	TEXT,
  name TEXT
)'

  @db.execute 'CREATE TABLE if not exists Comments (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	post_id	INTEGER,
	content	TEXT,
  created_date	DATE
)'
end

get '/' do
  @results = @db.execute 'select * from Posts order by id  desc'
  @comments_count = @db.execute 'select * from Comments'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  name = params[:name]
  content = params[:content]

  # validate_content(content, :new)
  if name.length <= 0
    @error = 'Enter your name'
    return erb :new
  end

  if content.length <= 0
    @error = 'Type post text'
    return erb :new
  end

  @db.execute 'insert into Posts (name, content, created_date) values (?, ?, datetime())', [name, content]

  redirect to '/'
  erb "You typed #{content}"
end

get '/details/:post_id' do
  post_id = params[:post_id]

  results = @db.execute 'select * from Posts where id = ?', [post_id]
  @row = results[0]
  @comments = @db.execute 'select * from Comments where post_id = ?', [post_id]

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]
  content = params[:content]

  # validate_content(content, :details)
  if content.length <= 0
    @error = 'Type post text'
    return erb 'Error'
  end

  @db.execute 'insert into Comments (post_id, content, created_date) values (?, ?, datetime())', [post_id, content]

  redirect to "/details/#{post_id}"
  # erb :details
end

# def validate_content(content, endpount)
#   if content.length <= 0
#     @error = 'Type post text'
#     return erb endpount.to_sym
#   end
# end