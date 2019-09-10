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
	content	TEXT
)'
end

get '/' do
  @results = @db.execute 'select * from Posts order by id  desc'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

  validate_content(content)

  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  redirect to '/'
  erb "You typed #{content}"
end

get '/details/:post_id' do
  post_id = params[:post_id]
  erb "Displaying information for post with id #{post_id}"
end

def validate_content(content)
  if content.length <= 0
    @error = 'Type post text'
    return erb :new
  end
end