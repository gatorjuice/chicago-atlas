class ResourceParser < Parser

  FIRST_ROW       = 1

  COLUMNS_HEADER  = {
    category:     'A',
    subcategory:  'B',
    indicator:    'C',
    year:         'D',
    geography:    'E',
    geo_group:    'F',
    demography:   'G',
    demo_group:   'F'
  }

  COLUMNS = [
    'number',
    'cum_number',
    'ave_annual_number',
    'crude_rate',
    'lower_95ci_crude_rate',
    'uppper_95ci_crude_rate',
    'age_adj_rate',
    'lower_95ci_adj_rate',
    'upper_95ci_adj_rate',
    'percent',
    'lower_95ci_percent',
    'upper_95ci_percent',
    'weight_number',
    'weight_percent',
    'lower_95ci_weight_percent',
    'upper_95ci_weight_percent',
    'map_key',
    'flag'
  ]

  #Main engine for analyse of excel file
  def run
    parse do
      self.current_sheet.processing!

      ss = Roo::Spreadsheet.open(self.new_file_path)
      ActiveRecord::Base.transaction do
        FIRST_ROW.upto ss.last_row do |row|
          category     = Category.where(name: ss.cell(row, COLUMNS_HEADER[:category]).to_s, parent_id:1).first_or_create
          subcategory  = Category.where(name: ss.cell(row, COLUMNS_HEADER[:subcategory]), parent_id:2).first_or_create
          indicator    = Indicator.where(name: ss.cell(row, COLUMNS_HEADER[:indicator])).first_or_create
          geography    = GeoGroup.where(name: ss.cell(row, COLUMNS_HEADER[:geo_group]), geography: ss.cell(row, COLUMNS_HEADER[:geography])).first_or_create
          demography   = DemoGroup.where(name: ss.cell(row, COLUMNS_HEADER[:demo_group]), demography: ss.cell(row, COLUMNS_HEADER[:demography])).first_or_create

          new_resource                    = Resource.new
          new_resource.uploader_id        = self.uploader_id
          new_resource.category_id        = category.id
          new_resource.sub_category_id    = subcategory.id
          new_resource.indicator_id       = indicator.id
          new_resource.geo_group_id       = geography.id
          new_resource.demo_group_id      = demography.id
          new_resource.year  = ss.cell(row, COLUMNS_HEADER[:year])

          rsc_array   = -1
          rsc_array.upto COLUMNS.length-1 do |rsc_id|
            rsc_start = 7
            rsc_start.upto ss.last_column-1 do |col_id|
              if COLUMNS[rsc_id].casecmp(ss.cell(1, col_id)) == 0
                new_resource[COLUMNS[rsc_id]] = ss.cell(row, col_id)
                break
              end
            end
          end
          new_resource.save
        end
      end
      self.current_sheet.completed!
    end
  end

  #initialize resource class
  def self.run(uploader_id)
    ResourceParser.new(uploader_id).run
  end
end