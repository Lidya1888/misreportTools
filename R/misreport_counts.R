#' Count misreporting classifications
#'
#' Returns counts of underreporting, overreporting, misreporting, and total N,
#' optionally by a grouping variable.
#'
#' @param data A data frame containing logical columns
#'   Underreporting, Overreporting, and Misreporting.
#' @param group Optional grouping column (unquoted), e.g. trimester.
#'
#' @return A tibble with counts.
#' @export
misreport_counts <- function(data, group = NULL) {
  g <- rlang::enquo(group)

  # Overall counts
  if (rlang::quo_is_null(g)) {
    return(
      dplyr::summarise(
        data,
        Under_n = sum(Underreporting, na.rm = TRUE),
        Over_n  = sum(Overreporting,  na.rm = TRUE),
        Mis_n   = sum(Misreporting, na.rm = TRUE),
        Total   = dplyr::n()
      )
    )
  }

  # Grouped counts
  dplyr::summarise(
    dplyr::group_by(data, !!g),
    Under_n = sum(Underreporting, na.rm = TRUE),
    Over_n  = sum(Overreporting,  na.rm = TRUE),
    Mis_n   = sum(Misreporting, na.rm = TRUE),
    Total   = dplyr::n(),
    .groups = "drop"
  )
}

