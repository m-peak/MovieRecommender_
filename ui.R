# ============================================================
# UI
# ============================================================
library(shiny)
library(shinydashboard)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

shinyUI(
    dashboardPage(
        skin = 'blue',
        dashboardHeader(title = 'Movie Recommender'),
        
        dashboardSidebar(disable = TRUE),
        
        dashboardBody(includeCSS("css/movies.css"),
            fluidRow(id = 'step1',
                box(width = 12, title = 'Step 1: Select a recommendation method', status = 'info', solidHeader = TRUE, collapsible = TRUE,
                    column(6, selectInput('method', h3('Recommendation Method'), 
                        choices = list(
                            ' ' = 0,
                            'Method 1: Genres' = 1,
                            'Method 2: Collaborative Filtering' = 2),
                        selected = 0)),
                    
                    
                    # show the pulldown list of movie genres to be selected (Systsem I (recommendation based on genres))
                    fluidRow(id = 'method1',
                         box(width = 12, title = 'Choose your favorite movie genres (up to 3)', status = 'primary', solidHeader = TRUE, collapsible = FALSE,
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup1', 
                                        h3(''), 
                                        choices = list(
                                            'Action' = 1,
                                            'Adventure' = 2))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup2', 
                                        h3(''), 
                                        choices = list(
                                            'Animation' = 3,
                                            "Children's" = 4))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup3', 
                                        h3(''), 
                                        choices = list(
                                            'Comedy' = 5,
                                            'Crime' = 6))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup4', 
                                        h3(''), 
                                        choices = list(
                                            'Documentary' = 7,
                                            'Drama' = 8))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup5', 
                                        h3(''), 
                                        choices = list(
                                            'Fantasy' = 9,
                                            'Film-Noir' = 10))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup6', 
                                        h3(''), 
                                        choices = list(
                                            'Horror' = 11,
                                            'Musical' = 12))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup7', 
                                        h3(''), 
                                        choices = list(
                                            'Mystery' = 13,
                                            'Romance' = 14))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup8', 
                                        h3(''), 
                                        choices = list(
                                            'Sci-Fi' = 15,
                                            'Thriller' = 16))),
                             column(2,
                                    checkboxGroupInput(
                                        'checkGroup8', 
                                        h3(''), 
                                        choices = list(
                                            'War' = 17,
                                            'Western' = 18)))
                         )
                    ),
                    # show the movies to be rated (Systsem II (collaborative recommendation))
                    fluidRow(id = 'method2',
                         box(width = 12, title = 'Rate as many movies as possible', status = 'primary', solidHeader = TRUE, collapsible = FALSE,
                             div(class = 'rateitems',
                                 uiOutput('ratings')
                             )
                         )
                    )
                )
            ),

            fluidRow(id = 'step2',
                useShinyjs(),
                box(
                  width = 12, status = 'info', solidHeader = TRUE, collapsible = TRUE,
                  title = 'Step 2: Discover movies you might like',
                  br(),
                  withBusyIndicatorUI(
                      actionButton('btn', 'Click here to get your recommendations', class = 'btn-warning')
                  ),
                  br(),
                  tableOutput('results')
                )
            )
        )
    )
)
