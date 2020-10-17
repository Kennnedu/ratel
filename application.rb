require 'bundler'

Bundler.require(:default, ENV['APP_ENV'] || 'development')

Dotenv.load(File.expand_path("../.env.#{ENV['APP_ENV']}.local",  __FILE__))
Dotenv.load(File.expand_path("../.env.local",  __FILE__))

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

unless ENV['APP_ENV'].eql? 'test'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end 

require 'shrine'

if ENV['APP_ENV'].eql? 'production'
  require 'shrine/storage/google_drive_storage'

  Shrine.storages = {
    cache: Shrine::Storage::GoogleDriveStorage.new(drive_public_folder_id: ENV['GOOGLE_PUBLIC_FOLDER_ID']),
    store: Shrine::Storage::GoogleDriveStorage.new(drive_public_folder_id: ENV['GOOGLE_PUBLIC_FOLDER_ID']),
  }
else
  require 'shrine/storage/file_system'

  Shrine.storages = { 
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary 
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),       # permanent 
  }
end

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data # for retaining the cached file across form redisplays 
Shrine.plugin :restore_cached_data # re-extract metadata when attaching a cached file 
Shrine.plugin :rack_file # for non-Rails apps

# last for uploading
Dir[File.dirname(__FILE__) + '/app/models/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/app/services/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each { |file| require file }

require_relative 'system/container.rb'
