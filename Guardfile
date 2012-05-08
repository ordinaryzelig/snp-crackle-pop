guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/apps.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')
  watch(%r{spec/support/.+\.rb})
end
