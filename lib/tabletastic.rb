module Tabletastic
  def table_for(array)
    concat(tag(:table, nil, true))
    concat("</table>")
  end

  class TableBuilder
  end
end