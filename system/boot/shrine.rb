# frozen_string_literal: true

Container.boot(:shrine) do
  init do
    require 'shrine'

    if ENV['APP_ENV'].eql? 'production'
      require 'shrine/storage/google_drive_storage'

      Shrine.storages = {
        cache: Shrine::Storage::GoogleDriveStorage.new(drive_public_folder_id: ENV['GOOGLE_PUBLIC_FOLDER_ID']),
        store: Shrine::Storage::GoogleDriveStorage.new(drive_public_folder_id: ENV['GOOGLE_PUBLIC_FOLDER_ID'])
      }
    else
      require 'shrine/storage/file_system'

      Shrine.storages = {
        cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'), # temporary
        store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads') # permanent
      }
    end

    Shrine.plugin :activerecord
    Shrine.plugin :cached_attachment_data # for retaining the cached file across form redisplays
    Shrine.plugin :restore_cached_data # re-extract metadata when attaching a cached file
    Shrine.plugin :rack_file # for non-Rails apps
    Shrine.plugin :determine_mime_type
  end
end
