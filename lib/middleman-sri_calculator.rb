require "middleman-core"

require "middleman-sri_calculator/extension"
::Middleman::Extensions.register(:sri_calculator, SRICalculator)