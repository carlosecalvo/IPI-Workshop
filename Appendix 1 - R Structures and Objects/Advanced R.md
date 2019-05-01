IPI Workshop - Advanced R Structure and Objects
========================================================
author: Carlos Calvo Hernandez
date: February 13th, 2019
autosize: true

DISCLAIMER
========================================================
## This might be the absolute worst medium to teach this topic. Probably an interactive document might be better.

Prerequisites
========================================================

- I'll follow Hadley Wickham's [Advanced R](https://adv-r.hadley.nz/)
- We'll use `lobstr` and `tidyverse` to dig into the internal representation of R objects.


```r
require(tidyverse)
require(lobstr)
```


Names and values
========================================================
incremental:true

- What does this code "means"?

```r
x <- c(1, 2, 3)
```

- It reads "create an object named 'x', containing the values 1, 2, and 3".
- Unfortunately that's not really what it means to R.
- This code does two things:
  1. Creates and object, vector of values, 1, 2, 3.
  2. Binds that object to the name `x`.
  
- I.e. the object, or value, doesn't have a name. The name has a value.


Binding basics
========================================================
- The binding of names to values work in the opposite direction than the assignment arrow `<-`.
- Think of a name as a reference to a value

```r
x <- c(1, 2, 3)
#creating a new name 'y' doesn't create a new value, you only get another binding to that value.
y <- x
y
```

```
[1] 1 2 3
```

- The object is stored once, but has two different references **x** and **y**.

Binding basics (cont.)
========================================================

- This is more clear when we look at the memory "address" where the object is stored.

```r
lobstr::obj_addr(x)
```

```
[1] "0x7febeec57ad8"
```

```r
lobstr::obj_addr(y)
```

```
[1] "0x7febeec57ad8"
```


Names and values: Non-syntactic names
========================================================
- As we know there are rules to **name** objects.
  - A **syntactic** name must consist of letters, digits `.`, `_`, and must begin with a letter.
  - You can't use any **reserved words** like `TRUE`, `NULL`, etc. (See `?Reserved`)
  - A **non-syntactic** name is one that doesn't follow the above rules, and outputs an error when used.

```r
_abc <- 1
> Error: unexpected input in "_"
if <- 10
> Error: unexpected assignment in "if <-"
```

Non-syntactic names (cont.)
========================================================

- You can override these rules and use any name by surrounding it in backticks


```r
(`_abc` <- 1)
```

```
[1] 1
```

```r
(`if` <- 10)
```

```
[1] 10
```

- These types of names appear mainly in data that was created outside of **R**.


Copy-on-modify
========================================================

- The following code binds `x` and `y` to the same object and then modifies `y`.

```r
x <- c(1, 2, 3)
y <- x

y[[3]] <- 4
x
```

```
[1] 1 2 3
```
- The original object didn't change, a new one was created and rebound to `y`.
- This is called **copy-on-modify** and denotes the immutable quality of objects in **R**.
  
  
Copy-on-modify: Lists
========================================================
- The same copy-on-modify behavior as with names (i.e. variables) happens when working with lists.


```r
l1 <- list(1, 2, 3)
```

- Lists store references to values stored in memory.


```r
l2 <- l1
l2[[3]] <- 4
```
- Changing an element of a list only changes the value references by that element of the list.


Copy-on-modify: Lists (cont.)
========================================================
- The list object and its bindings are copied, but the values pointed to by the bindings are not.
- If we use `lobstr::ref()` we can see the references of each object and its local ID.


```r
lobstr::ref(l1, l2)
```

```
█ [1:0x7febf061c868] <list> 
├─[2:0x7febefd03218] <dbl> 
├─[3:0x7febefd031e0] <dbl> 
└─[4:0x7febefd031a8] <dbl> 
 
█ [5:0x7febedf58958] <list> 
├─[2:0x7febefd03218] 
├─[3:0x7febefd031e0] 
└─[6:0x7febee7a8658] <dbl> 
```


Copy-on-modify: Data frames
========================================================
- Data frames are lists of vectors, so copy-on-modify has important consequences when you modify a data frame:

```r
d1 <- data.frame(x = c(1, 5, 6), y = c(2, 4, 3))
```
- If you modify a column, **only** that column needs to be modified.

```r
d2 <- d1
d2[, 2] <- d2[, 2] * 2
```
- However, if you modify a row, every column is modified.

```r
d3 <- d1
d3[1, ] <- d3[1, ] * 3
```

Copy-on-modify: Data frames (cont.)
========================================================
- It is clearer with `lobstr::obj_addrs()`.

```r
lobstr::obj_addrs(d1)
```

```
[1] "0x7febf08528f8" "0x7febf08528a8"
```

```r
lobstr::obj_addrs(d2)
```

```
[1] "0x7febf08528f8" "0x7febefe32f08"
```

```r
lobstr::obj_addrs(d3)
```

```
[1] "0x7febf09fc928" "0x7febf09fc8d8"
```

Copy-on-modify: Character vectors
========================================================
- R actually uses a **global string pool** where each element of a character vector is a pointer to a unique string in the pool

```r
x <- c("a", "a", "abc", "d")

lobstr::ref(x, character = T)
```

```
█ [1:0x7febedfc0588] <chr> 
├─[2:0x7febe9a26f98] <string: "a"> 
├─[2:0x7febe9a26f98] 
├─[3:0x7febeeb56e58] <string: "abc"> 
└─[4:0x7febea1c1de0] <string: "d"> 
```

Object size
========================================================
- You can find out how much memory an object takes with `lobstr::obj_size()`.

```r
lobstr::obj_size(letters)
```

```
1,712 B
```

```r
lobstr::obj_size(ggplot2::diamonds)
```

```
3,456,344 B
```

Modify-in-place
========================================================
- As we’ve seen above, modifying an R object usually creates a copy. 
- There are two exceptions:

  1. Objects with a single binding get a special performance optimisation.

  2. Environments, a special type of object, are always modified in place.

Vectors
========================================================
- Vectors come in two flavours: atomic and lists.
  - Atomic vectors:
    - all elements must have the same type.
  - List vectors:
    - elements can have different types.
    
- Every vector can also has "attributes" (i.e. a named list of metadata).
- Two are particularly important:
  1. **dim**ension 
  2. **class**
  
- Important types of vectors: factors, date/times, data frames, and tibbles. 

Atomic vectors
========================================================
- Four types: logical, integer, double, and character.
  - Numeric vectors: integer and double.

- Individual value: **scalar**.

```r
dbl_var <- c(1, 2.5, 4.5)
int_var <- c(1L, 6L, 10L)
lgl_var <- c(TRUE, FALSE)
chr_var <- c("these are", "some strings")
```

- `c()` always creates atomic vectors from atomic inputs, i.e. it flattens.

```r
c(c(1, 2), c(3, 4))
```

```
[1] 1 2 3 4
```

Atomic vectors (cont.)
========================================================

- `typeof()` determines the type of a

```r
typeof(dbl_var)
```

```
[1] "double"
```

```r
typeof(int_var)
```

```
[1] "integer"
```
---
 vector

```r
typeof(lgl_var)
```

```
[1] "logical"
```

```r
typeof(chr_var)
```

```
[1] "character"
```

Vectors: Testing and coercion
========================================================

- **test** a vector with `is.*()`. (e.g. `is.character()`, `is.double()`, etc.)

- REMEMBER: Atomic vectors, all elements must be the same type.

- **Coercion order**: character → double → integer → logical.
- Example:

```r
str(c("a", 1))
```

```
 chr [1:2] "a" "1"
```

Vectors: Testing and coercion (Mathematical Functions)
========================================================
- Most functions coerce to numeric (`+`, `log`, etc.)
- Logical vectors: `TRUE` equals `1` and `FALSE` equals `0`.

```r
x <- c(FALSE, FALSE, TRUE)
as.numeric(x) 
```

```
[1] 0 0 1
```

```r
sum(x) #Total number of TRUEs
```

```
[1] 1
```

```r
mean(x) #Proportion that are TRUE
```

```
[1] 0.3333333
```


Vectors: Attributes
========================================================
- Matrices, arrays, factors, and date/time data structures are built on top af atomic vectors.
  - They have an added structure called **attributes**.
  
- Attributes: name-value pairs that attach metadata to an object.
  - `attr()` and `attributes() + structure()` retrieve and modify them.
  

```r
a <- 1:3
attr(a, "x") <- "abcdef"
attr(a, "x")
```

```
[1] "abcdef"
```

Vectors: Attributes (Examples)
========================================================

```r
attr(a, "y") <- 4:6
str(attributes(a))
```

```
List of 2
 $ x: chr "abcdef"
 $ y: int [1:3] 4 5 6
```

```r
#equivalently
a <- structure(
  1:3,
  x = "abcdef",
  y = 4:6
)
str(attributes(a))
```

```
List of 2
 $ x: chr "abcdef"
 $ y: int [1:3] 4 5 6
```

Vectors: Attributes - Names
========================================================
- There are only two attributes that are routinely preserved: **names** and **dim**.
- Three ways to name a vector:

```r
# When creating it: 
x <- c(a = 1, b = 2, c = 3)

# By assigning a character vector to names()
x <- 1:3
names(x) <- c("a", "b", "c")

# Inline, with setNames():
x <- setNames(1:3, c("a", "b", "c"))
```

- Remove **names** by using `unname(x)` or `names(x) <- NULL`.

Vectors: Attributes - Dimensions
========================================================
- Adding `dim` attribute to a vector allows it to behave like a 2-dimensional matrix or a multidimensional array.

```r
# Two scalar arguments specify row and column sizes
a <- matrix(1:6, nrow = 2, ncol = 3)
a
```

```
     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6
```

Vectors: Attributes - Dimensions (cont.)
========================================================

```r
# One vector argument to describe all dimensions
b <- array(1:12, c(2, 3, 2))
b
```

```
, , 1

     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6

, , 2

     [,1] [,2] [,3]
[1,]    7    9   11
[2,]    8   10   12
```

Vectors: Attributes - Dimensions (cont.)
========================================================


```r
# You can also modify an object in place by setting dim()
c <- 1:6
dim(c) <- c(3, 2)
c
```

```
     [,1] [,2]
[1,]    1    4
[2,]    2    5
[3,]    3    6
```

Vectors: Attributes - Dimensions (cont.)
========================================================
- Functions for vectors, matrices, and arrays.

|Vector |	Matrix	| Array |
|------:|--------:|------:|
|names() |	rownames(), colnames()	| dimnames() |
|length() |	nrow(), ncol() |	dim() |
|c() |	rbind(), cbind() |	abind::abind() |
|—	| t()	| aperm() |
|is.null(dim(x)) |	is.matrix()	| is.array() |


- Vector without `dim` is not 1-dimensional, it has `NULL` dimension.
- There are matrices with a single row or single column, or arrays with a single dimension.

Vectors: Attributes - Dimensions (cont.)
========================================================
- 

```r
str(1:3)                    # 1d vector
```

```
 int [1:3] 1 2 3
```

```r
str(matrix(1:3, ncol = 1))  # column vector
```

```
 int [1:3, 1] 1 2 3
```
---
- 

```r
str(matrix(1:3, nrow = 1))  # row vector
```

```
 int [1, 1:3] 1 2 3
```

```r
str(array(1:3, 3))          # "array" vector
```

```
 int [1:3(1d)] 1 2 3
```

Vectors: Lists
========================================================
- Elements can be any time, not just vectors.

```r
l1 <- list(
  1:3, 
  "a", 
  c(TRUE, FALSE, TRUE), 
  c(2.3, 5.9)
)
typeof(l1)
```

```
[1] "list"
```


Vectors: Lists (cont.)
========================================================

```r
str(l1)
```

```
List of 4
 $ : int [1:3] 1 2 3
 $ : chr "a"
 $ : logi [1:3] TRUE FALSE TRUE
 $ : num [1:2] 2.3 5.9
```

Vectors: Lists (cont.)
========================================================
- Remember: elements of a list are references to objects, not the objects themselves.

```r
lobstr::obj_size(mtcars)
```

```
7,208 B
```

```r
l2 <- list(mtcars, mtcars, mtcars, mtcars)
lobstr::obj_size(l2)
```

```
7,288 B
```

Vectors: Lists (cont.)
========================================================
- Lists are **recursive**, they can contain other lists.

```r
l3 <- list(list(list(1)))
str(l3)
```

```
List of 1
 $ :List of 1
  ..$ :List of 1
  .. ..$ : num 1
```

Vectors: Lists with c()
========================================================

```r
l4 <- list(list(1, 2), c(3, 4))
l5 <- c(list(1, 2), c(3, 4))
str(l4)
```

```
List of 2
 $ :List of 2
  ..$ : num 1
  ..$ : num 2
 $ : num [1:2] 3 4
```

```r
str(l5)
```

```
List of 4
 $ : num 1
 $ : num 2
 $ : num 3
 $ : num 4
```

Vectors: Testing and Coercing Lists
========================================================

```r
list(1:3)
```

```
[[1]]
[1] 1 2 3
```

```r
as.list(1:3)
```

```
[[1]]
[1] 1

[[2]]
[1] 2

[[3]]
[1] 3
```

Vectors: Matrices and arrays of lists
========================================================
- `dim` creates list-matrices or list-arrays

```r
l <- list(1:3, "a", TRUE, 1.0)
dim(l) <- c(2,2)
l
```

```
     [,1]      [,2]
[1,] Integer,3 TRUE
[2,] "a"       1   
```

```r
l[[1,1]]
```

```
[1] 1 2 3
```

Data frames and tibbles
========================================================
- Data frames are named lists of vectors with attributes for `names`, `row.names`, and `class`.

```r
df1 <- data.frame(x = 1:3, y = letters[1:3])
typeof(df1)
```

```
[1] "list"
```

```r
attributes(df1)
```

```
$names
[1] "x" "y"

$class
[1] "data.frame"

$row.names
[1] 1 2 3
```

Data frames: Attributes
========================================================
- Length of each of its vectors must be the same.
- has `rownames()` and `colnames()`. The `names()` of a data frame are the column names.
- has `nrow()` rows and `ncol()` columns. The `length()` of a data frame gives the number of columns.


- The 20+ years history of R makes the data frame structure somewhat frustrating. Thst's where tibbles come in.

Tibbles
========================================================
- Tibbles are designed to be drop-in replacements for data frames that (try to) fix those frustrations.
- Quoting Hadley Wickham "...tibbles are lazy and surly: they do less and complain more."
- Tibbles are provided by the **tibble** package and share the same structure as data frames.
- The only difference is that the class vector is longer, and includes `tbl_df`.

Tibbles (cont.)
========================================================

```r
library(tibble)

df2 <- tibble(x = 1:3, y = letters[1:3])
typeof(df2)
```

```
[1] "list"
```

```r
attributes(df2)
```

```
$names
[1] "x" "y"

$row.names
[1] 1 2 3

$class
[1] "tbl_df"     "tbl"        "data.frame"
```

Data frames and tibbles: Creation
========================================================

```r
df <- data.frame(
  x = 1:3, 
  y = c("a", "b", "c")
)
str(df)
```

```
'data.frame':	3 obs. of  2 variables:
 $ x: int  1 2 3
 $ y: Factor w/ 3 levels "a","b","c": 1 2 3
```


Data frames and tibbles: Creation (cont.)
========================================================
- Data frames convert by default strings to factors.

```r
df1 <- data.frame(
  x = 1:3,
  y = c("a", "b", "c"),
  stringsAsFactors = FALSE
)
str(df1)
```

```
'data.frame':	3 obs. of  2 variables:
 $ x: int  1 2 3
 $ y: chr  "a" "b" "c"
```

Data frames and tibbles: Creation (cont.)
========================================================
- Tibbles never coerce their input (lazy).

```r
df2 <- tibble(
  x = 1:3, 
  y = c("a", "b", "c")
)
str(df2)
```

```
Classes 'tbl_df', 'tbl' and 'data.frame':	3 obs. of  2 variables:
 $ x: int  1 2 3
 $ y: chr  "a" "b" "c"
```

Data frames and tibbles: Names
========================================================

```r
names(data.frame(`1` = 1))
```

```
[1] "X1"
```

```r
names(tibble(`1` = 1))
```

```
[1] "1"
```

Data frames and tibbles: Lengths
========================================================

```r
data.frame(x = 1:4, y = 1:2)
```

```
  x y
1 1 1
2 2 2
3 3 1
4 4 2
```

```r
data.frame(x = 1:4, y = 1:3)

> Error in data.frame(x = 1:4, y = 1:3):
>   arguments imply differing number of rows: 4, 3
```
---

```r
tibble(x = 1:4, y = 1)
```

```
# A tibble: 4 x 2
      x     y
  <int> <dbl>
1     1     1
2     2     1
3     3     1
4     4     1
```


Data frames and tibbles: Lengths (cont.)
========================================================

```r
tibble(x = 1:4, y = 1:2)
> Error: Tibble columns must have consistent lengths, only values of length one are recycled:
> * Length 2: Column `y`
> * Length 4: Column `x`
> Backtrace:
>     █
>  1. └─tibble::tibble(x = 1:4, y = 1:2)
>  2.   └─tibble:::lst_to_tibble(xlq$output, .rows, .name_repair, lengths = xlq$lengths)
>  3.     └─tibble:::recycle_columns(x, .rows, lengths)
```

Tibbles: Final difference from Df
========================================================
- `tibble()` allows you to refer to variables created during construction.

```r
tibble(
  x = 1:3,
  y = x * 2
)
```

```
# A tibble: 3 x 2
      x     y
  <int> <dbl>
1     1     2
2     2     4
3     3     6
```

Data frames and tibbles: Row names
========================================================
- Data frames allow you to label each row with a “name”

```r
df3 <- data.frame(
  age = c(35, 27, 18),
  hair = c("blond", "brown", "black"),
  row.names = c("Bob", "Susan", "Sam")
)
df3
```

```
      age  hair
Bob    35 blond
Susan  27 brown
Sam    18 black
```


Data frames and tibbles: Row names (cont.)
========================================================
- You can get and set row names with rownames()

```r
rownames(df3)
```

```
[1] "Bob"   "Susan" "Sam"  
```

```r
df3["Bob", ]
```

```
    age  hair
Bob  35 blond
```

Data frames and tibbles: Row names (cont.)
========================================================
incremental:true
- Row names arise naturally if you think of data frames as 2D structures like matrices: columns (variables) have names so rows (observations) should too.
- PROBLEM: Matrices are transposable. Data frames are not.
- There are three reasons why row names are undesirable:
  - Metadata is data, so storing it in a different way to the rest of the data is fundamentally a bad idea.
  - Row names are a poor abstraction for labelling rows because they only work when a row can be identified by a single string.
  - Row names must be unique, so any duplication of rows (e.g. from bootstrapping) will create new row names.
  
Data frames and tibbles: Row names (cont.)
========================================================
- Tibbles do not support row names. The tibble package easily converts row names into a regular column with either `rownames_to_column()`, or the `rownames` argument in `as_tibble()`.

```r
as_tibble(df3, rownames = "name")
```

```
# A tibble: 3 x 3
  name    age hair 
  <chr> <dbl> <fct>
1 Bob      35 blond
2 Susan    27 brown
3 Sam      18 black
```

Data frames and tibbles: Printing
========================================================

```r
dplyr::starwars
```

```
# A tibble: 87 x 13
   name  height  mass hair_color skin_color eye_color birth_year gender
   <chr>  <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> 
 1 Luke…    172    77 blond      fair       blue            19   male  
 2 C-3PO    167    75 <NA>       gold       yellow         112   <NA>  
 3 R2-D2     96    32 <NA>       white, bl… red             33   <NA>  
 4 Dart…    202   136 none       white      yellow          41.9 male  
 5 Leia…    150    49 brown      light      brown           19   female
 6 Owen…    178   120 brown, gr… light      blue            52   male  
 7 Beru…    165    75 brown      light      blue            47   female
 8 R5-D4     97    32 <NA>       white, red red             NA   <NA>  
 9 Bigg…    183    84 black      light      brown           24   male  
10 Obi-…    182    77 auburn, w… fair       blue-gray       57   male  
# … with 77 more rows, and 5 more variables: homeworld <chr>,
#   species <chr>, films <list>, vehicles <list>, starships <list>
```

Data frames and tibbles: Subsetting
========================================================
- Tibbles always return a tibble with "[ ]" and "$" doesn't do partial matching (i.e. surly).

```text
df1 <- data.frame(xyz = "a")
df2 <- tibble::tibble(xyz = "a")

str(df1$x)
```

```
 Factor w/ 1 level "a": 1
```

```text
str(df2$x)
> Warning: Unknown or uninitialised column: 'x'.
>  NULL
```

Data frames and tibbles: Testing and coercing
========================================================

```r
is.data.frame(df1)
```

```
[1] TRUE
```

```r
is.data.frame(df2)
```

```
[1] TRUE
```

```r
is_tibble(df1)
```

```
[1] FALSE
```

```r
is_tibble(df2)
```

```
[1] TRUE
```

Data frames and tibbles: List columns
========================================================
- A data frame can have a column that is a list.
- Useful: Lists can contain any other object.

```r
df <- data.frame(x = 1:3)
df$y <- list(1:2, 1:3, 1:4)

data.frame(
  x = 1:3, 
  y = I(list(1:2, 1:3, 1:4))
)
```

```
  x          y
1 1       1, 2
2 2    1, 2, 3
3 3 1, 2, 3, 4
```

Data frames and tibbles: List columns
========================================================

```r
tibble(
  x = 1:3, 
  y = list(1:2, 1:3, 1:4)
)
```

```
# A tibble: 3 x 2
      x y        
  <int> <list>   
1     1 <int [2]>
2     2 <int [3]>
3     3 <int [4]>
```

NULL structure
========================================================
- Always length zero and can't have any attributes.

```r
typeof(NULL)
```

```
[1] "NULL"
```

```r
length(NULL)
```

```
[1] 0
```

```r
x <- NULL
attr(x, "y") <- 1

> Error in attr(x, "y") <- 1:
>   attempt to set an attribute on NULL
```

Subsetting operators
========================================================
- There are three subsetting operators [[, [, and $.
- They interact differently with the different vector types.


  - **[**: selects any number of elements from a vector.
  - **[[**: extracts a single item.
  - **x$y**: shorthand for `x[["y"]]`.
  
Selecting multiple elements: Vectors
========================================================

```r
x <- c(2.1, 4.2, 3.3, 5.4)
x[c(3, 1)] # Positive integers return the elements at that position
```

```
[1] 3.3 2.1
```

```r
x[c(1, 1)] # Duplicate indices will duplicate values
```

```
[1] 2.1 2.1
```

```r
x[c(2.1, 2.9)] # Real numbers are silently truncated to integers
```

```
[1] 4.2 4.2
```

Selecting multiple elements: Vectors
========================================================

```r
x[-c(3, 1)] # Negative integers exclude elements at the specified positions
```

```
[1] 4.2 5.4
```

```r
x[c(TRUE, TRUE, FALSE, FALSE)] # Logical vectors select elements where the value is TRUE
```

```
[1] 2.1 4.2
```

```r
x[x > 3]
```

```
[1] 4.2 3.3 5.4
```

Selecting multiple elements: Recycling rules
========================================================

```r
x[c(TRUE, FALSE)]
```

```
[1] 2.1 3.3
```

```r
# Equivalent to
x[c(TRUE, FALSE, TRUE, FALSE)]
```

```
[1] 2.1 3.3
```

Selecting multiple elements: Named vectors
========================================================

```r
(y <- setNames(x, letters[1:4]))
```

```
  a   b   c   d 
2.1 4.2 3.3 5.4 
```

```r
y[c("d", "c", "a")]
```

```
  d   c   a 
5.4 3.3 2.1 
```

```r
y[c("a", "a", "a")] # Like integer indices, you can repeat indices
```

```
  a   a   a 
2.1 2.1 2.1 
```

Selecting multiple elements: Named vectors
========================================================

```r
z <- c(abc = 1, def = 2) # When subsetting with [, names are always matched exactly
z[c("a", "d")]
```

```
<NA> <NA> 
  NA   NA 
```
- All these work the same for lists.

Selecting multiple elements: Matrices
========================================================
-

```r
a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")
a[1:2, ]
```

```
     A B C
[1,] 1 4 7
[2,] 2 5 8
```
---
-

```r
a[c(TRUE, FALSE, TRUE), c("B", "A")]
```

```
     B A
[1,] 4 1
[2,] 6 3
```

```r
a[0, -2]
```

```
     A C
```

Selecting multiple elements: Data frames and tibbles
========================================================
- Data frames have the characteristics of both lists and matrices:

  - When subsetting with a single index, they behave like lists and index the columns.
    - df[1:2] selects the first two columns.

  - When subsetting with two indices, they behave like matrices.
    - df[1:3, ] selects three rows and all the columns.
    
Selecting multiple elements: Data frames
========================================================
--


```r
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])

df[df$x == 2, ]
```

```
  x y z
2 2 2 b
```

```r
df[c(1, 3), ]
```

```
  x y z
1 1 3 a
3 3 1 c
```
---
-

```r
# Selecting columns
df[c("x", "z")]
```

```
  x z
1 1 a
2 2 b
3 3 c
```

```r
df[, c("x", "z")]
```

```
  x z
1 1 a
2 2 b
3 3 c
```


Selecting multiple elements: Data frames
========================================================
- There's an important difference if you select a single column: matrix subsetting simplifies by default, list subsetting does not.

```r
str(df["x"])
```

```
'data.frame':	3 obs. of  1 variable:
 $ x: int  1 2 3
```

```r
str(df[, "x"])
```

```
 int [1:3] 1 2 3
```

Selecting multiple elements: Tibbles
========================================================

```r
df <- tibble::tibble(x = 1:3, y = 3:1, z = letters[1:3])

str(df["x"])
```

```
Classes 'tbl_df', 'tbl' and 'data.frame':	3 obs. of  1 variable:
 $ x: int  1 2 3
```

```r
str(df[, "x"])
```

```
Classes 'tbl_df', 'tbl' and 'data.frame':	3 obs. of  1 variable:
 $ x: int  1 2 3
```

Selecting and single element
========================================================
- "If list x is a train carrying objects, then x[[5]] is the object in car 5; x[4:6] is a train of cars 4-6." [@RLangTip](https://twitter.com/RLangTip/status/268375867468681216)

```r
(x <- list(1:3, "a", 4:6))
```

```
[[1]]
[1] 1 2 3

[[2]]
[1] "a"

[[3]]
[1] 4 5 6
```

Selecting and single element: [ ]
========================================================

```r
x[1] # Creating a smaller train from car 1.
```

```
[[1]]
[1] 1 2 3
```

```r
x[[1]] # Objects in car 1.
```

```
[1] 1 2 3
```

Selecting and single element: $
========================================================
- `x$y` is roughly equivalent to `x[["y"]]`
- important difference between `$` and `[[` is that `$` does (left-to-right) partial matching

```r
x <- list(abc = 1)
x$a
```

```
[1] 1
```

```r
x[["a"]]
```

```
NULL
```
- Tibbles never do partial matching.

Selecting and single element: $
========================================================
- Summary of errors when subsetting vectors and lists with zero-length objects, out-of-bounds values (OOB), or a missing value

| `row[[col]]` | Zero-length | OOB (int)  | OOB (chr) | Missing  |
|--------------|-------------|------------|-----------|----------|
| Atomic       | Error       | Error      | Error     | Error    |
| List         | Error       | Error      | `NULL`    | `NULL`   |
| `NULL`       | `NULL`      | `NULL`     | `NULL`    | `NULL`   |

- This inconsistencies led to `purrr::pluck()` and `purrr::chuck()`.
  - When the element is missing `pluck()`returns `NULL`.
  - `chuck()`returns an error.
  
Selecting and single element: Purrr
========================================================

```r
x <- list(
  a = list(1, 2, 3),
  b = list(3, 4, 5)
)
purrr::pluck(x, "a", 1)
```

```
[1] 1
```

```r
purrr::pluck(x, "c", 1)
```

```
NULL
```

```r
purrr::pluck(x, "c", 1, .default = NA)
```

```
[1] NA
```


Need more?
========================================================
- This is just a minor introduction to the logic and structures behind R's base language. Evolution and development of other packages have adapted some structures to work in different ways.
- Most of the information contained here comes from [Advanced R](https://adv-r.hadley.nz/) by Hadley Wickham.
- As always, more examples and techniques for data analysis exist in another Hadley Wickham book [R for Data Science](http://r4ds.had.co.nz/).
