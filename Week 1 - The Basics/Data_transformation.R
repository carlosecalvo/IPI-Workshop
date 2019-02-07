library(nycflights13)
library(tidyverse)
library(dbplyr)

#Data Transformation Verbs for Dplyr
flights

#1. Filter()
#filter() allows you to subset observations based on their values.

filter(flights, month == 1, day == 1)

#This doesn't create a new object, for that you need to assign it

jan1 <- filter(flights, month == 1, day == 1)

(dec25 <- filter(flights, month == 12, day == 25)) #wrap in parenthesis to print out the results AND save them to the variable

#1.1 Comparisons

#R comparison operators: >, >=, <, <=, != (not equal), and == (equal).

filter(flights, month = 1)
#> Error: `month` (`month = 1`) must not be named, do you need `==`?

#1.2 Logical Operators

#Boolean operators: & is “and”, | is “or”, and ! is “not”.

#The following code finds all flights that departed in November or December:
  
filter(flights, month == 11 | month == 12)

#Which is not the same as 
filter(flights, month == 11 | 12) #this looks for months that equal 11 | 12    !!!!

#This could be better written with the syntax x %in% y

nov_dec <- filter(flights, month %in% c(11, 12))

#Remember De Morgan's law (the following two are the same)
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

#2. Arrange()
#arrange() works similarly to filter() except that instead of selecting rows, it changes their order. If you provide more than one column name, each additional column will be used to break ties in the values of preceding columns:

arrange(flights, year, month, day)

#desc() re-orders by a column in descending order:

arrange(flights, desc(dep_delay))

#3. Select()
#select() allows you to rapidly zoom in on a useful subset using operations based on the names of the variables.

# Select columns by name
select(flights, year, month, day)

# Select all columns between year and day (inclusive)
select(flights, year:day)

# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

#There are a number of helper functions you can use within select():
#starts_with("abc"): matches names that begin with “abc”.
#ends_with("xyz"): matches names that end with “xyz”.
#contains("ijk"): matches names that contain “ijk”.
#matches("(.)\\1"): selects variables that match a regular expression. This one matches any variables that contain repeated characters. You’ll learn more about regular expressions in strings.
#num_range("x", 1:3): matches x1, x2 and x3. See ?select for more info.

#select() can be used to rename variables, but it’s rarely useful because it drops all of the variables not explicitly mentioned. Instead, use rename()

rename(flights, tail_num = tailnum)

#4. Mutate()
#mutate() always adds new columns at the end of your dataset so we’ll start by creating a narrower dataset so we can see the new variables. Remember that when you’re in RStudio, the easiest way to see all the columns is View().

flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       speed = distance / air_time * 60
)

#Note that you can refer to columns that you’ve just created

mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)

#If you only want to keep the new variables, use transmute():

transmute(flights,
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
)

#5. Summarize()
#summarise() collapses a data frame to a single row:

summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

#summarise() is not terribly useful unless we pair it with group_by().

by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

#5.1 Pipeline
#Think about the following piece of code

by_dest <- group_by(flights, dest)
delay <- summarise(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
)
delay <- filter(delay, count > 20, dest != "HNL")

# It looks like delays increase with distance up to ~750 miles 
# and then decrease. Maybe as flights get longer there's more 
# ability to make up delays in the air?

ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

#This code is a little frustrating to write because we have to give each intermediate data frame a name, even though we don’t care about it. Naming things is hard, so this slows down our analysis. There’s another way to tackle the same problem with the pipe, %>%:

delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")

#This focuses on the transformations, not what’s being transformed, which makes the code easier to read.

#5.2 Counts
#Whenever you do any aggregation, it’s always a good idea to include either a count (n()), or a count of non-missing values (sum(!is.na(x))). For example, let’s look at the planes (identified by their tail number) that have the highest average delays:

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )

ggplot(data = delays, mapping = aes(x = delay)) + 
  geom_freqpoly(binwidth = 10)

#But the story is more nuanced, look at a scatterplot of number of flights vs average delay.

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

#Adding ggplot2 into dplyr pipes when filtering for higher delay numbers

delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

#5.4 Useful summary functions
#Measures of location: mean(x), and median(x)

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
  )

#Measures of spread: sd(x), IQR(x), mad(x).

# Why is distance to some destinations more variable than to others?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

#Measures of rank: min(x), quantile(x, 0.25), max(x).

# When do the first and last flights leave each day?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )

#Measures of position: first(x), nth(x, 2), last(x).

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first_dep = first(dep_time), 
    last_dep = last(dep_time)
  )

  #These are complementary to filtering on ranks
not_cancelled %>% 
  group_by(year, month, day) %>% 
  mutate(r = min_rank(desc(dep_time))) %>% 
  filter(r %in% range(r))

#Counts: n_distinct(x)
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

  #for a simple count
not_cancelled %>% 
  count(dest)

  #Provide a weight variable
not_cancelled %>% 
  count(tailnum, wt = distance)

#Counts and proportions of logical values
#When used with numeric functions, TRUE is converted to 1 and FALSE to 0. This makes sum() and mean() very useful: sum(x) gives the number of TRUEs in x, and mean(x) gives the proportion.

# How many flights left before 5am? (these usually indicate delayed flights from the previous day)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

# What proportion of flights are delayed by more than an hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60))

#5.5 Ungrouping

daily %>% 
  ungroup() %>%             # no longer grouped by date
  summarise(flights = n())  # all flights

#6. Grouped mutates
#Grouping is most useful in conjunction with summarise(), but you can also do convenient operations with mutate() and filter():

#Find the worst members of each group:

flights_sml %>% 
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)

#Find all groups bigger than a threshold:

popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 365)
popular_dests

#Standardize to compute per group metrics:

popular_dests %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)






