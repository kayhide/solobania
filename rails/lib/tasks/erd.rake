if Rails.env.development?
  require "thor/shell/color"
  @shell = Thor::Shell::Color.new

  Rake::Task["erd:load_models"].clear

  namespace :erd do
    task :load_models do
      @shell.say "Loading Application environment..."
      Rake::Task[:environment].invoke

      @shell.say "Loading code in search of ActiveRecord models..."
      Zeitwerk::Loader.eager_load_all
    end

    task :configure do
      ENV["filename"] = "db/erd"
      ENV["exclude"] = %w(
        ActiveRecord::InternalMetadata
        ActiveRecord::SchemaMigration
        ActiveStorage::Blob
        ActiveStorage::Attachment
        ActiveStorage::VariantRecord
      ).join(',')
      ENV["inheritance"] = "1"
    end
    task options: :configure
  end

end
