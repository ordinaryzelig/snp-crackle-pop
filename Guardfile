guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('app/app.rb')
  watch('config/apps.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')
  watch(%r{^lib/.*\.rb})
  watch(%r{spec/support/.+\.rb})
end
