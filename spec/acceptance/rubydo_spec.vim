Given:
  one
  two
  three
  four

Execute (Update one line using `$_`):
  2rubydo $_.upcase!

Expect:
  one
  TWO
  three
  four

Execute (Update a range of lines using `$_`):
  2,3rubydo $_.upcase!

Expect:
  one
  TWO
  THREE
  four

Execute (Update all lines using `$_`):
  %rubydo $_.upcase!

Expect:
  ONE
  TWO
  THREE
  FOUR

Execute (Raise a Ruby standard error):
  try
    1rubydo raise "BOOM"
  catch /BOOM/
  endtry

  1rubydo $_.replace("still works")

Expect:
  still works
  two
  three
  four

Execute (Raise a Ruby syntax error):
  try
    1rubydo puts[
  catch /SyntaxError/
  endtry

  1rubydo $_.replace("still works")

Expect:
  still works
  two
  three
  four

Given:
  x

Execute (Add a large number of lines):
  1yank
  silent normal 6000p
  %rubydo $_.succ!

  AssertEqual "y", getline(1)
  AssertEqual "y", getline(6001)
  AssertEqual "", getline(6002)
