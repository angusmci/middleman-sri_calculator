# Require core library
require 'middleman-core'
require 'yaml'

# Extension namespace
class SRICalculator < ::Middleman::Extension
  option :paths, [], 'List of pathnames for which we need to calculate a hash'
  option :datafile, 'sri.yaml', "Name of data file used to store SRI hashes"
  option :template, "shasum -b -a 384 %s | xxd -r -p | base64", "Command template"
  option :prefix, "sha384", "Identifier of hashing algorithm"

  def initialize(app, options_hash={}, &block)
    super
  end

  # after_build
  #
  # After the build is complete, refresh the SRI data file

  def after_build(builder)
  	datafilepath = File.join(builder.app.config[:data_dir], "/", options[:datafile])
  	sri_data = {}
	if File.exists?(datafilepath)
  	  sri_data = YAML.load_file(datafilepath)
  	end
	options.paths.each { |path|
		relative_path = File.join(builder.app.config[:build_dir], "/", path)
		if File.exists?(relative_path)
		    hash = compute_hash(relative_path)
		    normalized_name = path.gsub(/[^A-Za-z0-9]/,'_')
		    sri_data[normalized_name] = hash
		end
	}
    if not File.exists?(builder.app.config[:data_dir])
       Dir.mkdir(builder.app.config[:data_dir])
    end
	File.write(datafilepath, sri_data.to_yaml)
  end

  # compute_hash
  #
  # Compute a hash for the specified path by using a shell command.

  def compute_hash(path)
  	command = options.template % path
  	hash = `#{command}`.strip!
  	return options.prefix + "-" + hash
  end

end

