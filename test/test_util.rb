require "testutil"
$LOAD_PATH << psub("../")
require "rubygems"
require "test/unit"
require "util"

class Util_Test < Test::Unit::TestCase
  
  def test__validate_date_str
    puts "\ntest__validate_date_str ENTERED"
    
    # Based on dodcumentation here: http://www.w3.org/TR/NOTE-datetime
    # YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30+01:00)
    # YYYY = four-digit year
    # MM   = two-digit month (01=January, etc.)
    # DD   = two-digit day of month (01 through 31)
    # hh   = two digits of hour (00 through 23) (am/pm NOT allowed)
    # mm   = two digits of minute (00 through 59)
    # ss   = two digits of second (00 through 59)
    # s    = one or more digits representing a decimal fraction of a second
    # TZD  = time zone designator (Z or +hh:mm or -hh:mm)
    
    # Valid tests
    s = "1997-07-16T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(ret, "Didn't generate expected failure for YYYY")
    s = "1997-07-16T19:20:30-01:00"
    ret = validate_date_str(s)
    assert(ret, "Didn't generate expected failure for YYYY")
    s = "1997-07-16T19:20:30Z"
    ret = validate_date_str(s)
    assert(ret, "Didn't generate expected failure for YYYY")    
        
    # Invalid tests
    # Incorrect # of YYYY characters    
    s = "19978-07-16T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for YYYY")
    s = "199-07-16T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for YYYY")    
    # Incorrect # of MM characters    
    s = "1997-078-16T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for MM")
    s = "1997-0-16T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for MM")    
    # Incorrect # of DD characters    
    s = "1997-07-166T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for DD")
    s = "1997-07-1T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for DD")    
    # Missing dashes    
    s = "1997-0716T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for '-'")
    s = "199707-16T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for '-'")    
    s = "19970716T19:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for '-'")    
    # Missing T    
    s = "1997-07-1619:20:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for 'T'")
    # Missing colons    
    s = "1997-07-16T1920:30+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for ':'")
    s = "1997-07-16T19:2030+01:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for ':'")
    # Z not last character
    s = "1997-07-16T19:20:30Z5"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for 'Z'")
    # No Z and no time-zone offset    
    s = "1997-07-16T19:20:30"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for time-zone offset or 'Z'")
    # Missing +/-
    s = "1997-07-16T19:20:3001:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for '+/-'")    
    # Malformed time-zone offset
    s = "1997-07-16T19:20:30+0100"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for ':' in time-zone offset")    
    s = "1997-07-16T19:20:30+0:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for time-zone offset hours")    
    s = "1997-07-16T19:20:30+012:00"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for time-zone offset hours")    
    s = "1997-07-16T19:20:30+01:0"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for time-zone offset mins")    
    s = "1997-07-16T19:20:30+01:001"
    ret = validate_date_str(s)
    assert(! ret, "Didn't generate expected failure for time-zone offset mins")    
 
    puts "\ntest__validate_date_str COMPLETED"
  end
  
end