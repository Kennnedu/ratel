web: bundle exec rackup config.ru -p $PORT
console: APP_ENV=production bundle exec irb -r ./application.rb
test: bundle exec rspec -f d
generate_docs: bundle exec rspec --format RspecApiDocumentation::ApiFormatter
dev: rerun -- bundle exec rackup --port 4567 config.ru
