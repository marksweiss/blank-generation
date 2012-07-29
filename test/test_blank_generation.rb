require "testutil"
$LOAD_PATH << psub("../")
require "rubygems"
require "test/unit"
require "json"
require "uuidtools"
require "blank_generation"
require "util"

class BlankGenerator_Test < Test::Unit::TestCase  
  def test__initialize
    g = BlankGenerator.new
    assert(g.class == BlankGenerator, "test__initialize failed. object class == #{g.class}")
  end
  
  def test__generate_by_normal_int
    num_records = 2
    mean = 20.0
    std_dev = 0.0
    nil_ratio = nil
    nil_value = nil
    field_gen = NormalFieldGenerator.new("col", FieldGenerator::INT, mean, std_dev, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":20},{\"col\":20}]", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    dist = g.generate num_records    
    assert(dist == "20\n20\n", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_normal_float_json
    num_records = 2
    mean = 20.0
    std_dev = 0.0
    nil_ratio = nil
    nil_value = nil
    field_gen = NormalFieldGenerator.new("col", FieldGenerator::FLOAT, mean, std_dev, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate(num_records)
    assert(dist == "[{\"col\":20.0},{\"col\":20.0}]", "test__generate_by_normal failed. dist returned == #{dist.inspect}")  
  end
  
  def test__generate_by_normal_date_json
    num_records = 2
    mean = "1997-07-16T19:20:30.45+01:00"
    # Use util function with this package to convert two dates to a range value
    # NOTE: Time resolutions more granular than 1 sec are currently lost
    std_dev = date_diff_to_i("1997-07-16T19:20:30.45+01:00", "1997-07-16T19:20:30.45+01:00")
    nil_ratio = nil
    nil_value = nil
    field_gen = NormalFieldGenerator.new("col", FieldGenerator::DATE, mean, std_dev, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate(num_records)
    assert(dist == "[{\"col\":\"1997-07-16T14:20:30-04:00\"},{\"col\":\"1997-07-16T14:20:30-04:00\"}]", "test__generate_by_normal failed. dist returned == #{dist.inspect}")  
  end
  
  def test__generate_by_normal_int__nil_handling
    num_records = 2
    mean = 20.0
    std_dev = 0.0
    # Set all fields nil, range is 0.0:1.0
    nil_ratio = 1.0
    # Set fields that are nil to this
    nil_value = -1
    field_gen = NormalFieldGenerator.new("col", FieldGenerator::INT, mean, std_dev, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":-1},{\"col\":-1}]", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV, generate nil values
    csv_formatter = CsvFormatter.new
    g.formatter = csv_formatter
    dist = g.generate num_records
    assert(dist == "-1\n-1\n", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
    # Now set exclude_nil_fields on JSON Formatter, reassign to Generator and see that empty records come back
    #  for JSON but for CSV rows come back with delimiters but no values. i.e. JSON has records of length 0 but
    #  CSV still has records of length 1 but nil values
    formatter = JsonFormatter.new
    formatter.exclude_nil_fields = true
    g.formatter = formatter
    dist = g.generate num_records
    assert(dist == "[{},{}]", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
    g.formatter = csv_formatter
    dist = g.generate num_records
    # Still has the custom nil value because CSV includes nil columns
    assert(dist == "-1\n-1\n", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_random_int
    num_records = 2
    min = 1
    max = 1
    nil_ratio = nil
    nil_value = nil
    field_gen = RandomFieldGenerator.new("col", FieldGenerator::INT, min, max, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":1},{\"col\":1}]", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    dist = g.generate num_records    
    assert(dist == "1\n1\n", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    # Test min and max of random range
    field_gen.min = 4
    field_gen.max = 4
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    assert(dist == "[{\"col\":4},{\"col\":4}]", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    
    field_gen.min = 0
    field_gen.max = 4
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    
    assert(dist_json[0]["col"] >= 0 && dist_json[0]["col"] <= 4 && dist_json[1]["col"] >= 0 && dist_json[1]["col"] <= 4, "test__generate_by_random failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_random_float
    num_records = 2
    min = 1.0
    max = 1.0
    nil_ratio = nil
    nil_value = nil
    field_gen = RandomFieldGenerator.new("col", FieldGenerator::FLOAT, min, max, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":1.0},{\"col\":1.0}]", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    dist = g.generate num_records    
    assert(dist == "1.0\n1.0\n", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    # Test min and max of random range
    field_gen.min = 4.0
    field_gen.max = 4.0
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    assert(dist == "[{\"col\":4.0},{\"col\":4.0}]", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    
    field_gen.min = 0.0
    field_gen.max = 4.0
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    
    assert(dist_json[0]["col"] >= 0.0 && dist_json[0]["col"] <= 4.0 && dist_json[1]["col"] >= 0.0 && dist_json[1]["col"] <= 4.0, "test__generate_by_random failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_random_date
    num_records = 2
    min = "1997-07-16T19:20:30.45+01:00"
    max = "1997-07-16T19:20:30.45+01:00"
    nil_ratio = nil
    nil_value = nil
    field_gen = RandomFieldGenerator.new("col", FieldGenerator::DATE, min, max, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":\"1997-07-16T14:20:30-04:00\"},{\"col\":\"1997-07-16T14:20:30-04:00\"}]", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    dist = g.generate num_records    
    assert(dist == "1997-07-16T14:20:30-04:00\n1997-07-16T14:20:30-04:00\n", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    
    field_gen.min = "1997-07-16T19:20:30.45+01:00"
    field_gen.max = "1997-07-16T20:20:30.45+01:00"
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist  
    assert(date_s_to_i(dist_json[0]["col"]) >= date_s_to_i(field_gen.min) && 
           date_s_to_i(dist_json[0]["col"]) <= date_s_to_i(field_gen.max) && 
           date_s_to_i(dist_json[1]["col"]) >= date_s_to_i(field_gen.min) && 
           date_s_to_i(dist_json[1]["col"]) <= date_s_to_i(field_gen.max), "test__generate_by_random failed. dist returned == #{dist.inspect}")
  end
    
  def test__generate_by_string
    num_records = 2
    # Defaults
    # min_string_length = 1
    # max_string_length = 20
    # min_num_tokens = 1
    # max_num_tokens = 1
    # alphabet = ('a'..'z').to_a + ('A'..'Z').to_a    
    # nil_ratio = nil
    # nil_value = nil
    field_gen = StringFieldGenerator.new("col")
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist 
    assert((dist_json[0]["col"].length > 0 && dist_json[0]["col"].length <= 20 && dist_json[0]["col"].class == String), "test__generate_by_string failed. dist returned == #{dist.inspect}")
  
    field_gen.min_string_length = 5
    field_gen.max_string_length = 5
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist 
    assert((dist_json[0]["col"].length == 5 && dist_json[0]["col"].class == String), "test__generate_by_string failed. dist returned == #{dist.inspect}")

    field_gen.min_num_tokens = 1
    field_gen.max_num_tokens = 5
    # Must >=  2*max_num_tokens - 1 or exception raised
    field_gen.max_string_length = 15
    g = BlankGenerator.new    
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    tkns = dist_json[0]["col"].split(' ')
    assert((tkns.length >= field_gen.min_num_tokens && tkns.length <= field_gen.max_num_tokens && dist_json[0]["col"].class == String), "test__generate_by_string failed. dist returned == #{dist.inspect}")
    
    field_gen.delimiter = ';'
    field_gen.min_num_tokens = 1
    field_gen.max_num_tokens = 5
    g = BlankGenerator.new    
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    tkns = dist_json[0]["col"].split(';')
    assert((tkns.length >= field_gen.min_num_tokens && tkns.length <= field_gen.max_num_tokens && dist_json[0]["col"].class == String), "test__generate_by_string failed. dist returned == #{dist.inspect}")
  end
    
  def test__generate_by_dictionary
    num_records = 2
    path = "./test_dictionary.txt"
    nil_ratio = nil
    nil_value = nil
    field_gen = DictionaryFieldGenerator.new("col", path, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert( ((dist_json[0]["col"] == "hello world" || dist_json[0]["col"] == "goodbye chicken") && (dist_json[1]["col"] == "hello world" || dist_json[1]["col"] == "goodbye chicken")), "test__generate_by_dictionary failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    num_records = 1
    dist = g.generate num_records    
    assert(dist == "hello world\n" || dist == "goodbye chicken\n", "test__generate_by_dictionary failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_value_set
    num_records = 2
    values = [30, 30]
    nil_ratio = nil
    nil_value = nil
    field_gen = ValueSetFieldGenerator.new("col", values, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert(dist_json[0]["col"] == 30 && dist_json[1]["col"] == 30, "test__generate_by_value_set failed. dist returned == #{dist.inspect}")
    # Change to different values and mixed types
    field_gen.values = [30, "hello world"]
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert(((dist_json[0]["col"] == 30 || dist_json[0]["col"] == "hello world") && 
            (dist_json[1]["col"] == 30 || dist_json[1]["col"] == "hello world")), "test__generate_by_value_set failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    num_records = 1
    dist = g.generate num_records    
    assert(dist == "hello world\n" || dist == "30\n", "test__generate_by_value_set failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_histogram
    # Define the Histogram generator
    num_records = 2
    hist_field_gen = HistogramFieldGenerator.new("col", HistogramFieldGenerator::HIST_TYPE_RANDOM)
    # Define two RandomFieldGenerators and add them as bucket generators to the Histogram. Each will generate values with their share (bucket width)
    #  of the total distribution, with total width == 1.0. So we get a random distribution with each element falling into a bucket by bucket share,
    #  and then the value is generated by the generator for that bucket by calling its #generate() method
    rand_field_gen_1 = RandomFieldGenerator.new("", FieldGenerator::INT, 1, 1)
    rand_field_gen_2 = RandomFieldGenerator.new("", FieldGenerator::INT, 2, 2)
    share = 0.3
    hist_field_gen.add_bucket_generator(share, rand_field_gen_1)
    hist_field_gen.add_bucket_generator(share, rand_field_gen_2)
    share = 0.4
    rand_field_gen_3 = RandomFieldGenerator.new("", FieldGenerator::INT, 3, 3)
    hist_field_gen.add_bucket_generator(share, rand_field_gen_3)
    
    g = BlankGenerator.new
    g.add_field_generator hist_field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert(((dist_json[0]["col"] == 1 || dist_json[0]["col"] == 2 || dist_json[0]["col"] == 3) && 
            (dist_json[0]["col"] == 1 || dist_json[0]["col"] == 2 || dist_json[0]["col"] == 3)), "test__generate_by_histogram failed. dist returned == #{dist.inspect}")
    
    # Now test with DictionaryGenerator
    hist_field_gen = HistogramFieldGenerator.new("col", HistogramFieldGenerator::HIST_TYPE_DICTIONARY)
    path = "./test_dictionary.txt"
    dict_field_gen = DictionaryFieldGenerator.new("col", path)
    share = 1.0
    hist_field_gen.add_bucket_generator(share, dict_field_gen)
    g = BlankGenerator.new
    g.add_field_generator hist_field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert( ((dist_json[0]["col"] == "hello world" || dist_json[0]["col"] == "goodbye chicken") && 
             (dist_json[1]["col"] == "hello world" || dist_json[1]["col"] == "goodbye chicken")), "test__generate_by_histogram failed. dist returned == #{dist.inspect}")
  
    # Now test with ValueSetGenerator
    hist_field_gen = HistogramFieldGenerator.new("col", HistogramFieldGenerator::HIST_TYPE_VALUE_SET)
    value_set_field_gen = ValueSetFieldGenerator.new("col", ["hello world", "goodbye chicken"])
    share = 1.0
    hist_field_gen.add_bucket_generator(share, value_set_field_gen)
    g = BlankGenerator.new
    g.add_field_generator hist_field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert( ((dist_json[0]["col"] == "hello world" || dist_json[0]["col"] == "goodbye chicken") && 
             (dist_json[1]["col"] == "hello world" || dist_json[1]["col"] == "goodbye chicken")), "test__generate_by_histogram failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_id_int
    num_records = 3    
    # Test using default values for id_int_base and id_int_step, 0 and 1 respectively. So default for 3 records will be [0, 1, 2]
    field_gen = IdFieldGenerator.new("col")
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert((dist_json[0]["col"] == 0 && dist_json[1]["col"] == 1 && dist_json[2]["col"] == 2), "test__generate_by_id_int failed. dist returned == #{dist.inspect}")
    # Test using id_int_base
    id_base = 10
    field_gen = IdFieldGenerator.new("col", id_base)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert((dist_json[0]["col"] == 10 && dist_json[1]["col"] == 11 && dist_json[2]["col"] == 12), "test__generate_by_id_int failed. dist returned == #{dist.inspect}")
    # Test using id_int_base and id_int_step
    id_step = 2
    field_gen = IdFieldGenerator.new("col", id_base, id_step)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert((dist_json[0]["col"] == 10 && dist_json[1]["col"] == 12 && dist_json[2]["col"] == 14), "test__generate_by_id_int failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_id_uuid
    num_records = 2
    field_gen = IdUuidFieldGenerator.new("col")
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    dist_json.each do |id|      
      # Based on the source code in the documentation, parse will raise an exception if it can't parse its argument
      assert_nothing_raised do
        UUIDTools::UUID.parse(id["col"].to_s)
      end
    end
  end
  
  def test__generate_by_normal_int_nil_values
    num_records = 2
    mean = 20
    std_dev = 0
    nil_ratio = 1.0
    nil_value = -1
    field_gen = NormalFieldGenerator.new("col", FieldGenerator::INT, mean, std_dev, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    # Both values are deisgnated nil_value because nil_ratio is 1.0
    assert((dist_json[0]["col"] == -1 && dist_json[1]["col"] == -1), "test__generate_by_normal_int_nil_values failed. dist returned == #{dist.inspect}")
  
    nil_ratio = 0.5
    nil_value = -1
    field_gen = NormalFieldGenerator.new("col", FieldGenerator::INT, mean, std_dev, nil_ratio, nil_value)
    g = BlankGenerator.new
    g.add_field_generator field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist
    # One value is deisgnated nil_value because nil_ratio is 1.0
    assert(((dist_json[0]["col"] == 20 && dist_json[1]["col"] == -1) || (dist_json[0]["col"] == -1 && dist_json[1]["col"] == 20)), "test__generate_by_normal_int_nil_values failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_normal_int_options_hash
    num_records = 2
    g = BlankGenerator.new
    g.add_field_generator NormalFieldGenerator.new :name => "col", :data_type => FieldGenerator::INT, :mean => 20.0, :std_dev => 0.0
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":20},{\"col\":20}]", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    dist = g.generate num_records    
    assert(dist == "20\n20\n", "test__generate_by_normal failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_random_int_options_hash
    num_records = 2
    g = BlankGenerator.new
    g.add_field_generator RandomFieldGenerator.new :name => "col", :data_type => FieldGenerator::INT, :min => 1, :max => 1
    dist = g.generate num_records
    # Default out format is JSON
    assert(dist == "[{\"col\":1},{\"col\":1}]", "test__generate_by_random failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    dist = g.generate num_records    
    assert(dist == "1\n1\n", "test__generate_by_random failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_dictionary_options_hash
    num_records = 2
    g = BlankGenerator.new
    g.add_field_generator DictionaryFieldGenerator.new :name => "col", :path => "./test_dictionary.txt"
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert( ((dist_json[0]["col"] == "hello world" || dist_json[0]["col"] == "goodbye chicken") && (dist_json[1]["col"] == "hello world" || dist_json[1]["col"] == "goodbye chicken")), "test__generate_by_dictionary failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    num_records = 1
    dist = g.generate num_records    
    assert(dist == "hello world\n" || dist == "goodbye chicken\n", "test__generate_by_dictionary failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_value_set_options_hash
    num_records = 2
    g = BlankGenerator.new
    g.add_field_generator ValueSetFieldGenerator.new :name => "col", :values => [30, 30]
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert(dist_json[0]["col"] == 30 && dist_json[1]["col"] == 30, "test__generate_by_value_set failed. dist returned == #{dist.inspect}")
    # Change to different values and mixed types
    g = BlankGenerator.new
    g.add_field_generator ValueSetFieldGenerator.new :name => "col", :values => [30, "hello world"]
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert(((dist_json[0]["col"] == 30 || dist_json[0]["col"] == "hello world") && 
            (dist_json[1]["col"] == 30 || dist_json[1]["col"] == "hello world")), "test__generate_by_value_set failed. dist returned == #{dist.inspect}")
    # Change out_format to CSV
    g.formatter = CsvFormatter.new
    num_records = 1
    dist = g.generate num_records    
    assert(dist == "hello world\n" || dist == "30\n", "test__generate_by_value_set failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_histogram_normal_options_hash
    # Define the Histogram generator
    num_records = 2
    hist_field_gen = HistogramFieldGenerator.new :name => "col", :hist_type => HistogramFieldGenerator::HIST_TYPE_NORMAL
    # Define two RandomFieldGenerators and add them as bucket generators to the Histogram. Each will generate values with their share (bucket width)
    #  of the total distribution, with total width == 1.0. So we get a random distribution with each element falling into a bucket by bucket share,
    #  and then the value is generated by the generator for that bucket by calling its #generate() method
    norm_field_gen_1 = NormalFieldGenerator.new :name => "", :data_type => FieldGenerator::INT, :mean => 1, :std_dev => 0
    rand_field_gen_2 = NormalFieldGenerator.new :name => "", :data_type => FieldGenerator::INT, :mean => 2, :std_dev => 0
    share = 0.3
    hist_field_gen.add_bucket_generator(share, norm_field_gen_1)
    hist_field_gen.add_bucket_generator(share, rand_field_gen_2)
    rand_field_gen_3 = NormalFieldGenerator.new :name => "", :data_type => FieldGenerator::INT, :mean => 3, :std_dev => 0
    share = 0.4
    hist_field_gen.add_bucket_generator(share, rand_field_gen_3)
    
    g = BlankGenerator.new
    g.add_field_generator hist_field_gen
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert(((dist_json[0]["col"] == 1.0 || dist_json[0]["col"] == 2 || dist_json[0]["col"] == 3) && 
            (dist_json[1]["col"] == 1.0 || dist_json[1]["col"] == 2 || dist_json[1]["col"] == 3)), "test__generate_by_histogram failed. dist returned == #{dist.inspect}")
  end  
  
  def test__generate_full_record
    num_records = 1
    id_gen = IdFieldGenerator.new("CustId")
    first_name_gen = ValueSetFieldGenerator.new("FirstName", ["Tom"])
    last_name_gen = ValueSetFieldGenerator.new("LastName", ["Smith"])
    state_gen = ValueSetFieldGenerator.new("State", ["NY"])
    created_at_gen = RandomFieldGenerator.new("Created", FieldGenerator::DATE, "1997-07-16T19:20:30.45+01:00", "1997-07-16T19:20:30.45+01:00")
    last_modified_gen = RandomFieldGenerator.new("LastModified", FieldGenerator::DATE, "1997-07-16T19:20:30.45+01:00", "1997-07-16T19:20:30.45+01:00")
    avg_purchase_gen = NormalFieldGenerator.new("AvgPurchase", FieldGenerator::FLOAT, 20.0, 0.0)
    g = BlankGenerator.new
    g.add_field_generators(id_gen, first_name_gen, last_name_gen, state_gen, created_at_gen, last_modified_gen, avg_purchase_gen)
    dist = g.generate num_records    
    dist_json = JSON.parse dist
    assert((dist_json[0]["CustId"] == 0 && 
            dist_json[0]["FirstName"] == "Tom" && 
            dist_json[0]["LastName"] == "Smith" && 
            dist_json[0]["State"] == "NY" && 
            dist_json[0]["Created"] ==  "1997-07-16T14:20:30-04:00" && 
            dist_json[0]["LastModified"] == "1997-07-16T14:20:30-04:00" && 
            dist_json[0]["AvgPurchase"] == 20.0), "test__generate_full_record failed. dist returned == #{dist.inspect}")    
  end
  
  def test__generate_by_id_int_options_hash
    num_records = 3 
    # Test using default values for id_int_base and id_int_step, 0 and 1 respectively. So default for 3 records will be [0, 1, 2]
    g = BlankGenerator.new
    g.add_field_generator IdFieldGenerator.new :name => "col"
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert((dist_json[0]["col"] == 0 && dist_json[1]["col"] == 1 && dist_json[2]["col"] == 2), "test__generate_by_id_int failed. dist returned == #{dist.inspect}")
    # Test using id_int_base
    g = BlankGenerator.new
    g.add_field_generator IdFieldGenerator.new :name => "col", :id_int_base => 10
    dist = g.generate num_records
    dist_json = JSON.parse dist
    assert((dist_json[0]["col"] == 10 && dist_json[1]["col"] == 11 && dist_json[2]["col"] == 12), "test__generate_by_id_int failed. dist returned == #{dist.inspect}")
    # Test using id_int_base and id_int_step
    g = BlankGenerator.new
    g.add_field_generator IdFieldGenerator.new :name => "col", :id_int_base => 10, :id_int_step => 2
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    assert((dist_json[0]["col"] == 10 && dist_json[1]["col"] == 12 && dist_json[2]["col"] == 14), "test__generate_by_id_int failed. dist returned == #{dist.inspect}")
  end
  
  def test__generate_by_id_uuid_options_hash
    num_records = 2
    g = BlankGenerator.new
    g.add_field_generator IdUuidFieldGenerator.new :name => "col"
    dist = g.generate num_records
    dist_json = JSON.parse dist    
    dist_json.each do |id|      
      # Based on the source code in the documentation, parse will raise an exception if it can't parse its argument
      assert_nothing_raised do
        UUIDTools::UUID.parse(id["col"].to_s)
      end
    end
  end
    
end