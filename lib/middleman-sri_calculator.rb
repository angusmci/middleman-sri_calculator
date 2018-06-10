require "middleman-core"

Middleman::Extensions.register :middleman-sri_calculator do
  require "my-extension/extension"
  MyExtension
end
