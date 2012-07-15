#!/usr/bin/ruby

require "rubygems"
require "rsruby"
require "date"
require "util"

# require 'ruby-debug' ; Debugger.start
# SAMPLE DEBUGGER CALLS
# Debugger.tracing = true
# breakpoint if true == false
# Debugger.tracing = false

NIL_FLD_MARKER = '7ab09e90-668e-11e1-b86c-0800200c9a66'

class BlankGenerationException < Exception; end
class BlankFormatterException < Exception; end

# Author:: Mark S. Weiss  (http://github.com/marksweiss)
# Copyright:: Copyright (c) 2012 Mark S. Weiss
# License:: MIT 
#
class BlankGenerator
  attr_accessor :exclude_nil_fields
  attr_reader :field_generators, :formatter

  def initialize(exclude_nil_fields=false, formatter=nil)
    @exclude_nil_fields = exclude_nil_fields
    @formatter = formatter || JsonFormatter.new    
    @field_generators = []
  end
  
  def formatter=(formatter)
    if !formatter.class.ancestors.include? BlankFormatter
      raise BlankGenerationException, "Invalid formatter of type #{formatter.class}. Formatter must be a subclass of BlankFormatter."
    end
    @formatter = formatter
  end
  
  def add_field_generators(*field_generators)
    field_generators.each do |field_generator|
      add_field_generator field_generator
    end
  end
  
  def add_field_generator(field_generator)    
    if !field_generator.class.ancestors.include? FieldGenerator
      raise BlankGenerationException, "Invalide field generator of type #{field_generator.class}. Field generator must be a subclass of FieldGenerator."
    end    
    @field_generators << field_generator
  end

  def generate(num_records)    
    if num_records.nil? || num_records.class != Fixnum
      raise BlankGenerationException, "Invalid value for num_records #{num_records} passed as arg to #BlankGenerator::generate()."    
    end    
    if @field_generators.nil? or @field_generators.length == 0
      raise BlankGenerationException, "No field generators defined when #BlankGenerator::generate() called."
    end
    
    begin    
      field_data = {}
      # This is a little ugly, copy the Field Generators into a hash to pass to each Formatter
      #  so the Formatter can check each generator to see if it has a custom nil_value
      formatter_config = {}
      @field_generators.each do |field_gen|
        formatter_config[field_gen.name] = field_gen
        # Appends array which is all the data for this field, in order
        # So each array in array out is the pivot of all data for that column for all rows
        field_data[field_gen.name] = field_gen.generate num_records
        # If Date field, convert Date fields from Unix time int back to Date
        if field_gen.respond_to?(:date_flag) && field_gen.date_flag
          field_data[field_gen.name].map! do |v|
            v = date_i_to_s(v.to_i)
          end
        end
      end

      # TODO Change this to not have to loop twice, make formatter format each line and append to output inline
      #  in above loop
      out = @formatter.format(field_data, num_records, formatter_config)      
      out
    rescue Exception => e
      puts e
    end
  end
end

class FieldGenerator  
  INT = 2
  FLOAT = 3
  STRING = 4
  DATE = 5
  ANY = 6
  Types = {INT => Fixnum, FLOAT => Float, STRING => String, DATE => Fixnum, ANY => Array}
  
  attr_accessor :name, :data_type
  
  def initialize(name, data_type)
    @name = name
    @data_type = convert_data_type data_type
    # Overwritten by derived types that use it, in base class so #BlankGenerator::generate() doesn't cough
    @date_flag = false    
  end
  
  def convert_data_type(data_type)
    Types[data_type]
  end
  
  def set_nil_values(dist, nil_ratio, num_records)
    # If nil_ratio was passed, nil out values at random distribution of indices within all indices in the distribution
    # So random sampling over normal distribution maintains a normal distribituion asymptotically    
    if not nil_ratio.nil?
      num_nil_indices = (nil_ratio * num_records).floor      
      # Random distribution of index position in the range (0..num_records-1), don't allow repeat values
      #  because we are guaranteeing the nil_ratio so we don't want to "use" a nil index more than once
      allow_repeat_values = false
      r = RSRuby.instance
      nil_indices = r.sample(0.upto(num_records - 1).collect, num_nil_indices, allow_repeat_values)
      nil_indices = [nil_indices] if nil_indices.class == Fixnum
      # Set each index to a marker value. The formatter will then set that to nil or its custom nil_value      
      nil_indices.each do |i|
        dist[i] = NIL_FLD_MARKER
      end
    end
  
    dist
  end  

  protected
  
  def validate
    return false if (@name.nil? || @name.class != String)
    return false if (@data_type.nil? || (@data_type.class == Fixnum && Types[@data_type].nil?))
    true
  end
end

class NormalFieldGenerator < FieldGenerator
  attr_accessor :std_dev, :nil_ratio, :nil_value, :date_flag
  
  def initialize(*args) # name, data_type, mean, std_dev, nil_ratio=nil, nil_value=nil
    # Handle args as argument list or options hash
    name, data_type, mean, std_dev, nil_ratio, nil_value = load_init_args args
    
    if data_type != INT && data_type != FLOAT && data_type != DATE
      raise BlankGenerationException, "NormalGenerator: illegal value for data_type, != INT, FLOAT, DATE: data_type #{data_type}"
    end
    
    super(name, data_type)
    @mean = mean
    @std_dev = std_dev
    @nil_ratio = nil_ratio
    @nil_value = nil_value
    # Map data type enum to actual type of data stored in field
    @date_flag = data_type == DATE
    @r = RSRuby.instance
    
    if not validate
      raise BlankGenerationException, "NormalFieldGenerator: Validation failed for arguments: name #{name}, data_type #{data_type}, mean #{mean}, std_dev #{std_dev}, nil_ratio #{nil_ratio}, nil_value #{nil_value}"
    end    
    
    # Manage mean and std_dev. Ints are valid but must be converted to floats for R call. Dates converted to ints to floats.
    # Convert dates into ints, seconds since epoch. So can then use R dist function to generate int distribution
    #  and convert back to Dates when data returned
    @date_flag ? @mean = date_s_to_i(@mean).to_f : @mean = @mean.to_f
    @std_dev = @std_dev.to_f
  end
  
  def mean
    @date_flag ? date_i_to_s(@mean) : @mean
  end
  
  def mean=(mean)
    @date_flag ? @mean = date_s_to_i(mean).to_f : @mean = mean.to_f
  end

  def std_dev=(std_dev)
    @std_dev = std_dev.to_f
  end
  
  def generate(num_records)    
    dist = @r.rnorm(num_records, @mean, @std_dev)  # rsruby R call 
    if @data_type == Fixnum
      dist.map! {|x| x.floor}
    end
    dist = [dist] if dist.class != Array # Workaround RSRuby anomaly, returns scalar for single value, Array for multiple values
    dist = self.set_nil_values(dist, @nil_ratio, num_records)    
    dist
  end
  
  private
  
  def load_init_args(args)
    # name, data_type, mean, std_dev, nil_ratio, nil_value    
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name], opts[:data_type], opts[:mean], opts[:std_dev], opts[:nil_ratio], opts[:nil_value]
    elsif args.length == 4
      return args[0], args[1], args[2], args[3], nil, nil
    elsif args.length == 5
      return args[0], args[1], args[2], args[3], args[4], nil     
    elsif args.length == 6
      return args[0], args[1], args[2], args[3], args[4], args[5]
    else
      raise BlankGenerationException, "NormalFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end
  
  def validate    
    return false if not super
    return false if ! @nil_ratio.nil? && @nil_ratio.class != Float
    mean_cls = @mean.class
    std_dev_cls = @std_dev.class
    return false if (@data_type == Fixnum && @date_flag) && (!validate_date_str(@mean) || !@std_dev.class == Fixnum) 
    return false if mean_cls != Fixnum && mean_cls != Float && !(mean_cls == String && validate_date_str(@mean))
    return false if std_dev_cls != Fixnum && std_dev_cls != Float
    return false if !@date_flag && mean_cls != std_dev_cls
    true  
  end
end

class RandomFieldGenerator < FieldGenerator
  attr_accessor :nil_ratio, :nil_value, :date_flag

  def initialize(*args) # name, data_type, min, max, nil_ratio=nil, nil_value=nil
    name, data_type, min, max, nil_ratio, nil_value = load_init_args args
    
    if data_type != INT && data_type != FLOAT && data_type != DATE
      raise BlankGenerationException, "RandomFieldGenerator: illegal value for data_type, != INT, FLOAT, DATE: data_type #{data_type}"
    end
        
    super(name, data_type)
    @min = min
    @max = max
    @nil_ratio = nil_ratio
    @nil_value = nil_value    
    @date_flag = data_type == DATE
        
    if not validate
      raise BlankGenerationException, "RandomFieldGenerator: Validation failed for arguments: name #{name}, data_type #{data_type}, min #{min}, max #{max}, nil_ratio #{nil_ratio}, nil_value #{nil_value}"
    end

    if @date_flag
      @min = date_s_to_i(@min)
      @max = date_s_to_i(@max)
    end
  end
  
  def min
    @date_flag ? date_i_to_s(@min) : @min
  end
  
  def min=(min)
     @date_flag ? @min = date_s_to_i(min) : @min = min
  end
  
  def max
    @date_flag ? date_i_to_s(@max) : @max
  end
  
  def max=(max)
    @date_flag ? @max = date_s_to_i(max) : @max = max
  end  
  
  def generate(num_records)    
    dist = []
    min = @min
    max = @max
    if @data_type == Fixnum
      min = min.to_i
      max = max.to_i
    end
    
    num_records.times do |i|
      val = ((rand(max - min + 1)) + min).floor if @data_type == Fixnum 
      val = (rand * (max - min)) + min if @data_type == Float
      dist << val
    end
    
    dist = self.set_nil_values(dist, @nil_ratio, num_records)    
    dist
  end
  
  private
  
  def load_init_args(args)
    # name, data_type, min, max, nil_ratio, nil_value    
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name], opts[:data_type], opts[:min], opts[:max], opts[:nil_ratio], opts[:nil_value]
    elsif args.length == 4
      return args[0], args[1], args[2], args[3], nil, nil
    elsif args.length == 5
      return args[0], args[1], args[2], args[3], args[4], nil     
    elsif args.length == 6
      return args[0], args[1], args[2], args[3], args[4], args[5]
    else
      raise BlankGenerationException, "RandomFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end  
  
  def validate
    return false if not super
    return false if !@nil_ratio.nil? && @nil_ratio.class != Float    
    return false if (@data_type == Fixnum && @date_flag) && !(validate_date_str(@min) && validate_date_str(@max)) 
    min_cls = @min.class
    max_cls = @max.class
    return false if min_cls != Fixnum && min_cls != Float && !(min_cls == String && validate_date_str(@min))
    return false if max_cls != Fixnum && max_cls != Float && !(max_cls == String && validate_date_str(@max))        
    return false if !@date_flag && min_cls != max_cls
    true  
  end  
end

class DictionaryFieldGenerator < FieldGenerator
  attr_accessor :path
  
  def initialize(*args) # name, path, nil_ratio=nil, nil_value=nil
    name, path, nil_ratio, nil_value = load_init_args args
    super(name, STRING)
    @path = path
    @nil_ratio = nil_ratio
    @nil_value = nil_value
    
    if not validate
      raise BlankGenerationException, "DictionaryFieldGenerator: Validation failed for arguments: name #{name}, path #{path}, nil_ratio #{nil_ratio}, nil_value #{nil_value}"
    end    

    # Test/cache for strings from the dictionary for this histogram entry
    @dictionary = []
    File.foreach(@path) do |line|       
      @dictionary.push line.strip
    end        
  end
  
  def generate(num_records)
    dist = []
    len = @dictionary.length
    num_records.times do |i|
      dist << @dictionary[rand(len)]
    end    
    dist = self.set_nil_values(dist, @nil_ratio, num_records)
    dist    
  end
  
  private
  
  def load_init_args(args)
    # name, path, nil_ratio, nil_value    
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name], opts[:path], opts[:nil_ratio], opts[:nil_value]
    elsif args.length == 2
      return args[0], args[1], nil, nil
    elsif args.length == 3
      return args[0], args[1], args[2], nil     
    elsif args.length == 4
      return args[0], args[1], args[2], args[3]
    else
      raise BlankGenerationException, "DictionaryFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end  
  
  def validate
    return false if not super
    return false if ! @nil_ratio.nil? && @nil_ratio.class != Float
    true
  end  
end

class ValueSetFieldGenerator < FieldGenerator
  attr_accessor :values, :nil_ratio, :nil_value
  
  def initialize(*args) # name, values, nil_ratio=nil, nil_value=nil
    name, values, nil_ratio, nil_value = load_init_args args
    # Allow heterogeneous types because we just take an array and pull values from indices to generate distribution
    super(name, ANY)
    @values = values
    @nil_ratio = nil_ratio
    @nil_value = nil_value

    if not validate
      raise BlankGenerationException, "DictionaryGenerator: Validation failed for arguments: name #{name}, values #{values}, nil_ratio #{nil_ratio}, nil_value #{nil_value}"
    end
  end

  def generate(num_records)
    dist = []
    len = @values.length
    num_records.times do |i|
      dist << @values[rand(len)]
    end    
    dist = self.set_nil_values(dist, @nil_ratio, num_records)    
    dist
  end

  private
  
  def load_init_args(args)
    # name, values, nil_ratio, nil_value   
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name], opts[:values], opts[:nil_ratio], opts[:nil_value]
    elsif args.length == 2
      return args[0], args[1], nil, nil
    elsif args.length == 3
      return args[0], args[1], args[2], nil     
    elsif args.length == 4
      return args[0], args[1], args[2], args[3]
    else
      raise BlankGenerationException, "ValueSetFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end  
  
  def validate
    return false if not super
    return false if @values.class != Array || @values.length == 0
    return false if ! @nil_ratio.nil? && @nil_ratio.class != Float
    true
  end
end

# TODO Need child helper object for Histogram and ValueSet or method to create on here statically, 
class HistogramFieldGenerator < FieldGenerator
  HIST_TYPE_RANDOM = 1
  HIST_TYPE_VALUE_SET = 2
  HIST_TYPE_DICTIONARY = 3
   
  class Bucket
    attr_accessor :min_share_boundary, :max_share_boundary, :generator
    
    def initialize(min_share_boundary, max_share_boundary, generator)
      @min_share_boundary = min_share_boundary
      @max_share_boundary = max_share_boundary
      @generator = generator      
    end    
  end 
  
  def initialize(*args) # name , hist_type
    name, hist_type = load_init_args args
    # Called with ANY because Histogram uses Generators passed in #add_bucket_generator() and each of these is a valid generator object
    super(name, ANY) 
    @hist_type = hist_type
    @buckets = []
    # Maintain running total in #add_bucket_generator() which can't exceed 1.0 and must be equal to 1.0 when #generate() is called
    @total_share = 0.0
    if not validate
      raise BlankGenerationException, "HistogramGenerator: Validation failed for arguments: name #{name}, hist_type #{hist_type}"
    end
  end
  
  def add_bucket_generator(share, generator)
    if share.class != Float || (share.class == Float && (share < 0.0 || share > 1.0))
      raise BlankGenerationException, "HistogramGenerator::add_bucket_generator(): Validation failed for arguments: share #{share}. Arg not a Float or not in range 0.0 <= x <= 1.0"
    end
    if @total_share + share > 1.0
      raise BlankGenerationException, "HistogramGenerator::add_bucket_generator(): total_share + share cannot exceed 1.0. total_share #{total_share}, share #{share}"        
    end
    cls = generator.class
    if cls != RandomFieldGenerator && cls != ValueSetFieldGenerator && cls != DictionaryFieldGenerator
      raise BlankGenerationException, "HistogramGenerator::add_bucket_generator(): Validation failed for arguments: generator #{generator.inspect}. Arg not a valid generator type, either RandomFieldGenerator, DictionaryFieldGenerator or ValueSetGenerator"
    end
    # Enforce that all generators are the same type as each other and as the declared type of the Histogram
    # So the class can generate arbitrary distributions but of homogenous data
    if ((cls == RandomFieldGenerator && @hist_type != HIST_TYPE_RANDOM) || 
      (cls == ValueSetFieldGenerator && @hist_type != HIST_TYPE_VALUE_SET) ||
      (cls == DictionaryFieldGenerator && @hist_type != HIST_TYPE_DICTIONARY))
      raise BlankGenerationException, "HistogramGenerator::add_bucket_generator(): Validation failed for values: generator #{generator.inspect} and hist_type #{hist_type}. Generator type doesn't match Histrogram type"
    end
    # Enforce the case that all RandomFieldGenerators added (if the Histogram is type HIST_TYPE_RANDOM)
    #  must be of homogenous data, either all Fixnum or all Float. If this isn't the first generator and this one is Random, then its data type must
    #  match previous generator's data type.
    if cls == RandomFieldGenerator && @buckets.length > 0 && @buckets.last.generator.data_type != generator.data_type
      raise BlankGenerationException, "HistogramGenerator::add_bucket_generator(): Validation failed for values: generator #{generator.inspect} and buckets #{@buckets}. Generator data type doesn't match existing Histogram data type."    
    end

    @buckets.push Bucket.new(@total_share, @total_share + share, generator)
    @total_share += share
  end
  
  def generate(num_records)
    if @total_share != 1.0
      raise BlankGenerationException, "HistogramGenerator::generate(): total_share must equal 1.0 when #generate() is called. total_share == #{total_share}"        
    end    
    dist = []
    num_records.times do |i|
      idx = rand
      @buckets.each do |bucket|
        if bucket.min_share_boundary <= idx && idx < bucket.max_share_boundary
          # Call the #generate() method of the generator for this bucket, with num_records == 1 to get one value back
          dist.push bucket.generator.generate(1)[0]
          break
        end
      end
    end    
    dist
  end
  
  private
  
  def load_init_args(args)
    # name, hist_type   
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name], opts[:hist_type]
    elsif args.length == 2
      return args[0], args[1]
    else
      raise BlankGenerationException, "HistogramFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end  
  
  def validate
    return false if @hist_type != HIST_TYPE_RANDOM && @hist_type != HIST_TYPE_VALUE_SET && @hist_type != HIST_TYPE_DICTIONARY
    true
  end
end

class IdFieldGenerator < FieldGenerator
  DEFAULT_ID_INT_BASE = 0
  DEFAULT_ID_INT_STEP = 1
  
  attr_accessor :id_int_base, :id_int_step
  
  def initialize(*args) # name, id_int_base=nil, id_int_step=nil
    name, id_int_base, id_int_step = load_init_args args
    super(name, INT)
    @id_int_base = id_int_base || DEFAULT_ID_INT_BASE
    @id_int_step = id_int_step || DEFAULT_ID_INT_STEP
    if not validate
      raise BlankGenerationException, "IdFieldGenerator: Validation failed for arguments: name #{name}, id_int_base #{id_int_base}, id_int_step #{id_int_step}"
    end
  end

  def generate(num_records, id_int_base=nil, id_int_step=nil)
    @id_int_base = id_int_base || @id_int_base
    @id_int_step = id_int_step || @id_int_step
    dist = num_records.times.collect {|i| @id_int_base + (i * @id_int_step)}
    # Adjust base so that if #generate() is called again, new Id values will be generated
    @id_int_base += num_records * @id_int_step
    dist
  end
  
  private

  def load_init_args(args)
    # name, id_int_base=nil, id_int_step=nil   
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name], opts[:id_int_base], opts[:id_int_step]
    elsif args.length == 1
      return args[0], nil, nil
    elsif args.length == 2
      return args[0], args[1], nil
    elsif args.length == 3
      return args[0], args[1], args[2]
    else
      raise BlankGenerationException, "IdFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end  
  
  def validate
    return false if ! @nil_ratio.nil? && @nil_ratio.class != Float
    true
  end  
end

class IdUuidFieldGenerator < FieldGenerator
  def initialize(*args) # name
    name = load_init_args args
    super(name, STRING)
  end

  def generate(num_records)
    require 'uuidtools'
    num_records.times.collect {UUIDTools::UUID.random_create}
  end
  
  private
  
  def load_init_args(args)
    # name   
    if args.length == 1 && args[0].class == Hash
      opts = args[0]
      return opts[:name]
    elsif args.length == 1
      return args[0]
    else
      raise BlankGenerationException, "IdUuidFieldGenerator: illegal arguments passed to #initialize() #{args.inspect}"
    end
  end  
end


class BlankFormatter
  # field_data is a hash of arrays, key is field name and value is a list of values, the distribution of the data
  #  for num_records for that field in the, or the values for each "row" or record of data for that field or "column"
  def format(field_data, num_records, formatter_config)
    raise BlankFormatterException, "Must implement in concrete class derived from BlankFormatter. JsonFormatter and CsvFormatter are provided by this library."
  end
end

# TODO Support specific JSON lib options
class JsonFormatter < BlankFormatter
  require 'json'
  
  attr_reader :out_proto, :exclude_nil_fields
  
  def initialize
    @out_proto = nil
    @exclude_nil_fields = false
  end
  
  def out_proto=(out_proto)
    if !out_proto.nil? && out_proto.class != Hash
      raise BlankFormatterException, "Invalid output prototype object #{out_proto}, class == #{out_proto.class}. Must be a Hash."    
    end
    @out_proto = out_proto
  end
  
  def exclude_nil_fields=(flag)
    flag = false if flag.nil?
    if not bool?(flag)
      raise BlankFormatterException, "Invalid exclude_nil_fields value #{exclude_nil_fields}. Must be a Boolean."    
    end
    @exclude_nil_fields = flag
  end
  
  def format(field_data, num_records, formatter_config)
    out = []
    num_records.times do |j|
      record = {}
      field_data.each do |field, data|
        cur_data = data[j]
        if cur_data == NIL_FLD_MARKER
          if not @exclude_nil_fields
            cur_data = nil
            cur_data = formatter_config[field].nil_value if formatter_config[field].respond_to? :nil_value                    
            # We set the marker in #set_nil_values() and here we pick it up and don't include the field if marked
            record[field] = cur_data
          end
        else
          record[field] = cur_data
        end
      end
      out << record
    end
    
    out.to_json
  end
  
end

class CsvFormatter < BlankFormatter
  require 'csv'
  
  # TODO At least support delimiter choice, line separator choice and quote-qualification of each element!
  attr_accessor :line_ending
  
  def initialize
    @line_ending = "\n"
  end
  
  def format(field_data, num_records, formatter_config)
    out = []
    num_records.times do |j|
      record = []
      field_data.each do |field, data|
        cur_data = data[j]
        if cur_data == NIL_FLD_MARKER
          cur_data = nil
          cur_data = formatter_config[field].nil_value if formatter_config[field].respond_to? :nil_value 
        end
        record << cur_data 
      end 
      out << record
    end
    
    csv = ""
    out.each do |row|
      csv << CSV.generate_line(row) + @line_ending
    end
    
    csv    
  end
end
