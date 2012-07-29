## Blank Generation

#### Overview

_Blank Generation_ aims to be a general purpose library for generating realistic and useful test data. The library has two key design goals. 

First, it aims to provide the right set of primitives for generating data -- simple to use but flexible enough to be used to create many different kinds of realistic data sets. Second, the library intends to have a simple, clear, pleasing API. If you come back to your data-generation scripts months later to add a new column and you can't quickly understand what you are looking at, you will abandon the library.

#### Using the Library

The first part of the process of creating useful test data remains the same. You perform analysis and profiling of existing data, figure out what realistic distributions of data might look like, and perhaps generate some input files and static sets of code values.  

_Blank Generation_ aims to provide a reusable framework for the second part of the process, creating scripts to generate the test data. The goal is for you to be able to create data-generation scripts that you maintain and continue to use along with the rest of your code base, rather than writing one-offs every time you need new test data.

You use the library by thinking of your data as a sequence of records with each record containing values for one or more fields (a table of rows with columns for relational data, an array of documents with attributes for document DB data, an array of key/value pairs for KV stores). Next, think of all the data for a field in a set of records as its own distribution. To provide a trivial example, 5 records with a sequential integer "ID" field could have the distribution _[0, 1, 2, 3, 4]_.

#### Field Generators

After deciding what distribution of data you need for each field in a record, you use _Field Generators_ to generate data for each field. The available _Field Generators_ are the primitives provided by the library to let you generate test data in a standard way.  The goal is to provide the right set of tool that cover many common use cases and also offer flexibility to let you handle your particular data details.

The following _Field Generators_ are provided:

* _NormalFieldGenerator_
    * Generate a normal distribution of Integer, Float or Date data.
* _RandomFieldGenerator_
    * Generate a random distribution of Integer, Float or Date data.
* _StringFieldGenerator_
    * Generate a random string with control over the min string length, max string length, minimum number of string tokens, max number of string tokens, token delimiter and alphabet.
* _ValueSetFieldGenerator_
    * Generate a random distribution drawn from a fixed set of values provided. Values can be any type. Useful for fields using a fixed set of values, such as zip codes, state codes, etc.
* _DictionaryFieldGenerator_
    * Generate a random distribution drawn from a fixed set of String values loaded in from a file. Similar to the value set, but lets you store and manage large sets of values in separate input files.
* _HistogramFieldGenerator_
    * Generate arbitrary histogram distributions. You specify "buckets" in the histogram, and for each bucket you specify it's share of the total and provide a _NormalFieldGenerator_, _RandomFieldGenerator_, _ValueSetFieldGenerator_ or _DictionaryFieldGenerator_. This lets you design a wide variety of distributions. 
* _IdFieldGenerator_
    * Generate sequential integer values, starting at 0 and incrementing by 1, or with a specified base value and a specified increment value.
* _IdUuidFieldGenerator_
    * Generate UUID values.

#### Generating and Formatting Results

After defining generators for each field, you bind them to a _BlankGeneration_ record generator object and call its _generate_ method with the number of records to generate.

Output is formatted using a separate _Formatter_. If you don't specify any formatter then the default JSON formatter is used.  The library also includes a CSV formatter.

#### An Example

To get a feel for using _BlankGeneration_, let's use it to generate data for a simple but fairly realistic example:

* CustomerMaxPurchase
    * "CustId"
    * "Name"
    * "State"
    * "CreatedAt"
    * "MaxPurchasePrice"

In a realistic set of test data, each of these fields would contain a different distribution of values.  The "CustId" would be a sequence of integers.  The "Name" might be a random distribution from a file of real customer names.  The "State" field might be a random distribution from a fixed set of state-code values.  The "CreatedAt" might be a random distribution within a fixed start and end date.  The "MaxPurchasePrice" might be a normal distribution around a known mean and standard deviation. 

Here is the code to create this test data and return it as JSON, using Rails-style syntax for creating generators:

```ruby
id_gen = IdFieldGenerator.new :name => "CustId"
name_gen = DictionaryFieldGenerator.new :name => "Name", :path => "./namesfile.txt"
state_gen = ValueSetFieldGenerator.new :name => "State", :values => ["NY", "NJ", "PA", "DE"]
created_at_gen = RandomFieldGenerator.new :name => "CreatedAt", :data_type => FieldGenerator::DATE, :min => "1997-07-16T19:20:30.45+01:00", :max => "1997-07-16T19:20:30.45+01:00"
max_purchase_gen = NormalFieldGenerator.new :name => "MaxPurchasePrice", :data_type => FieldGenerator::FLOAT, :mean => 20.32, :std_dev => 8.63
g = BlankGenerator.new
g.add_field_generators(id_gen, name_gen, state_gen, created_at_gen, max_purchase_gen)
num_records = 1000
dist = JSON.parse(g.generate(num_records))
```

#### A Slightly More Elaborate Example

Now let's expand the example a bit to show the flexibility of the _HistogramFieldGenerator_. Let's say your max purchase data actually comes from three sales regions, each with a known mean and standard deviation.  Further, let's assume the "East" region contributes half of total sales, and the "Central" and "West" regions one quarter each.  We could use a histogram generator to generate this distribution:

```ruby
# ...
# ...
# Leaving out declarations of the other fields, same as previous example
# ...
# Define the Histogram Generator
max_purchase_gen = HistogramFieldGenerator.new :name => "MaxPurchasePrice", :hist_type => HistogramFieldGenerator::HIST_TYPE_NORMAL
# Define the bucket generators, each is a Normal generator filling part of the Histogram's distribution
max_purchase_east_gen = NormalFieldGenerator.new :name => "MaxPurchasePriceEast", :data_type => FieldGenerator::FLOAT, :mean => 20.32, :std_dev => 8.63
share = 0.5
hist_gen.add_bucket_generator(share, max_purchase_east_gen)
max_purchase_central_gen = NormalFieldGenerator.new :name => "MaxPurchasePriceCentral", :data_type => FieldGenerator::FLOAT, :mean => 18.19, :std_dev => 5.84
share = 0.25
hist_gen.add_bucket_generator(share, max_purchase_central_gen)
max_purchase_west_gen = NormalFieldGenerator.new :name => "MaxPurchasePriceWest", :data_type => FieldGenerator::FLOAT, :mean => 16.26, :std_dev => 4.17
hist_gen.add_bucket_generator(share, max_purchase_west_gen)
g = BlankGenerator.new
g.add_field_generators(id_gen, name_gen, state_gen, created_at_gen, max_purchase_gen)
num_records = 1000
dist = JSON.parse(g.generate(num_records))
```

#### Contributing

Creating a general-purpose library for creating test data is challenging because the breadth of possible use cases is arbitrary -- everybody has different data. There are many, many edge cases and special cases. Just having reasonable date support is a tall order.  

So, please send pull requests with improvements. Please open issues. But before you do, push the features provided as far as they can go. General tools like the _DictionaryFieldGenerator_, _ValueSetFieldGenerator_ and _HistogramFieldGenerator_ can be used to generate a wide range of data.
