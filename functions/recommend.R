# ============================================================
# Recommend
# ============================================================
library(recommenderlab)
library(Matrix)
library(dplyr)

# ratingMatrix
create_rmat = function(train) {
  i <- paste0('u', train$UserID)
  j <- paste0('m', train$MovieID)
  x <- train$Rating
  tmp <- data.frame(i, j, x, stringsAsFactors = TRUE)
  rmat <- sparseMatrix(as.integer(tmp$i), as.integer(tmp$j), x = tmp$x)
  rmat <- rmat[unique(summary(rmat)$i), ] # remove users with no ratings
  rownames(rmat) <- levels(tmp$i)
  colnames(rmat) <- levels(tmp$j)
  rmat
}

# Load rmat manually
load_rmat = function() {
  # Ratings Data ('NULL' = skip non-integer columns)
  myurl <- "https://masamipeak.shinyapps.io/MovieRecommender/data/"
  ratings <- read.csv(paste0(myurl, 'ratings.dat?raw=true'), sep = ':', colClasses = c('integer', 'NULL'), header = FALSE)
  colnames(ratings) <- c('UserID', 'MovieID', 'Rating', 'Timestamp')
  create_rmat(ratings)
}

# UBCF Algorithm ('train')
build_ubcf = function(rmat) {
  Recommender(rmat, method = 'UBCF', parameter = list(method = 'cosine', nn = 25, normalize = 'Z-score'))
}

# IBCF Algorithm ('train')
build_ibcf = function(rmat) {
  Recommender(rmat, method = 'IBCF', parameter = list(method = 'cosine', k = 30, normalize = 'Z-score', normalize_sim_matrix = FALSE, alpha = 0.5, na_as_zero = FALSE))
}

# Prediction ('known')
# type='ratingMatrix': original + predicted, type='ratings': predicted, n=n: top-N
predict_ratings = function(algo, rmat) {
  predict(algo, rmat, type='ratingMatrix')
}

# Predict Collaborative Filtering (CF)
predict_cf = function(train, known, algo_name = 'ubcf') {
  if (algo_name == 'ubcf') {
    algo <- build_ubcf(train)
  } else if (algo_name == 'ibcf') {
    algo <- build_ibcf(train)
  }
  predict_ratings(algo, known)
}

# Results of Collaborative Filtering (CF) (Top20)
get_user_results = function(res, avg_rating, movies, top_n = 20) {
  mat <- as(res, 'dgCMatrix')
  dimnames(mat) <- list(rownames(res), colnames(res))
  mat[1, ] <- sapply(mat[1, ], function(x) ifelse(x == 0, avg_rating, x)) # missings = avg_rating
  user_predicted_ratings <- sort(mat[1, ], decreasing = TRUE)[1:top_n]
  user_predicted_ids <- as.numeric(gsub('m', '', names(user_predicted_ratings)))
  
  df = as.data.frame(matrix(user_predicted_ids, nrow=top_n, ncol=1))
  colnames(df) <- c('MovieID')
  df$MovieID <- as.vector(as.matrix(user_predicted_ids))
  df$Title <- sapply(user_predicted_ids, function(x) movies[which(movies$MovieID == x), ]$Title)
  df$Year <- sapply(user_predicted_ids, function(x) movies[which(movies$MovieID == x), ]$Year)
  df$Rating <- as.vector(user_predicted_ratings)
  df$image_url <- sapply(user_predicted_ids, function(x) movies[which(movies$MovieID == x), ]$image_url)
  df
}

# Sort Dataset by Genres
sort_dataset = function(df, gs, top_n = 20) {
  df$Temp = df[[gs[1]]]
  for (i in 2:length(gs)) {
    df$Temp <- df$Temp + df[[gs[i]]]
  }
  df[order(-df$Temp, -df$Year), ][1:top_n, ] %>%
    select(c('MovieID', 'Title', 'Year', all_of(gs)))
}

# Sorted and Sampled MovieIDs
get_sorted_ids = function(df, gs, top_n = 120, rate = 4) {
  ds <- sort_dataset(df, gs, top_n * rate)
  sample(nrow(ds), floor(nrow(ds)/rate))
}
