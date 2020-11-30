# ============================================================
# Server
# ============================================================
# Load functions
source('functions/funcs.R')
source('functions/recommend.R') # collaborative filtering & genre filtering

# Read in data
movies <- read.table('data/movies.tsv', stringsAsFactors=FALSE, header=TRUE)
movies$image_url <- sapply(movies$MovieID, function(x) paste0(small_image_url, x, '.jpg?raw=true'))
rdf <- read.table('data/rdf.tsv', stringsAsFactors=FALSE, header=TRUE)
rmat <- read.table('data/rmat.tsv', stringsAsFactors=FALSE, header=TRUE)
rmat <- as(as.matrix(rmat), 'sparseMatrix')
avg_rating <- mean(tapply(rmat@x,col(rmat)[(!rmat==0)@x],mean))
ubcf <- readRDS('data/ubcf.rds')

shinyServer(function(input, output, session) {
  observe({
    check_genres(input)
  })
  
  observeEvent(input$method, {
    display_filters(input, session)
    display_user_results(FALSE)
  })
  
  observeEvent(input$btn, {
    # Enable to display user_results
    display_user_results(TRUE)
  })
  
  # Show the movies to be rated (Systsem II (collaborative recommendation))
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    ids <- get_sorted_ids(rdf, genres)
    mvs <- movies[ids, ]
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        index = (i - 1) * num_movies + j
        list(box(width = 2,
                 div(style = 'text-align:center', img(src = mvs$image_url[index], height = 150)),
                 div(style = 'text-align:center', strong(mvs$Title[index])),
                 div(style = 'text-align:center; font-size: 150%; color: #f0ad4e;', ratingInput(paste0('select_', mvs$MovieID[index]), label = '', dataStop = 5)))) #00c0ef
      })))
    })
  })
  
  # Calculate recommendations when the sbumbutton is clicked
  df <- eventReactive(input$btn, {
    withBusyIndicatorServer('btn', { # showing the busy indicator
        
        # Recommendation Method 1 (Systsem I (recommendation based on genres))
        if (input$method == 1) {
          # Get the user's genres
          user_genres <- get_user_genres(input)
          user_results <- sort_dataset(rdf, user_genres)
          user_results$image_url <- sapply(user_results$MovieID, function(x) movies[which(movies$MovieID == x), ]$image_url)
          
        # Recommendation Method 2 (Systsem II (collaborative recommendation))
        } else if (input$method == 2) {
          # Get the user's rating data
          value_list <- reactiveValuesToList(input)
          user_ratings <- get_user_ratings(value_list, ncol(rmat))
          
          # User's ratings as a row of a rating matrix
          rrmat <- as(user_ratings, 'realRatingMatrix')
          res <- predict_ratings(ubcf, rrmat)[1]
          
          # Alternative way
          #rrmat <- rbind(user_ratings, rmat)
          #rrmat <- as(rrmat, 'realRatingMatrix')
          #res <- predict_cf(rrmat, rrmat[1])[1]

          user_results <- get_user_results(res, avg_rating, movies)
        }
        user_results
    }) # still busy
  }) # clicked on button

  # Display the recommendations
  output$results <- renderUI({
    num_rows <- 4
    num_movies <- 5
    user_results <- df()
    
    div(id = 'user_results', class = 'user-results',
      lapply(1:num_rows, function(i) {
        list(fluidRow(lapply(1:num_movies, function(j) {
          index = (i - 1) * num_movies + j
          #rating = ifelse('Rating' %in% colnames(user_results), paste0(' (', round(user_results$Rating, digits=0), ')'), '')
          box(width = 2, status = 'success', solidHeader = TRUE, title = paste0('Rank ', index),
            div(style = 'text-align:center',
                a(img(src=user_results$image_url[index], height = 150))),
            div(style = 'text-align:center; font-size: 100%',
                strong(user_results$Title[index])))        
        }))) # columns
      }) # rows
    )
  }) # renderUI function
}) # server function
