ActiveSupport::Inflector.inflections do |inflect|
  inflect.human 'het_uncertainty', 'heterozygosity uncertainty'
  inflect.human /^_+/, '' # Truncate leading underscores.
  inflect.human 'symbols_other', 'other symbols'
end
