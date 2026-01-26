#' Misreporting counts and percentages
#'
#' Returns a table with both counts (n) and percentages (%) for
#' underreporting, overreporting, and total misreporting.
#'
#' @param data A data frame containing logical columns
#'   Underreporting, Overreporting, and Misreporting.
#' @param group Optional grouping column (unquoted), e.g. trimester.
#'
#' @return A tibble with counts and percentages.
#' @export
misreport_table <- function(data, group = NULL) {
  g <- rlang::enquo(group)

  # Overall table (no grouping)
  if (rlang::quo_is_null(g)) {
    return(
      dplyr::summarise(
        data,
        Under_n   = sum(Underreporting, na.rm = TRUE),
        Under_pct = mean(Underreporting, na.rm = TRUE) * 100,
        Over_n    = sum(Overreporting, na.rm = TRUE),
        Over_pct  = mean(Overreporting, na.rm = TRUE) * 100,
        Mis_n     = sum(Misreporting, na.rm = TRUE),
        Mis_pct   = mean(Misreporting, na.rm = TRUE) * 100,
        Total     = dplyr::n()
      )
    )
  }

  # Grouped table
  dplyr::summarise(
    dplyr::group_by(data, !!g),
    Under_n   = sum(Underreporting, na.rm = TRUE),
    Under_pct = mean(Underreporting, na.rm = TRUE) * 100,
    Over_n    = sum(Overreporting, na.rm = TRUE),
    Over_pct  = mean(Overreporting, na.rm = TRUE) * 100,
    Mis_n     = sum(Misreporting, na.rm = TRUE),
    Mis_pct   = mean(Misreporting, na.rm = TRUE) * 100,
    Total     = dplyr::n(),
    .groups = "drop"
  )
}
