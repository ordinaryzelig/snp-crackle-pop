class Assembly

  include NCBI::Document

  verify_xml { |node| node.to_s.match /^\<Assembly/ }

  field :db_snp_build,  type: Integer, xml: lambda { |node| node['dbSnpBuild'] }
  field :genome_build,  type: Float,   xml: lambda { |node| node['genomeBuild'].sub('_', '.') }
  field :group_label,   type: String,  xml: lambda { |node| node['groupLabel'] }
  field :current,       type: Boolean, xml: lambda { |node| node['current'] == 'true' }
  field :reference,     type: Boolean, xml: lambda { |node| node['reference'] == 'true' }
  field :base_position, type: Integer, xml: lambda { |node| node.css('MapLoc').detect { |maploc_node| b_pos = maploc_node['physMapInt']; break b_pos if b_pos } }

end
