require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Components', 'app/components'
  add_group 'Helpers', 'app/helpers'
  add_group 'Jobs', 'app/jobs'
end
