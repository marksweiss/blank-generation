## Blank Generation

_Blank Generation_ aims to be a general purpose library for generating realistic and useful test data. The library has two key design goals. 

First, it aims to provide the right set of primitives for generating data -- simple to use but flexible enough to be uses to create many different kinds of realistic distributions of data. Second, the library intends to have a simple, clear, pleasing API. If you come back to your data-generation scripts months later to add a new column and you can't quickly understand what you are looking at, you will abandon the library.

#### Using the Library

The first part of the process of creating useful test data remains the same. You do some analysis and profiling of existing data, figure out what realistic distributions of data might look like, perhaps generate some input files and static sets of code values, then use standard tools to define fields for records, and generate as many records as you need.  

_Blank Generation_ aims to provide a reusable framework for the second part of the process, creating scripts to generate the test data.  Hopefully you will be able to create data-generation scripts that you evolve and reuse, rather than writing one-offs.

You use the library by thinking of your test data as a sequence of records (a "table" of "rows" if you are creating relational data, an "array" of "documents" if you are creating document DB data) with one or more fields ("columns" for relational data, "attributes" or "keys" for document DB data). Then, think of all the data for a field for all the records (one "column" of data) as its own distribution of data.  For example, 5 records with an "ID" field containing standard sequential integer IDs starting at 0 would have the distribution _[0, 1, 2, 3, 4]_.

After defining _field generators_ for each field, you bind them to a _record generator_ and call its _generate_ method with the number of records to create.  Output is formatted using a separate _formatter_. If you don't specify any formatter then the default JSON formatter is used.  The library also includes a CSV formatter.

#### A Simple Example

To add a little more detail, imagine a customer record with the following fields:
* "CustId"
* "Name"
* "State"
* "CreatedAt"
* "MaxPurchasePrice"

Each of these, in a realistic set of test data, would contain a different type of distribution.  The "CustId" would be a sequence of integers.  The "Name" might be a random distribution from a file of real customer names.  The "State" field might be a random distribution from a fixed set of state-code values.  The "CreatedAt" might be a random distribution within a fixed start and end date.  The "MaxPurchasePrice" might be a normal distribution around a known mean and standard deviation.

The code to create this test data and return it as JSON looks like this:

```ruby
name = "CustId"
id_gen = IdFieldGenerator.new(name)
name = "Name"
path = "./namesfile.txt"
name_gen = DictionaryFieldGenerator.new(name, path)
name = "State"
values = ["NY", "NJ", "PA", "DE"]
state_gen = ValueSetFieldGenerator.new(name, values)
name = "CreatedAt"
date_type = FieldGenerator::DATE
min = "1997-07-16T19:20:30.45+01:00"
max = "1997-07-16T19:20:30.45+01:00"
created_at_gen = RandomFieldGenerator.new(name, data_type, min, max)
name = "MaxPurchasePrice"
data_type = FieldGenerator::FLOAT
mean = 20.32
std_dev_ = 8.63
max_purchase_gen = NormalFieldGenerator.new(name, data_type, mean, std_dev)
g = BlankGenerator.new
g.add_field_generators(id_gen, name_gen, state_gen, created_at_gen, max_purchase_gen)
num_records = 1000
dist = JSON.parse(g.generate(num_records))
```
Or, if you prefer, you can use a Rails-style syntax for creating generators that names arguments and eliminates all the boilerplate of defining variables to pass as constructor arguments. Much nicer:
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
#### Contributing

Creating a general-purpose library for creating test data is challenging because the breadth of possible use cases is arbitrary -- everybody has different data. There are many, many edge cases and special cases. Just having reasonable date support is a tall order.  

So, please send pull requests with improvements. Please open issues. But before you do, push the features provided as far as they can go. General tools like the _DictionaryFieldGenerator_, _ValueSetFieldGenerator_ and _HistogramFieldGenerator_ can be used to generate a wide range of data.
