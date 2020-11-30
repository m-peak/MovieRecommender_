# Movie Recommender

A simple project on recommendation system [MovieRecommender](https://masamipeak.shinyapps.io/MovieRecommender/) for a shiny app based on the following recommendation methods.

* Choices of movie Genres
* Collaborative Filtering

Environment
-------------
* R version 4.0.0
* shiny 1.5.0
* recommenderlab 0.2-6
* dplyr_1.0.0
* Matrix_1.2-18
* RStudio Version 1.2.5042

Description
-------------
Choices of movie Genres :

Top 20 recommended movies in the user's favorite genres will be selected based on each movie that is
* Higher average rating
* More count of movie ratings
* Newer release year

UBCF Recommender Model :

Top 20 recommended movies will be selected based on User-Based Collaborative Filtering using a package recommenderlab.

Credits:
The following sources are referenced for this app.
1. [BookRecommender](https://github.com/pspachtholz/BookRecommender)
2. [Movie Images](https://liangfgithub.github.io/MovieImages/)
