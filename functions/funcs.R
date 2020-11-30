# ============================================================
# Functions
# ============================================================
library(Matrix)

# Constants
small_image_url <- "https://liangfgithub.github.io/MovieImages/"
genres <- c('Action',
            'Adventure',
            'Animation',
            'Children.s',
            'Comedy',
            'Crime',
            'Documentary',
            'Drama',
            'Fantasy',
            'Film.Noir',
            'Horror',
            'Musical',
            'Mystery',
            'Romance',
            'Sci.Fi',
            'Thriller',
            'War',
            'Western')

# Functions
get_user_genres = function(input) {
  genre_ids <- as.integer(c(
    {input$checkGroup1},
    {input$checkGroup2},
    {input$checkGroup3},
    {input$checkGroup4},
    {input$checkGroup5},
    {input$checkGroup6},
    {input$checkGroup7},
    {input$checkGroup8},
    {input$checkGroup9}))
  genres[genre_ids]
}

get_ratings = function(value_list) {
  dat <- data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                     function(x) ifelse(length(x) > 1, x[[2]], NA)),
                    Rating = unlist(as.character(value_list)))
  
  dat <- dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat <- dat[Rating > 0]
  dat
}

get_user_ratings = function(value_list, ncol) {
  dat <- get_ratings(value_list)
  user_ratings <- sparseMatrix(i = rep(1, nrow(dat)),
                               j = dat$MovieID,
                               x = dat$Rating, 
                               dims = c(1, ncol))
  rownames(user_ratings) <- paste0('u', 0)
  user_ratings
}

check_genres = function(input) {
  if (input$method == 1) {
    if (length(get_user_genres(input)) > 3) {
      reset_user_genres()
    }
  }
}

display_filters = function(input, session) {
  if (input$method == 1) {
    showElement(id='method1')
    hideElement(id='method2')
    showElement(id='step2')
    reset_user_ratings(input, session)
    
    if (length(get_user_genres(input)) > 3) {
      reset_user_genres()
    }
  } else if (input$method == 2) {
    hideElement(id='method1')
    showElement(id='method2')
    showElement(id='step2')
    reset_user_genres()
  } else {
    hideElement(id='method1')
    hideElement(id='method2')
    hideElement(id='step2')
    reset_user_genres()
    reset_user_ratings(input, session)
  }
}

reset_user_genres = function() {
  reset('checkGroup1')
  reset('checkGroup2')
  reset('checkGroup3')
  reset('checkGroup4')
  reset('checkGroup5')
  reset('checkGroup6')
  reset('checkGroup7')
  reset('checkGroup8')
  reset('checkGroup9')
}

reset_user_ratings = function(input, session) {
  value_list <- reactiveValuesToList(input)
  ids <- get_ratings(value_list)$MovieID
  for (id in ids) {
    session$sendInputMessage(paste0('select_', id), list(value=NULL))
  }
  jsCode <- "$('.rating-symbol-foreground').css('width', 0);"
  runjs(jsCode)
}

display_user_results = function(on) {
  if (on) {
    # Hide the Step0 (method selection) & Step1 (method1 & method2)
    useShinyjs()
    jsCode <- "document.querySelectorAll('[data-widget=collapse]')[0].click();"
    runjs(jsCode)
    
    jsCode <- "$('.user-results').css('display', 'inline');"
  } else {
    jsCode <- "$('.user-results').css('display', 'none');"
  }
  runjs(jsCode)
}
