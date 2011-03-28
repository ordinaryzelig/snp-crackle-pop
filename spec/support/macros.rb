module Macros

  def drop_tables
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end
end
