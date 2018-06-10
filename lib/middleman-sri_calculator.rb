require "middleman-core"

Middleman::Extensions.register :middleman-sri_calculator do
  require "middleman-sri_calculator/extension"
  SRI_Calculator
end
