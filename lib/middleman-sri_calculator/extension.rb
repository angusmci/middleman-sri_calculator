# Require core library
require 'middleman-core'

# Extension namespace
class SRICalculator < ::Middleman::Extension
  option :my_option, 'default', 'An example option'

  def initialize(app, options_hash={}, &block)
    # Call super to build options from the options_hash
    super

    # Require libraries only when activated
    # require 'necessary/library'

    # set up your extension
    # puts options.my_option
    puts('Initialized')
  end

  def after_configuration
    puts('After configuration')
  end

  # A Sitemap Manipulator
  # def manipulate_resource_list(resources)
  # end

  # helpers do
  #   def a_helper
  #   end
  # end
end
