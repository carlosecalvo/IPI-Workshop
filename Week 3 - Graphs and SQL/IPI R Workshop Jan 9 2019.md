IPI R Workshop: Graphs and SQL
========================================================
author: Carlos Calvo Hernandez
date: January 9, 2019
autosize: true

Prerequisites
========================================================
- We're gonna use these libraries:

```r
library(tidyverse)
library(DBI)
library(RPostgreSQL)
```



Plots? ggplot2 can help
========================================================
- What does **ggplot2** stand for? A **Grammar of Graphics**!

```r
ggplot(data = <Data>) +
  <Geom_function>(
    mapping = aes(<Mappings>),
    stat = <Stat>,
    position = <Position>
  ) +
  <Coordinate_function> +
  <Facet_function>
```


First: Working with ggplot2
========================================================
- Download and unzip the Gapminder data we are going to use.
- link: [https://monashdatafluency.github.io/r-intro-2/r-intro-2-files.zip](https://monashdatafluency.github.io/r-intro-2/r-intro-2-files.zip)

















































```
Warning message:
package 'knitr' was built under R version 3.4.4 


processing file: IPI R Workshop Jan 9 2019.Rpres
-- Attaching packages -------------------------------------------------------------------- tidyverse 1.2.1 --
v ggplot2 3.1.0     v purrr   0.2.5
v tibble  1.4.2     v dplyr   0.7.8
v tidyr   0.8.2     v stringr 1.3.1
v readr   1.2.1     v forcats 0.3.0
-- Conflicts ----------------------------------------------------------------------- tidyverse_conflicts() --
x dplyr::filter() masks stats::filter()
x dplyr::lag()    masks stats::lag()
Quitting from lines 41-45 (IPI R Workshop Jan 9 2019.Rpres) 
Error: 'r-intro-2-files/geo.csv' does not exist in current working directory ('C:/Users/bialeks/Box/R Workshop/Week 3 - Graphs and SQL').
In addition: There were 11 warnings (use warnings() to see them)
Execution halted
```
