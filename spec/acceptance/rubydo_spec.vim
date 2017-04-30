Given:
  a
  b
  c
  d

Execute (Update one line using `$_`):
  2rubydo $_.upcase!

Expect:
  a
  B
  c
  d

Execute (Update a range of lines using `$_`):
  2,3rubydo $_.upcase!

Expect:
  a
  B
  C
  d

Execute (Update all lines using `$_`):
  %rubydo $_.upcase!

Execute (Raise a Ruby standard error):
  AssertThrows '1rubydo raise "BOOM"'
  1rubydo $_.replace("still works")

Expect:
  still works
  b
  c
  d

Execute (Raise a Ruby syntax error):
  AssertThrows '1rubydo puts['
  1rubydo $_.replace("still works")

Expect:
  still works
  b
  c
  d

Given:
  x

Execute (Add a large number of lines):
  1yank
  silent normal 6000p
  %rubydo $_.succ!

  AssertEqual "y", getline(1)
  AssertEqual "y", getline(6001)
  AssertEqual "", getline(6002)
