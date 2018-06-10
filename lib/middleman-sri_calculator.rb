require "middleman-core"

Middleman::Extensions.register :middleman-sricalculator do
  require "middleman-sri_calculator/extension"
  SRICalculator
end
