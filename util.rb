class BlankGenerationConversionException < Exception; end

def date_diff_to_i(date1_str, date2_str)
  (date_s_to_i(date1_str) - date_s_to_i(date2_str)).abs
end

# NOTE: Time resolutions more granular than 1 sec are currently lost, truncated to floor in secs
# TODO: Add this to documentation  
def date_s_to_i(date_str)
  require 'time'
  
  if  not validate_date_str(date_str)
    raise BlankGenerationConversionException, "Invalid date value #{date_str}"
  end
  
 Time.parse(date_str).to_i
end

def date_i_to_s(date_i)
  Time.at(date_i).iso8601
end

def validate_date_str(s)
  return false if s.class != String
  # Based on dodcumentation here: http://www.w3.org/TR/NOTE-datetime
  
  # YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)
  # YYYY = four-digit year
  # MM   = two-digit month (01=January, etc.)
  # DD   = two-digit day of month (01 through 31)
  # hh   = two digits of hour (00 through 23) (am/pm NOT allowed)
  # mm   = two digits of minute (00 through 59)
  # ss   = two digits of second (00 through 59)
  # s    = one or more digits representing a decimal fraction of a second
  # TZD  = time zone designator (Z or +hh:mm or -hh:mm)

  (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|\.\d{2}(-|\+)\d{2}:\d{2})$/ =~ s.strip) == 0 ||
  (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(-|\+)\d{2}:\d{2}$/ =~ s.strip)== 0
end

def bool?(x)
  x.class == FalseClass || x.class == TrueClass
end