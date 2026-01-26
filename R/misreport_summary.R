#' Summarize misreporting percentages
#'
#' Calculates % underreporting, % overreporting, % misreporting, and total N,
#' optionally by a grouping variable.
#'
#' @param data A data frame containing logical columns Underreporting, Overreporting, Misreporting.
#' @param group Optional grouping column (unquoted).
#' @return A tibble with percentages and Total.
#' @export
misreport_summary <- function(data, group = NULL) {
  g <- rlang::enquo(group)

  # Overall summary (no grouping)
  if (rlang::quo_is_null(g)) {
    return(
      dplyr::summarise(
        data,
        Under_pct     = mean(Underreporting, na.rm = TRUE) * 100,
        Over_pct      = mean(Overreporting,  na.rm = TRUE) * 100,
        Misreport_pct = mean(Misreporting,   na.rm = TRUE) * 100,
        Total         = dplyr::n()
      )
    )
  }

  # Grouped summary
  dplyr::summarise(
    dplyr::group_by(data, !!g),
    Under_pct     = mean(Underreporting, na.rm = TRUE) * 100,
    Over_pct      = mean(Overreporting,  na.rm = TRUE) * 100,
    Misreport_pct = mean(Misreporting,   na.rm = TRUE) * 100,
    Total         = dplyr::n(),
    .groups = "drop"
  )
}
