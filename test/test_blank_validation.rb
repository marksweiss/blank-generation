# require "testutil"
# $LOAD_PATH << psub("../")
# require "rubygems"
# require "json"
# require "test/unit"
# require "blank_validation"
# 
# require 'ruby-debug' ; Debugger.start
# 
# 
# class BlankValidator_Test < Test::Unit::TestCase
#   
#   def setup
#     @validator = BlankValidator.new
#   end
# 
#   def run_test(field_def, msg)
#     puts "\n" + msg + " ENTERED"
#     ret = @validator.validate_field_def(field_def)
#     assert(ret["return_val"], ret["err_msg"])
#     puts "SUCCESS\n#{msg} COMPLETED"
#   end
# 
#   def run_invalid_test(field_def, msg)
#     puts "\n" + msg + " ENTERED"
#     ret = @validator. validate_field_def(field_def)    
#     # Testing for correctly identifying illegal cases, so expecting a false return value, i.e. expecting that parse failed.
#     assert(! ret["return_val"], "Didn't generate expected failure")
#     puts "SUCCESS -- received expected failure message:\n#{ret['err_msg']}" if not ret["return_val"]
#     puts msg + " COMPLETED"
#   end
# 
#   def test__normal
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : "1997-07-16T19:20:30.45+01:00", "std_dev" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "normal"}!    
#     run_test(field_def, "normal: no nil_value")
#     
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : "1997-07-16T19:20:30.45+01:00", "std_dev" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "normal", "nil_ratio" : 0.1}!    
#     run_test(field_def, "normal: nil_ratio")
#     
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : "1997-07-16T19:20:30.45+01:00", "std_dev" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "normal", "nil_ratio" : 0.1, "nil_include_field" : false}!    
#     run_test(field_def, "normal: nil_ratio nil_include_field")
#         
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : "1997-07-16T19:20:30.45+01:00", "std_dev" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1}!    
#     run_test(field_def, "normal: nil_ratio nil_value")
#     
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "mean" : "1997-07-16T19:20:30.45+01:00", "std_dev" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}!    
#     run_test(field_def, "normal: nil_ratio nil_value nil_include_field")
#   
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}!    
#     run_test(field_def, "normal: no nil_value")
#     
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1.5, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1}!    
#     run_test(field_def, "normal: nil_ratio")
#     
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_include_field" : false}!    
#     run_test(field_def, "normal: nil_ratio nil_include_field")
#         
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1.5, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1}!    
#     run_test(field_def, "normal: nil_ratio nil_value")
#     
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}!    
#     run_test(field_def, "normal: nil_ratio nil_value nil_include_field")
#   end
# 
#   # def test__random
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random"}!    
#   #   run_test(field_def, "random: no nil_value")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1}!    
#   #   run_test(field_def, "random: nil_ratio")
#   #   
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_include_field" : false}!    
#   #   run_test(field_def, "random: nil_ratio nil_include_field")
#   #   
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1}!    
#   #   run_test(field_def, "random: nil_ratio nil_value")
#   #   
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}!    
#   #   run_test(field_def, "random: nil_ratio nil_value nil_include_field")
#   #   
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1.0, "min" : 0.0, "max" : 1.0, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}!    
#   #   run_test(field_def, "random: example_value float nil_ratio nil_value nil_include_field")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random"}!    
#   #   run_test(field_def, "random: no nil_value")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1}!    
#   #   run_test(field_def, "random: nil_ratio")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1.0, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_include_field" : false}!    
#   #   run_test(field_def, "random: nil_ratio nil_include_field")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1}!    
#   #   run_test(field_def, "random: nil_ratio nil_value")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1.0, "min" : 1, "max" : 100000, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}!    
#   #   run_test(field_def, "random: nil_ratio nil_value nil_include_field")
#   #   
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1.0, "min" : 0.0, "max" : 1.0, "allow_repeat_values" : true, "dist_type" : "random", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : false}!    
#   #   run_test(field_def, "random: example_value float nil_ratio nil_value nil_include_field")
#   # end
# 
#   def test__histogram
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "histogram", "histogram" : [{"min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "count" : 50}, {"min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "count" : 53}]}!    
#     run_test(field_def, "histogram: numeric data")
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : "1997-07-16T19:20:30.45+01:00", "dist_type" : "histogram", "histogram" : [{"min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "count" : 50}, {"min" : "1997-07-16T19:20:30.45+01:00", "max" : "1997-07-16T19:20:30.45+01:00", "count" : 53}]}!    
#     run_test(field_def, "histogram: numeric data")
# 
# 
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#     run_test(field_def, "histogram: numeric data")
#     field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"min" : 0.0, "max" : 1123.0, "count" : 50}, {"min" : 1124.0, "max" : 18532.56, "count" : 53}]}!    
#     run_test(field_def, "histogram: numeric data")
# 
#     field_def = JSON.parse %q!{"name" : "name", "dist_type" : "histogram", "histogram" : [{"value_set" : ["a", "b", "c"], "count": 50}, {"value_set" : ["d", "e", "f"], "count": 53}]}!    
#     run_test(field_def, "histogram: value_set string data")
# 
#     field_def = JSON.parse %q!{"name" : "name", "dist_type" : "histogram", "histogram" : [{"dictionary" : "/PATH TO DICT 1", "count" : 50}, {"dictionary" : "/PATH TO DICT 2", "count" : 53}]}!    
#     run_test(field_def, "histogram: dictionary string data")
#   end
# 
#   # def test__value_set
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_test(field_def, "value_set: no nil_value")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1}!    
#   #   run_test(field_def, "value_set: nil_ratio")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1, "nil_include_field" : true}!    
#   #   run_test(field_def, "value_set: nil_ratio nil_include_field")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1, "nil_value" : -1}!    
#   #   run_test(field_def, "value_set: nil_ratio nil_value")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21], "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : true}!    
#   #   run_test(field_def, "value_set: nil_ratio nil_value nil_include_field")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH TO DICT 1"}!    
#   #   run_test(field_def, "value_set: dictionary string data no nil_valu")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH TO DICT 1", "nil_ratio" : 0.1}!    
#   #   run_test(field_def, "value_set: dictionary string data nil_ratio")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH TO DICT 1", "nil_ratio" : 0.1, "nil_include_field" : true}!    
#   #   run_test(field_def, "value_set: dictionary string data nil_ratio nil_include_field")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH TO DICT 1", "nil_ratio" : 0.1, "nil_value" : -1}!    
#   #   run_test(field_def, "value_set: dictionary string data nil_ratio nil_value")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : "PATH TO DICT 1", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : true}!    
#   #   run_test(field_def, "value_set: dictionary string data nil_ratio nil_value nil_include_field")
#   # end
#   # 
#   # def test__id_int
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_int"}!    
#   #   run_test(field_def, "id_int")
#   # 
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_int", "id_int_base" : 1000000}!    
#   #   run_test(field_def, "id_int: int_base")
#   #   
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_int", "id_int_base" : 1000000, "id_int_step" : 20}!    
#   #   run_test(field_def, "id_int: id_int_base id_int_step")
#   # end
#   # 
#   # def test__id_uuid
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_uuid"}!    
#   #   run_test(field_def, "id_uuid")    
#   # end
#   # 
#   # def test__id_mongo_objid
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_mongo_objid"}!    
#   #   run_test(field_def, "id_mongo_objid")  
#   # end
#   # 
#   # def test__invalid_field_def_fields
#   #   # name  
#   #   # Missing required field 'name'
#   #   field_def = JSON.parse %q!{"dist_type" : "id_mongo_objid"}!    
#   #   run_invalid_test(field_def, "missing name")    
#   #   # Missing value for required field 'name'
#   #   field_def = JSON.parse %q!{"name" : null, "dist_type" : "id_mongo_objid"}!    
#   #   run_invalid_test(field_def, "name: missing value")    
#   #   # Empty value for required field 'name'
#   #   field_def = JSON.parse %q!{"name" : "", "dist_type" : "id_mongo_objid"}!    
#   #   run_invalid_test(field_def, "name: empty value")    
#   #   # Invalid type required field 'name', valid types: String
#   #   field_def = JSON.parse %q!{"name" : 100, "dist_type" : "id_mongo_objid"}!    
#   #   run_invalid_test(field_def, "name: invalid type")    
#   #   
#   #   # dist type
#   #   # Missing required field 'dist type'
#   #   field_def = JSON.parse %q!{"name" : "name"}!    
#   #   run_invalid_test(field_def, "dist_type: missing")    
#   #   # Missing value for required field 'dist type'
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : null}!    
#   #   run_invalid_test(field_def, "dist_type: missing value")    
#   #   # Empty value for required field 'dist type'
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : ""}!    
#   #   run_invalid_test(field_def, "dist_type: empty value")    
#   #   # Invalid value for required field 'dist type'
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "Snippy"}!    
#   #   run_invalid_test(field_def, "dist_type: invalid value")
#   #   # Invalid type for required field 'dist type', valid types: String
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : 100}!    
#   #   run_invalid_test(field_def, "dist_type: invalid type")
#   #   
#   #   # example value
#   #   # 'dist type' == "normal" requires 'example value', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: example value: missing")
#   #   # 'dist type' == "normal" requires 'example value', field present but has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : null, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: example value: null")
#   #   # 'dist type' == "normal" requires 'example value', field present but has invalid type, valid types: Fixnum, Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "x", "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: example_value: invalid type")
#   #   #
#   #   # 'dist type' == "random" requires 'example value', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: example_value: missing")
#   #   # 'dist type' == "random" requires 'example value', field present but has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : null, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: example_value: null")
#   #   # 'dist type' == "random" requires 'example value', field present but has invalid type, valid types: Fixnum, Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "x", "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: example_value: invalid type")
#   #   #
#   #   # 'dist type' == "histogram" and 'histogram' field is present requires 'example value', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: example_value: missing")
#   #   # 'dist type' == "histogram" and 'histogram' field is present requires 'example value', field present but has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : null, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: example_value: null")
#   #   # 'dist type' == "histogram" and 'histogram' field is present requires 'example value', field present but has invalid type, valid types: Array (of JSON objects)
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : "x", "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: example_value: invalid type")
#   #   # 'dist type' == "histogram" and 'histogram' field is not present but 'value set' is so 'example value' invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"value_set" : ["a", "b", "c"], "count": 50}, {"value_set" : ["d", "e", "f"], "count": 53}]}!    
#   #   run_invalid_test(field_def, "histogram: value_set: value is invalid")
#   #   # 'dist type' == "histogram" and 'histogram' field is not present but 'dictionary' is so 'example value' invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "histogram" : [{"dictionary" : "/PATH TO DICT 1", "count" : 50}, {"dictionary" : "/PATH TO DICT 2", "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: dictionary: value is invalid")
#   #   #
#   #   # 'dist type' == "value_set" then 'example value' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 100, "dist_type" : "value_set"}!
#   #   run_invalid_test(field_def, "value_set: example_value: is invalid")
#   #   # 'dist type' == "id_int" then 'example value' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 100, "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: example_value: is invalid")
#   #   # 'dist type' == "id_uuid" then 'example value' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 100, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: example_value: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'example value' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 100, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: example_value: is invalid")
#   #   
#   #   # mean
#   #   # 'dist type' == "normal" requires 'mean', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: mean: missing")
#   #   # 'dist type' == "normal" requires 'mean', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : null, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: mean: null")
#   #   # 'dist type' == "normal" requires 'mean', field has invalid type, valid types: Fixnum, Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : "x", "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: mean: invalid type")
#   #   #
#   #   # 'dist type' == 'random' and 'mean' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 0.5, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: mean: is invalid")
#   #   # 'dist type' == 'histogram' and 'mean' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 0.5, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: mean: is invalid")
#   #   # 'dist type' == 'value set' and 'mean' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "mean" : 0.5, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: mean: is invalid")
#   #   # 'dist type' == "id_int" then 'mean' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "mean" : 0.5, "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: mean: is invalid")
#   #   # 'dist type' == "id_uuid" then 'mean' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "mean" : 0.5, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: mean: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'mean' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "mean" : 0.5, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: mean: is invalid")
#   #   
#   #   # std dev
#   #   # 'dist type' == "normal" requires 'std dev', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: std_dev: missing")
#   #   # 'dist type' == "normal" requires 'std dev', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1,  "mean" : 1, "std_dev" : null, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: std_dev: null")
#   #   # 'dist type' == "normal" requires 'std dev', field has invalid type, valid types: Fixnum, Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : "x", "std_dev" : "x", "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: std_dev: invalid type")
#   #   #
#   #   # 'dist type' == 'random' and 'std dev' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "std_dev" : 0.5, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: std_dev: is invalid")
#   #   # 'dist type' == 'histogram' and 'std dev' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "std_dev" : 0.5, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: std_dev: is invalid")
#   #   # 'dist type' == 'value set' and 'std dev' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "std_dev" : 0.5, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: std_dev: is invalid")
#   #   # 'dist type' == "id_int" then 'std dev' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "std_dev" : 0.5, "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: std_dev: is invalid")
#   #   # 'dist type' == "id_uuid" then 'std dev' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "std_dev" : 0.5, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: std_dev: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'std dev' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "std_dev" : 0.5, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: std_dev: is invalid")
#   #   
#   #   # min
#   #   # 'dist type' == "random" requires 'min', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: min: missing")
#   #   # 'dist type' == "random" requires 'min', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : null, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: min: null")
#   #   # 'dist type' == "random" requires 'min', field has invalid type, valid types: Fixnum, Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : "x", "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: min: invalid")
#   #   #
#   #   # 'dist type' == 'normal' and 'min' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: min: is invalid")
#   #   # 'dist type' == 'histogram' and 'min' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: min: is invalid")
#   #   # 'dist type' == 'value set' and 'min' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "min" : 1, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: min: is invalid")
#   #   # 'dist type' == "id_int" then 'min' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "min" : 1, "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: min: is invalid")
#   #   # 'dist type' == "id_uuid" then 'min' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "min" : 1, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: min: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'min' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "min" : 1, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: min: is invalid")
#   #   #
#   #   # 'dist type' == "random" and 'min' > 'max'
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 2, "max" : 1, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: min|max: min > max")
#   #           
#   #   # max
#   #   # 'dist type' == "random" requires 'max', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: max: missing")
#   #   # 'dist type' == "random" requires 'max', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : null, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: max: null")
#   #   # 'dist type' == "random" requires 'max', field has invalid type, valid types: Fixnum, Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : "x", "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: max: invalid type")
#   #   #
#   #   # 'dist type' == 'normal' and 'max' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "max" : 1, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: max: is invalid")
#   #   # 'dist type' == 'histogram' and 'max' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "max" : 1, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: max: is invalid")
#   #   # 'dist type' == 'value set' and 'max' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "max" : 1, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: max: is invalid")
#   #   # 'dist type' == "id_int" then 'max' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "max" : 1, "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: max: is invalid")
#   #   # 'dist type' == "id_uuid" then 'max' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "max" : 1, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: max: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'max' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "max" : 1, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: max: is invalid")
#   #   
#   #   # allow repeat values
#   #   # 'dist type' == "random" requires 'allow repeat values', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: allow_repeat_values: missing")
#   #   # 'dist type' == "random" requires 'allow repeat values', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : null, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: allow_repeat_values: null")
#   #   # 'dist type' == "random" requires 'allow repeat values', field has invalid type, valid types: Boolean
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : "x", "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: allow_repeat_values: invalid type")
#   #   #
#   #   # 'dist type' == 'normal' and 'allow repeat values' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "allow repeat values" : true, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: allow_repeat_values: is invalid")
#   #   # 'dist type' == 'histogram' and 'allow repeat values' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "allow repeat values" : true, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: allow_repeat_values: is invalid")
#   #   # 'dist type' == 'value set' and 'allow repeat values' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "allow repeat values" : true, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: allow_repeat_values: is invalid")
#   #   # 'dist type' == "id_int" then 'allow repeat values' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "allow repeat values" : true, "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: allow_repeat_values: is invalid")
#   #   # 'dist type' == "id_uuid" then 'allow repeat values' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "allow repeat values" : true, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: allow_repeat_values: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'allow repeat values' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "allow repeat values" : true, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: allow_repeat_values: is invalid")
#   # 
#   #   # dictionary
#   #   # 'dist type' == 'normal' and 'dictionary' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "dictionary" : "PATH TO DICT 1", "example_value" : 1, "mean" : 10.0, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: dictionary: is invalid")
#   #   # 'dist type' == 'random' and 'dictionary' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "dictionary" : "PATH TO DICT 1", "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: dictionary: is invalid")   
#   #   # 'dist type' == "id_int" then 'dictionary' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "dictionary" : "PATH TO DICT 1", "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: dictionary: is invalid")
#   #   # 'dist type' == "id_uuid" then 'dictionary' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "dictionary" : "PATH TO DICT 1", "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: dictionary: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'dictionary' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "dictionary" : "PATH TO DICT 1", "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: dictionary: is invalid")    
#   #   
#   #   # histogram
#   #   # 'dist type' == "histogram" requires 'histogram', field missing
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "allow repeat values" : true}!    
#   #   run_invalid_test(field_def, "histogram: histogram: missing")
#   #   # 'dist type' == "histogram" requires 'histogram', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "allow repeat values" : true, "histogram" : null}!    
#   #   run_invalid_test(field_def, "histogram: histogram: null")
#   #   # 'dist type' == "histogram" requires 'histogram', field has invalid type, valid types: Array (of JSON objects)
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "allow repeat values" : true, "histogram" : "x"}!    
#   #   run_invalid_test(field_def, "histogram: histogram: invalid type")
#   #   # 'dist type' == "histogram" requires 'histogram', field has 'min' and 'max' elements with types that don't match, types must be both Fixnum or both Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "allow repeat values" : true, "histogram" : [{"min" : 0.0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: min|max: types dont match")
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "dist_type" : "histogram", "allow repeat values" : true, "histogram" : [{"min" : 0, "max" : 1123.0, "count" : 50}, {"min" : 1124.0, "max" : 18532.0, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: min|max: types dont match")
#   #   #    
#   #   # 'dist type' == 'normal' and 'histogram' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}], "example_value" : 1, "mean" : 10.0, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: histogram: is invalid")
#   #   # 'dist type' == 'random' and 'histogram' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}], "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: histogram: is invalid")   
#   #   # 'dist type' == 'value set' and 'histogram' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}], "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: histogram: is invalid")   
#   #   # 'dist type' == "id_int" then 'histogram' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}], "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: histogram: is invalid")
#   #   # 'dist type' == "id_uuid" then 'histogram' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}], "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: histogram: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'histogram' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}], "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: histogram: is invalid")    
#   # 
#   #   # value set
#   #   # 'dist type' == "value_set" requires 'value set' or 'dictionary', both fields missing
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set"}!
#   #   run_invalid_test(field_def, "value_set: value_set: missing")
#   #   # 'dist type' == "value_set" requires 'value set' or 'dictionary', field has null value
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : null}!    
#   #   run_invalid_test(field_def, "value_set: value set: null")
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : null}!    
#   #   run_invalid_test(field_def, "value_set: dictionary: null")
#   #   # # 'dist type' == "value_set" requires 'value set' or 'dictionary', field has invalid value
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "value_set" : "x"}!    
#   #   run_invalid_test(field_def, "value_set: value_set: invalid type")
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "value_set", "dictionary" : 100}!    
#   #   run_invalid_test(field_def, "value_set: dictionary: invalid type")
#   #   #
#   #   # 'dist type' == 'normal' and 'value set' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "value_set" : [1, 2, 3, 5, 8, 13, 21], "example_value" : 1, "mean" : 10.0, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: value_set: is invalid")
#   #   # 'dist type' == 'random' and 'value set' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "value_set" : [1, 2, 3, 5, 8, 13, 21], "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: value_set: is invalid")   
#   #   # 'dist type' == "id_int" then 'value set' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "value_set" : [1, 2, 3, 5, 8, 13, 21], "dist_type" : "id_int"}!    
#   #   run_invalid_test(field_def, "id_int: value_set: is invalid")
#   #   # 'dist type' == "id_uuid" then 'value set' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "value_set" : [1, 2, 3, 5, 8, 13, 21], "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: value_set: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'value set' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "value_set" : [1, 2, 3, 5, 8, 13, 21], "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: value_set: is invalid")    
#   # 
#   #   # id int base
#   #   # 'id int base' invalid type, valid types: Fixnum
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_int", "id_int_base" : 1.0}!    
#   #   run_invalid_test(field_def, "id_int: invalid")
#   #   #
#   #   # 'dist type' == 'normal' and 'id int base' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_base" : 0, "example_value" : 1, "mean" : 10.0, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: id_int_base: is invalid")
#   #   # 'dist type' == 'random' and 'id int base' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_base" : 0, "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: id_int_base: is invalid")   
#   #   # 'dist type' == 'value set' and 'id int base' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_base" : 0, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: id_int_base: is invalid")
#   #   # 'dist type' == 'histogram' and 'id int base' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "id_int_base" : 0, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: id_int_base: is invalid")       
#   #   # 'dist type' == "id_uuid" then 'id int base' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_base" : 0, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: id_int_base: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'id int base' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_base" : 0, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: id_int_base: is invalid")    
#   # 
#   #   # id int step
#   #   # 'id int step' invalid type, valid types: Fixnum
#   #   field_def = JSON.parse %q!{"name" : "name", "dist_type" : "id_int", "id_int_step" : 1.0}!    
#   #   run_invalid_test(field_def, "dist_type: id_int_step: invalid type")
#   #   #
#   #   # 'dist type' == 'normal' and 'id int step' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_step" : 0, "example_value" : 1, "mean" : 10.0, "std_dev" : 0.25, "dist_type" : "normal"}!    
#   #   run_invalid_test(field_def, "normal: id_int_step: is invalid")
#   #   # 'dist type' == 'random' and 'id int step' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_step" : 0, "example_value" : 1, "min" : 1, "max" : 100000, "allow repeat values" : true, "dist_type" : "random"}!    
#   #   run_invalid_test(field_def, "random: id_int_step: is invalid")   
#   #   # 'dist type' == 'value set' and 'id int step' field is invalid    
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_step" : 0, "dist_type" : "value_set", "value_set" : [1, 2, 3, 5, 8, 13, 21]}!    
#   #   run_invalid_test(field_def, "value_set: id_int_step: is invalid")
#   #   # 'dist type' == 'histogram' and 'id int step' field is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "id_int_step" : 0, "dist_type" : "histogram", "histogram" : [{"min" : 0, "max" : 1123, "count" : 50}, {"min" : 1124, "max" : 18532, "count" : 53}]}!    
#   #   run_invalid_test(field_def, "histogram: id_int_step: is invalid")       
#   #   # 'dist type' == "id_uuid" then 'id int step' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_step" : 0, "dist_type" : "id_uuid"}! 
#   #   run_invalid_test(field_def, "id_uuid: id_int_step: is invalid")
#   #   # 'dist type' == "id_mongo_objid" then 'id int step' is invalid
#   #   field_def = JSON.parse %q!{"name" : "name", "id_int_step" : 0, "dist_type" : "id_mongo_objid"}! 
#   #   run_invalid_test(field_def, "id_mongo_objid: id_int_step: is invalid")    
#   # 
#   #   # nil_ratio
#   #   # 'nil_ratio' invalid type, valid types: Float
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 1, "nil_value" : -1, "nil_include_field" : false}!    
#   #   run_invalid_test(field_def, "normal: nil_ratio: invalid type")
#   #   # 'nil_ratio' invalid range, valid range: 0.0 <= x <= 1.0
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 1.01, "nil_value" : -1, "nil_include_field" : false}!    
#   #   run_invalid_test(field_def, "normal: nil_ratio: invalid range")
#   # 
#   #   # nil_include_field
#   #   # 'nil_include_field' invalid type, valid types: Boolean
#   #   field_def = JSON.parse %q!{"name" : "name", "example_value" : 1, "mean" : 1.5, "std_dev" : 0.25, "dist_type" : "normal", "nil_ratio" : 0.1, "nil_value" : -1, "nil_include_field" : "false"}!    
#   #   run_invalid_test(field_def, "normal: nil_include_field: invalid type")    
#   # end
#   
# end
