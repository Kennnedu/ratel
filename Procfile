web: bundle exec rackup config.ru -p $PORT
sidekiq: bundle exec sidekiq -r ./app/workers/*
console: APP_ENV=production bundle exec irb -r ./system/boot.rb
test: bundle exec rspec -f d
generate_docs: bundle exec rspec --format RspecApiDocumentation::ApiFormatter
