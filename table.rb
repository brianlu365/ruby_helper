require 'csv'

# @class: Table
# @brief: creates a table for read and write csv file.
# @attr - columns: an array of symbol holds header name.
# @attr - data: an array of hash holds data.
class Table
	attr_accessor :columns, :data
	def initialize(c = [], d = [])
		@columns = c
		@data = d
	end


	# @method: load_csv
	# @brief: load a csv file into Table object.
	# @param - file_name: choose which file.
	# @option - :header: does this csv file have headers. if yes (:header => true) else (:header => false).
	# @option - :transforms: manipulate data when load. use lambda function.
	# 	example: 
	# 		:transforms => lambda {|r| r[:shipout_type] = "#{r[:shipout_type].to_s.gsub(/(1|2)/, '1' => 'air freight', '2' => 'ocean freight')}"
	def load_csv(file_name,option = {})
		if (file_name)
			input_string = File.read(file_name)
			@data = CSV.parse(input_string, :col_sep => ",", :quote_char => '"', :encoding => Encoding::UTF_8)
			# p !@data.empty?
			if (!@data.empty?)
				if (option[:header])	#convert array into hash with column name as key
					@columns = @data.shift.map {|i| i.to_sym}
					@data = @data.map {|row| row.map {|cell| cell.to_s } }
					@data = @data.map {|row| Hash[*columns.zip(row).flatten] }
				end
			end
		end

		if (option[:transforms])	
			@data.each {|r| option[:transforms].call(r)}
		end
	end

	# @operator: <<
	# @brief: append a row of data into @data.
	# @param row: hash.
	def << (row = {})
		self.add_row(row)
	end

	# @method: operator
	# @brief: same as <<
	def add_row(row = {})
		@data << row
	end

	# @method: add_col
	# @brief: add a new column and data under the column.
	# @param - col: an array of symbol.
	# @param - dat: an array of hash.
	def add_col(col = [], dat = [])
		@columns = @columns + col
		(0...dat.length).each {|i| @data[i].merge!(dat[i])}
	end

	# @method: to_csv
	# @brief: write table to a csv file.
	# @para - file_name: where you want to write the file to.
	def to_csv(file_name)
		csv_data = []
		csv_data << @columns
		@data.each do |r|
			csv_data << @columns.map {|col|  r[col] ? '|' + r[col] + '|' : '||' }
		end

		csv_data.map! {|r| r.join(',')}
		File.open(file_name, 'w') {|file| file.puts csv_data}
	end

end