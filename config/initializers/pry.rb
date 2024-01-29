# Show red environment name in pry prompt for non development environments
unless Rails.env.development?
  module Pry::CustomColorHelpers
    def self.red(text)
      "\001\033[0;31m\002#{text}\001\033[0m\002"
    end
  end

  env = Pry::CustomColorHelpers.red(Rails.env.upcase)

  Pry.config.prompt.prompt_procs.map! do |prok|
    proc { |*a| "#{env} #{prok.call(*a)}" }
  end
end

Pry::Method.prepend(
  Module.new do
    def pry_doc_info
      require 'pry-doc'
      super
    end
  end
)
if Rails.env.production?
  Pry.config.history_save = false
  Pry.config.history_load = false
end
