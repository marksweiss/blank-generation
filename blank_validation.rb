# require 'time'
# require 'util'
# 
# require 'rubygems'
# require 'ruby-debug' ; Debugger.start
# #--
# # SAMPLE DEBUGGER CALLS
# #  Debugger.tracing = true
# #  breakpoint if true == false
# #  Debugger.tracing = false
# #++
# 
# # Author:: Mark S. Weiss  (http://github.com/marksweiss)
# # Copyright:: Copyright (c) 2012 Mark S. Weiss
# # License:: MIT 
# #
# # == Overview
# # Validates that field definitions are valid combinations of keys, i.e. valid syntax, and that the values for each
# # included key are valid values for that type of key, e.g. that the value for a 'mean' key is either int or float.
# #
# # Here is an example of a field definition: <tt>{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}</tt>
# # ---
# # == Field Definition Grammar
# # Here is the complete BNF grammar for the keys of the key-value pairs in field definitions:
# # * S -> name T
# # * T -> dist_type U V
# # * U -> example_value mean std_dev | example_value min max allow_repeat_values | example_value histogram | histogram | value_set | dictionary | id_int_base | id_int_step | id_int_base id_int_step 
# # * V -> nil_ratio | nil_ratio nil_value | nil_ratio nil_include_field | nil_ratio nil_value nil_include_field | EMPTY_SET
# # ---
# # == Field Definition Specification
# # <tt>name</tt>
# # * String 
# # * Required
# # * The name of the field. Must be a string one or more characters in length  .
# #
# # <tt>dist_type</tt>
# # * String with a value in: "normal"|"random"|"histogram"|"value_set"|"id_int"|"id_uuid"|"id_mongo_objid"
# # * Required
# # * The type of distribution to generate:
# # 1. Normal distribution will generate values using the average and standard deviation provided.
# # 2. Random will generate a random distribution of values within the min and max bounds provided and honoring the allow_repeat_values argument provided.
# # 3. Histogram will generate a distribution conforming to the histogram provided. 
# # 4. Value set will generate  a random distribution drawing from the fixed set of values provided. 
# # 5. Id_int will generate monotonically increasing integer id values for each record, using the id_int_step provided or incremening by 1 if no step is provided.
# # 6. Id_uuid will generate a UUID id value for each record. 
# # 7. Id_mongo_objid will generate a MongoDB ObjectId id for each record.
# #
# # <tt>example_value</tt>
# # * Fixnum|Float|ISO 8601 Timestamp String (http://www.w3.org/TR/NOTE-datetime)
# # * Required if <tt>dist_type == "normal"</tt> or <tt>dist_type == "random"</tt> or <tt>dist_type == "histogram"</tt> and there is a <tt>histogram</tt> element supplying bucket values (instead of a <tt>value_set</tt> or <tt>dictionary</tt>). Invalid otherwise.
# # * A value provided as an example of the type of data stored in the field. Used to disambiguate definitions of <tt>"normal"</tt> and <tt>"random"</tt> distributions, which can take arguments describing the distribution of one type and have values of another. For example, you might specifiy <tt>mean</tt> and <tt>std_dev</tt> as floats but want to produce a distribution of integers or ISO 8601 date strings. This application only supports time resolution to the second in ISO 8601 date strings.
# #
# # <tt>mean</tt>
# # * Float|ISO 8601 Timestamp String (http://www.w3.org/TR/NOTE-datetime)
# # * Required if <tt>dist_type == "normal"</tt>. Invalid otherwise.
# # * The average value over all records for data stored in the field.
# # * NOTE: Can supply ISO 8601 date string and Blank Generation will convert to Unix time Fixnum and then to Float to generate distribution. This application only supports time resolution to the second in ISO 8601 date strings.
# #
# # <tt>std_dev</tt>
# # * Float|Array of two ISO 8601 Timestamp Strings
# # * Required if <tt>dist_type == "normal"</tt>. Invalid otherwise.
# # * The standard deviation from the average over all records for data stored in the field.
# # * NOTE: If Array of two ISO 8601 date strings is provided, then these will be converted to Unix time, one subtracted from the other, the absolute value taken and the resulting Fixnum converted to a Float to use as a standard deviation. This application only supports time resolution to the second in ISO 8601 date strings.
# #
# # <tt>min</tt>
# # * Fixnum|Float|ISO 8601 Timestamp String (http://www.w3.org/TR/NOTE-datetime)
# # * Required if <tt>dist_type = "random"</tt>. Invalid otherwise.
# # * The minimum value allowed for a random distribution.
# # * NOTE: Can supply timestamp and Blank Generation will convert to Unix time Fixnum to generate distribution. This application only supports time resolution to the second in ISO 8601 date strings.
# #
# # <tt>max</tt>
# # * Fixnum|Float|ISO 8601 Timestamp String (http://www.w3.org/TR/NOTE-datetime)
# # * Required if <tt>dist_type = "random"</tt>. Invalid otherwise.
# # * The maxium value allowed for a random distribution.
# # * NOTE: Can supply timestamp and Blank Generation will convert to Unix time Fixnum to generate distribution. This application only supports time resolution to the second in ISO 8601 date strings.
# #
# # <tt>allow_repeat_values</tt>
# # * Boolean
# # * Required if <tt>dist_type == "random"</tt>. Invalid otherwise.
# # * Indicates whether values can repeat or must be unique in a random distribution.
# #
# # <tt>dictionary</tt>
# # * String
# # * Optional if <tt>dist_type == "value_set"</tt> or <tt>"histogram"</tt>. Invalid otherwise.
# # * Path to an external dictionary of words or phrases (one per line) to use for generating string data:
# # 1. If provided as the value for the 'value_set' element when 'dist_type' == "value_set", then a random distribution from the dictionary will be generated.
# # 2. If provided as the value for elements in a 'histogram' when 'dist_type' == "histogram", then the dictionary provides the set of values for the histogram bucket.
# #
# # <tt>histogram</tt>
# # * Array of Hash
# # * Required if <tt>dist_type == "histogram"</tt> unless there is a <tt>dictionary</tt> or <tt>value_set</tt> present. Invalid otherwise.
# # * A JSON object describing a histogram distribution, following this format: <tt>[{min : Fixnum|Float|ISO 8601 Timestamp String, max : Fixnum|Float||ISO 8601 Timestamp String, count : Fixnum}, ...]</tt>. As elsewhere ISO 8601 date strings will be converted to Floats or Fixnums as necessary, and time resolution is to the second.
# #
# # <tt>value_set</tt>
# # * Array
# # * Required if <tt>dist_type == "value_set"</tt> unless there is a <tt>dictionary</tt> element present. Optional if <tt>dist_type == "histogram"</tt>. Invalid otherwise. 
# # * An array of values (which can be heterogenous) to draw from to randomly generate a distribution.
# #
# # <tt>id_int_base</tt>
# # * Fixnum
# # * Optional if <tt>dist_type == "id_int"</tt>. Invalid otherwise. 
# # * The starting value from which to generate monotonically incereasing id values. If this key is not specified then a default of 1 is used.
# # 
# # <tt>id_int_step</tt>
# # * Fixnum
# # * Optional if <tt>dist_type == "id_int"</tt>. Invalid otherwise. 
# # * The amount to increment each id value generated. If this key is not specified then a default of 1 is used.
# #
# # <tt>nil_ratio</tt>
# # * Float in the range (0.0 <= x <= 1.0).
# # * Optional with default of 0.0 except explicitly not allowed if <tt>dist_type == "id_*"</tt>, <tt>dist_type == "histogram"</tt>.
# # * NOTE: To support nil values in <tt>histogram</tt> distributions, include a "null bucket" element with a positive count -- so, for a histogram with the sum of its counts == 100 (including the null bucket), including this bucket means each element will have a 50% chance of being null: <tt>{"min" : null, "max" : null, "count" : 50}</tt>
# # * The ratio of records that should have a nil value. Here 'nil' is used loosely and means either the default nil value (no value in CSV output and JSON null in JSON output), or the value provided in the optional <tt>nil_value</tt> field.
# #
# # <tt>nil_value</tt>
# # * ANY
# # * Optional except explicitly not allowed if "<tt>dist_type == "id_*"</tt>, <tt>dist_type == "histogram"</tt>.
# # * NOTE: To support nil values in <tt>histogram</tt> distributions, include a "null bucket" element with a positive count -- so, for a histogram with the sum of its counts == 100 (including the null bucket), including this bucket means each element will have a 50% chance of being null: <tt>{"min" : null, "max" : null, "count" : 50}</tt>
# # * The value of any type desired that should be emitted for records assigned a 'nil' value for this field. For example, to explicitly output empty strings in output, include a <tt>{nil_value : ""}</tt> hash element in the field definition.
# #
# # <tt>nil_include_field</tt>
# # * Boolean
# # * Optional with default of true but invalid if <tt>nil_ratio</tt> is not also present and set to a value > 0.0. Not allowed if "<tt>dist_type == "id_*"</tt>, <tt>dist_type == "histogram"</tt>.
# # * NOTE: To support nil values in <tt>histogram</tt> distributions, include a "null bucket" element with a positive count -- so, for a histogram with the sum of its counts == 100 (including the null bucket), including this bucket means each element will have a 50% chance of being null: <tt>{"min" : null, "max" : null, "count" : 50}</tt>
# # * A flag that toggles whether the field is included if it is nil. Allows generation of data with uniform columns and nils (for example for CSVs or data intended to be used in relational DBs) and generation of  ragged documents only including fields with values (for example for JSON data intended to be used in document DBs)
# # ---
# 
# # TODO
# # EXAMPLES OF DATES
# 
# # == Examples of Each Valid Field Definition
# # === Normal
# # Normal distribution, no nil_ratio specified:
# #  {"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}
# # Normal distribution, nil_ratio specified:
# #  {"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1}
# # Normal distribution, nil_ratio and nil_include_field, specified:
# #  {"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_include_field" : false}
# # Normal distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1}
# # Normal distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}
# #
# # Normal distribution, no nil_ratio specified:
# #  {"name" : "name", "example_value" : 1.0, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}
# # Normal distribution, nil_ratio specified:
# #  {"name" : "name", "example_value" : 1.0, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1}
# # Normal distribution, nil_ratio and nil_include_field, specified:
# #  {"name" : "name", "example_value" : 1.0, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_include_field" : false}
# # Normal distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "example_value" : 1.0, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1}
# # Normal distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "example_value" : 1.0, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}
# #
# # Normal distribution, no nil_ratio specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}
# # Normal distribution, nil_ratio specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1}
# # Normal distribution, nil_ratio and nil_include_field, specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_include_field" : false}
# # Normal distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1}
# # Normal distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}
# # ---
# # === Random
# # Random distribution, no nil_ratio specified:
# #  {"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random"}
# # Random distribution, nil_ratio specified:
# #  {"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1}
# # Random distribution, nil_ratio and nil_include_field specified:
# #  {"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_include_field" : false}
# # Random distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1}
# # Random distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}
# #
# #  {"name" : "name", "example_value" : 1.0, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random"}
# # Random distribution, nil_ratio specified:
# #  {"name" : "name", "example_value" : 1.0, "min" : 1.0, "max" : 100000.0, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1}
# # Random distribution, nil_ratio and nil_include_field specified:
# #  {"name" : "name", "example_value" : 1.0, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_include_field" : false}
# # Random distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "example_value" : 1.0, "min" : 1.0, "max" : 100000.0, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1}
# # Random distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "example_value" : 1.0, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}
# #
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random"}
# # Random distribution, nil_ratio specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1}
# # Random distribution, nil_ratio and nil_include_field specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_include_field" : false}
# # Random distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1}
# # Random distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}
# # === Histogram
# # Histogram distribution for numeric data:
# #  {"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, count: 50}, {"min" : 1124, "max" : 18532, count: 53}]}
# #  {"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"min" : 0.0, "max" : 1123.0, count: 50}, {"min" : 1124.0, "max" : 18532.0, count: 53}]}
# #  {"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", count: 50}, {"min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", count: 53}]}
# # Histogram distribution for String data using a value_set:
# #  {"name" : "name", "dist_type" : "histogram", "histogram" : [{"value_set" : ["a", "b", "c"], count: 50}, {"value_set" : ["d", "e", "f"], count: 53}]}
# # Histogram distribution for string data using a dictionary:
# #  {"name" : "name", "dist_type" : "histogram", "histogram" : [{"dictionary" : "/PATH_TO_DICT_1", count: 50}, {"dictionary" : "/PATH_TO_DICT_2", count: 53}]}
# #
# # === Value Set
# # Value Set distribution, no nil_ratio specified:
# #  {"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}
# # Value Set distribution, nil_ratio specified:
# #  {"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1}
# # Value Set distribution, nil_ratio and nil_include_field specified:
# #  {"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1, "nil_include_field" : true}
# # Value Set distribution, nil_ratio and nil_value specified:
# #  {"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1, "nil_value" : -1}
# # Value Set distribution, nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : true}
# # Value Set distribution, String data, with Dictionary, no nil_ratio specified:
# #  {"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH_TO_DICT_1"}}
# # Value Set distribution, String data, with Dictionary, nil_ratio specified:
# #  {"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH_TO_DICT_1", "nil_ratio" : 0.1}
# # Value Set distribution, String data, with Dictionary, nil_ratio and nil_include_field specified:
# #  {"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH_TO_DICT_1", "nil_ratio" : 0.1, "nil_include_field" : true}
# # Value Set distribution, String data, with Dictionary, nil_ratio and nil_value specified:
# #  {"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH_TO_DICT_1", "nil_ratio" : 0.1, "nil_value" : -1}
# # Value Set distribution,String data, with Dictionary,  nil_ratio, nil_value and nil_include_field specified:
# #  {"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH_TO_DICT_1", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : true}
# #
# # === Id_Int
# # Id_int distribution, no id_int_base or id_int_step specified:
# #  {"name" : "name", "dist_type" : "id_int"}
# # Id_int distribution, id_int_base specified but no id_int_step specified:
# #  {"name" : "name", "dist_type" : "id_int", "id_int_base" : 1000000}
# # Id_int distribution, id_int_base specified and id_int_step specified:
# #  {"name" : "name", "dist_type" : "id_int", "id_int_base" : 1000000, "id_int_step" : 20}
# #
# # === Id_uuid distribution:
# #  {"name" : "name", "dist_type" : "id_uuid"}
# #
# # === Id_mongo_objid distribution:
# #  {"name" : "name", "dist_type" : "id_mongo_objid"}
# #
# class BlankValidator
# 
#   public
#   
#   # Validate a field definition syntax (i.e. - it's set of keys), and the value for each key.
#   # <tt>field_def</tt> - a JSON field defintion (see the full specification in the documentation for this module <tt>BlankValidator</tt>)
#   def validate_field_def(field_def)
#     # Copy the field_def
#     # Walk this recursive descent parser until successful termination or failed termination
#     # Each successful step consumes a key in the copied field_def. 
#     #  So successful termination occurs when the copied field_def is empty.
#     #  Failure occurs when the state machine advances to a state where it cannot continue and it is not empty
#     # The grammar defined by the JSON spec for field definitions is context-free
#     # The terminals of the grammar are the keys in the field_def hash
#     # 'name' is the Start symbol of the grammar
#     #
#     # * S -> name T
#     # * T -> dist_type U V
#     # * U -> example_value mean std_dev | example_value min max allow_repeat_values | example_value histogram | histogram | value_set | dictionary | id_int_base | id_int_step | id_int_base id_int_step 
#     # * V -> nil_ratio | nil_ratio nil_value | nil_ratio nil_include_field | nil_ratio nil_value nil_include_field | EMPTY_SET
#     
#     # Violating a cardinal rule here, using exceptions for flow control, but ...
#     # We are doing recursive descent, which means failures can occur from an arbitrarily deep call stack, and we want to unwind
#     #  all the way up as soon as we hit any failure. The only two ways to do that are exceptions and goto, and exceptions are clean and centralized.
#     # Also, the goal is to return errors as a JSON message and not make the client handle excpetions, because the intent of this code is to be
#     #  as technology-independent and service-oriented as possible. By returning JSON messages this code is ready to be as service to any client in any language
#     #  or to be piped etc.
#     begin
#       # Keep the original and modify that with converted values to return to the client. So this call does two things. First, makes a copy
#       #  of the field_def and parses and consumes that -- if it consumes it the def is valid, so simple recursive descent parser. Second,
#       #  modifies the original with any converted values (dates into ints) and returns that to the client to use for generating the data.      
#       @field_def_orig = field_def
#       start(deep_copy(field_def))
#     rescue BlankGenerationValidatorException => e
#       build_return_value(false, e.message, @field_def_orig)
#     end
#       
#   end
# 
#   private
#   
#   class BlankGenerationValidatorException < Exception; end
#   
#   # Start state of the validating parser. Consumes the <tt>name</tt> element.
#   def start(fd)
#     name = fd["name"]
#     if name.nil? || name.class != String || name.length == 0
#       raise BlankGenerationValidatorException, "Failure validating field_def. Required field 'name' not found or empty string value provided."
#     end
#     
#     fd.delete "name"
#     dist_type(fd)
#   end
#   
#   # State in the validating parser. Consumes the <tt>dist_type</tt> element. Dispatches along appropriate
#   # path in recursive descent parse depending on value for dist_type
#   def dist_type(fd)
#     dist_type = fd["dist_type"]
#     if dist_type.nil? || dist_type.class != String || dist_type.length == 0
#       raise BlankGenerationValidatorException, "Failure validating field_def. Required field 'dist_type' not found or empty string value provided."
#     end
#     
#     fd.delete "dist_type"
#     
#     case dist_type
#       when "normal"
#         normal(fd)
#       when "random"
#         random(fd)          
#       when "histogram"
#         histogram(fd)
#       when "value_set"
#         value_set(fd)
#       when "id_int"
#         id_int(fd)
#       when "id_uuid"
#         id_uuid(fd)
#       when "id_mongo_objid"
#         id_mongo_objid(fd)
#       else
#         raise BlankGenerationValidatorException, "Failure validating field_def. Value for 'dist_type' not one of the legal values [normal|random|histogram|value_set|id_int|id_uuid|id_mongo_objid]."
#     end
#   end
#   
#   def normal(fd)
#     converted_vals = validate_fields(fd, "normal", "example_value", "mean", "std_dev")
#     @field_def_orig["mean"] = converted_vals["mean"]
#     @field_def_orig["std_dev"] = converted_vals["std_dev"]
# 
#     # Delete the keys required for this dist_type
#     delete_fields(fd, "example_value", "mean", "std_dev")
# 
#     validate_invalid_fields(fd, "normal", "min", "max", "allow_repeat_values", "value_set", "dictionary", "id_int_base", "id_int_step")
#     
#     # Test for and delete if found the optional fields for this dist_type
#     nil_fields(fd)
#   end
#     
#   def random(fd)
#     converted_vals = validate_fields(fd, "random", "example_value", "min", "max", "allow_repeat_values")
#     @field_def_orig["min"] = converted_vals["min"]
#     @field_def_orig["max"] = converted_vals["max"]
#     
#     # 'min' must be <= 'max' or the pair of values don't define a valid range of values to draw a distribution from
#     if fd["min"] > fd["max"]
#       raise BlankGenerationValidatorException, "Failure validating field_def. Field 'min' must be <= field 'max'"
#     end
#     
#     delete_fields(fd, "example_value", "min", "max", "allow_repeat_values")
# 
#     validate_invalid_fields(fd, "normal", "mean", "std_dev", "value_set", "dictionary", "id_int_base", "id_int_step")
#     
#     nil_fields(fd)
#   end
# 
#   def histogram(fd)
#     # TODO REFACTOR. This is definitely ugly. validate_field_val() handles some resassignmnet of values
#     #  because it has to handle the case of recursing to modify the 'min' and 'max' fields of 'histogram'
#     # And up here there is additional reassignment handling. Also, we ignore the return value except where
#     #  we care, which is more inconsistent special case login 
#     converted_val = validate_field("histogram", fd["histogram"], "histogram")
#     @field_def_orig["histogram"] = converted_val
#     
#     # TEMP DEBUG
#     puts "\n\nhistogram\n@field_def_orig #{@field_def_orig.inspect}"
#     
#     # If the histogram has a 'min' and 'max' then field_def must have example value
#     h = fd["histogram"][0]
#     if h.include?("min") && h.include?("max")
#       validate_field("example_value", fd["example_value"], "histogram")
#       delete_fields(fd, "histogram", "example_value")      
#     else
#       validate_invalid_field("example_value", fd["example_value"], "histogram")      
#       delete_fields(fd, "histogram")      
#     end
# 
#     validate_invalid_fields(fd, "histogram", "mean", "std_dev", "min", "max", "allow_repeat_values", "value_set", "dictionary", "id_int_base", "id_int_step", "nil_ratio", "nil_value", "nil_include_field")
# 
#     check_terminate(fd)
#   end
# 
#   def value_set(fd)
#     if !fd.include?("value_set") && !fd.include?("dictionary")
#       raise BlankGenerationValidatorException, "Failure validating field_def. Field 'value_set' or field 'dictionary' required for dist_type = 'value_set.' Neither provided."
#     end
#     validate_field("value_set", fd["value_set"], "value_set") if fd.include?("value_set")
#     validate_field("dictionary", fd["dictionary"], "value_set") if fd.include?("dictionary")
# 
#     delete_fields(fd, "value_set", "dictionary")
# 
#     validate_invalid_fields(fd, "value_set", "example_value", "mean", "std_dev", "min", "max", "histogram", "allow_repeat_values", "id_int_base", "id_int_step")
# 
#     nil_fields(fd)
#   end
# 
#   def id_int(fd)
#     validate_field("id_int_base", fd["id_int_base"], "id_int") if !fd["id_int_base"].nil?
#     validate_field("id_int_step", fd["id_int_step"], "id_int") if !fd["id_int_step"].nil?
# 
#     validate_invalid_fields(fd, "id_int", "example_value", "mean", "std_dev", "min", "max", "allow_repeat_values", "histogram", "value_set", "dictionary", "nil_ratio", "nil_value", "nil_include_field")
#     
#     delete_fields(fd, "id_int_base", "id_int_step") 
#     
#     check_terminate(fd)
#   end
#   
#   def id_uuid(fd)
#     validate_invalid_fields(fd, "id_uuid", "id_int_base", "id_int_step", "example_value", "mean", "std_dev", "min", "max", "allow_repeat_values", "histogram", "value_set", "dictionary", "nil_ratio", "nil_value", "nil_include_field")
#       
#     check_terminate(fd)
#   end
#   
#   def id_mongo_objid(fd)
#     validate_invalid_fields(fd, "id_mongo_objid", "id_int_base", "id_int_step", "example_value", "mean", "std_dev", "min", "max", "allow_repeat_values", "histogram", "value_set", "dictionary", "nil_ratio", "nil_value", "nil_include_field")
#   
#     check_terminate(fd)
#   end
# 
#   def nil_fields(fd)
#     # Can't have 'nil_include_field' without a positive 'nil_ratio'
#     nil_ratio = fd["nil_ratio"]
#     nil_include_field = fd.include?("nil_include_field")
#     if (nil_ratio.nil? || nil_ratio.class != Float || nil_ratio <= 0.0) && nil_include_field
#       raise BlankGenerationValidatorException, "Failure validating field_def. Invalid to provide value for 'nil_include_field' but not 'nil_ratio'. 'nil_include_field' = #{nil_include_field} and 'nil_ratio' = #{nil_ratio}"
#     end
#     # These fields are never required, and can be included or not in any combination.
#     # So simply consume them if they are present and of the valid type
#     validate_optional_field("nil_ratio", fd["nil_ratio"], "MANY")
#     validate_optional_field("nil_include_field", fd["nil_include_field"], "MANY")
#     delete_fields(fd, "nil_ratio", "nil_value", "nil_include_field")      
#     # Optional fields always checked last, check for empty field_def hash, if it has been consumed
#     #  parse succeeded and it is valid
#     check_terminate(fd)
#   end
# 
#   # This is the bottom of the recursive descent, if we have consumed all keys in field_def, return true
#   #  otherwise return false
#   def check_terminate(fd)
#     len = fd.length 
#     ret_val = (len == 0)
#     err_msg = (ret_val ? "" : "Validation of field_def failed. #{len} fields were not consumed.  This what was not consumed:\n#{fd.inspect}")
#     
#     # TEMP DEBUG
#     #if fd["dist_type"] == "histogram"
#     puts "\n\nIN CHECK_TERMINATE @field_def_orig =\n#{@field_def_orig.inspect}"
#     puts "\nLEN = #{len}"
#     puts  "\nret_val = #{ret_val}"
#     #end
#     
#     ret_val ? build_return_value(true, err_msg, @field_def_orig) : build_return_value(false, err_msg, @field_def_orig)
#   end
#   
#   def build_return_value(ret_val, err_msg, field_def_orig)
#     {"return_val" => ret_val, "err_msg" => err_msg, "field_def_converted" => field_def_orig}
#   end
#   # /
#   
#   # Validate optional field_def field values
#   def validate_optional_field(key, val, dist_type)
#     return true if val.nil?
#     ret, converted_val = validate_field_val(key, val)
#     if not ret
#       raise BlankGenerationValidatorException, "Failure validating field_def. Invalid value #{val.inspect} for field == '#{key}' for dist_type == '#{dist_type}'"
#     end
#     
#     converted_val
#   end
#   
#   def validate_fields(fd, dist_type, *keys)
#     converted_vals = {}
#     keys.each do |key|
#       converted_vals[key] = validate_field(key, fd[key], dist_type)
#     end
#     
#     converted_vals
#   end
#   
#   # Validate field_def field values
#   def validate_field(key, val, dist_type)    
#     if val.nil?
#       raise BlankGenerationValidatorException, "Failure validating field_def. Required field '#{key}' not found for dist_type == '#{dist_type}'"
#     end
#     ret, converted_val = validate_field_val(key, val)
#     if not ret
#       raise BlankGenerationValidatorException, "Failure validating field_def. Invalid value #{val.inspect} for field == '#{key}' for dist_type == '#{dist_type}'"
#     end
#     
#     converted_val
#   end
#   
#   def validate_field_val(key, val)
#     cls = val.class
#     converted_val = val
#   
#     if key == "example_value"
#       return (cls == Float || cls == Fixnum || (cls == String && validate_date_str(val))), converted_val
#     elsif key == "mean"
#       return true, converted_val if cls == Float
#       # Test Date String case, true if passes and set converted value in original field_def
#       is_valid_date = (cls == String && validate_date_str(val))
#       if is_valid_date
#         converted_val = Time.parse(val).to_i
#         return true, converted_val
#       else
#         return false, converted_val
#       end
#     elsif key == "std_dev"
#       return true, converted_val if cls == Float        
#       is_valid_date = (cls == Array && val.length == 2 && validate_date_str(val[0]) && validate_date_str(val[1]))
#       if is_valid_date
#         converted_val = date_diff_to_i(val[0], val[1])
#         return true, converted_val
#       else
#         return false, converted_val
#       end
#     elsif key == "min" || key == "max"
#       return true, converted_val if cls == Float || cls == Fixnum
#       # Test Date String case, true if passes and set converted value in original field_def      
#       is_valid_date = (cls == String && validate_date_str(val))
#       if is_valid_date
#         converted_val = Time.parse(val).to_i
#         return true, converted_val
#       else
#         return false, converted_val
#       end      
#     elsif key == "allow_repeat_values" || key == "nil_include_field"
#       return (cls == TrueClass || cls == FalseClass), converted_val   
#     elsif key == "histogram"        
#       # Must be an Array with at least one valid histogram value
#       return false, converted_val if cls != Array || (cls == Array && val.length == 0)    
#       # Valid values are triples of (min, max, count) or doubles of (value_set, count) or doubles of (path to dictionary (string), count)          
#       val.each do |h|
#         # 'min' without 'max' or 'max' without 'min' is error, but OK to not have either
#         return false, val if ! h.include?("min") && h.include?("max")
#         return false, val if h.include?("min") && ! h.include?("max")         
#         # Return false if there is more than one source of values in the histogram
#         return false, val if h.include?("value_set") && h.include?("dictionary")
#         # If we have 'min' and 'max' then validate their type
#         if h.include?("min") && h.include?("max")
#           # Return false if there is more than one source of values in the histogram
#           return false, val if h.include?("value_set") || h.include?("dictionary")
#            # 'min' and 'max' must have same type, actual types being valid are tested on validation of 'min' and 'max' on recursion from here
#           return false, val if h["min"].class != h["max"].class
#           return false, val if h["min"] > h["max"] 
#           # Two special cases. Recursed in histogram value on it's 'min' and 'max' fields. Set the converted
#           #  values in the histogram object and return that, as that was the value for key 'histogram' passed in
#           ret, converted_val = validate_field_val("min", h["min"])
#           return false, val if not ret
#           # Validation passed, 'min' field of histogram converted, set value in the histogram
#           h["min"] = converted_val
#           ret, converted_val = validate_field_val("max", h["max"])
#           return false, val if not ret
#           h["max"] = converted_val                    
#         # If we have a 'value_set' histogram then validate that
#         elsif h.include?("value_set")
#           return false, converted_val if not validate_field_val("value_set", h["value_set"])[0]
#         # If we have a 'dictionary' histogram then validate that
#         elsif h.include?("dictionary")
#           return false, converted_val if not validate_field_val("dictionary", h["dictionary"])[0]
#         end            
#         # Now validate 'count' is a whole number
#         ct = h["count"]
#         return false, converted_val if ct.nil? || ct.class != Fixnum || ct < 0        
#       end
#             
#       return true, val      
#     elsif key == "value_set"
#       if cls == Array && val.length > 0
#         return true, converted_val
#       else
#         return false, converted_val
#       end
#       return false, converted_val if not cls        
#       val_cls = val[0].class
#       # All elements in the value set must be the same type        
#       val.each do |v|
#         return false, converted_val if v.class != val_cls
#       end
#     elsif key == "dictionary"
#       return (cls == String && val.length > 0), converted_val
#     elsif key == "id_int_base" || key == "id_int_step"
#       return (cls == Fixnum), converted_val
#     elsif key == "nil_ratio"
#       return (cls == Float && (val >= 0.0 && val <= 1.0)), converted_val
#     end
#   end
#   
#   def validate_invalid_fields(fd, dist_type, *keys)
#     keys.each do |key|
#       validate_invalid_field(key, fd[key], dist_type)
#     end
#   end
#   
#   def validate_invalid_field(key, val, dist_type)
#     if not val.nil?
#       raise BlankGenerationValidatorException, "Failure validating field_def. Illegal field '#{key}' found for dist_type == '#{dist_type}'"      
#     end    
#   end
#   # /
#   
#   # Helpers
#   def delete_fields(fd, *fields)
#     fields.each do |f|
#       fd.delete f
#     end
#   end
# 
#   def deep_copy(o)
#     Marshal.load(Marshal.dump(o))
#   end
#   
# end
