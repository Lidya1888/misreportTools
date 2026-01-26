#' Run misreporting pipeline (EI vs pTEE predictive intervals)
#'
#' Computes predicted TEE (pTEE), applies pregnancy corrections by trimester,
#' converts reported energy intake to MJ, calculates predictive interval bounds,
#' and flags under/over/misreporting.
#'
#' @param data A data frame.
#' @param id_col,visit_col,trimester_col,weight_col,height_col,age_col,elev_col,EI_kcal_col Column names (unquoted).
#' @param ethnicity Character. Currently supports "African" (adds ethnicity coefficient), otherwise no ethnicity term.
#' @param pregnancy Logical. If TRUE, adds trimester corrections for trimester 2 and 3.
#' @param preg_corr_tri2 Numeric. Pregnancy correction (MJ/day) for trimester 2.
#' @param preg_corr_tri3 Numeric. Pregnancy correction (MJ/day) for trimester 3.
#' @param kcal_to_mj Numeric. Conversion factor (default 239).
#' @param pi_lower_mult,pi_lower_int,pi_upper_mult,pi_upper_int PI formula parameters.
#'
#' @return A tibble with pTEE, pTEE_adj, Reported_EI_MJ, PI bounds, and misreporting flags.
#' @export
run_misreport_pipeline <- function(
    data,
    id_col = champs_id_ps,
    visit_col = drvisitcode,
    trimester_col = trimester,
    weight_col = weight_peres,
    height_col = height_peres,
    age_col = matage,
    elev_col = elevation_m,
    EI_kcal_col = total_Energykcal,
    ethnicity = "African",
    pregnancy = TRUE,
    preg_corr_tri2 = 2.53,
    preg_corr_tri3 = 3.53,
    kcal_to_mj = 239,
    pi_lower_mult = 0.7466,
    pi_lower_int  = -1.5405,
    pi_upper_mult = 1.3395,
    pi_upper_int  = 2.7668
) {

  # 1) unique visits + ordered fill for weight/height
  d <- data |>
    dplyr::distinct({{ id_col }}, {{ visit_col }}, {{ trimester_col }}, .keep_all = TRUE) |>
    dplyr::group_by({{ id_col }}) |>
    dplyr::arrange({{ visit_col }}) |>
    tidyr::fill({{ weight_col }}, .direction = "down") |>
    tidyr::fill({{ height_col }}, .direction = "down") |>
    dplyr::ungroup()

  # 2) build model terms
  d <- d |>
    dplyr::mutate(
      ln_BW        = log({{ weight_col }}),
      ln_Elevation = log({{ elev_col }}),
      Age2 = {{ age_col }}^2,
      Age3 = {{ age_col }}^3,
      Height_lnElev = {{ height_col }} * ln_Elevation,
      Age_lnElev    = {{ age_col }} * ln_Elevation,
      Age2_lnElev   = Age2 * ln_Elevation
    )

  # 3) coefficients (exactly from your script)
  const <- -0.21723930921
  coef_lnBW <- 0.41666419569
  coef_Height <- 0.00656496388
  coef_Age <- -0.02054339322
  coef_Age2 <- 0.00033079019
  coef_Age3 <- -0.000001852
  coef_lnElev <- 0.09126350903
  coef_Ethnicity_A <- 0.01939639976
  coef_Height_lnElev <- -0.00067594646
  coef_Age_lnElev <- 0.00201815477
  coef_Age2_lnElev <- -0.00002262281
  coef_sex <- -0.04091711710
  coef_sex_lnElev <- -0.00694699228

  eth_term <- if (tolower(ethnicity) == "african") coef_Ethnicity_A else 0

  # 4) ln_TEE and pTEE
  d <- d |>
    dplyr::mutate(
      ln_TEE =
        const +
        coef_lnBW * ln_BW +
        coef_Height * {{ height_col }} +
        coef_Age * {{ age_col }} +
        coef_Age2 * Age2 +
        coef_Age3 * Age3 +
        coef_lnElev * ln_Elevation +
        coef_sex +
        eth_term +
        coef_Height_lnElev * Height_lnElev +
        coef_Age_lnElev * Age_lnElev +
        coef_Age2_lnElev * Age2_lnElev +
        coef_sex_lnElev * ln_Elevation,
      pTEE = exp(ln_TEE)
    )

  # 5) pregnancy correction (tri2/tri3 only)
  d <- d |>
    dplyr::mutate(
      Pregnancy_correction = if (!isTRUE(pregnancy)) 0 else dplyr::case_when(
        {{ trimester_col }} == 2 ~ preg_corr_tri2,
        {{ trimester_col }} == 3 ~ preg_corr_tri3,
        TRUE ~ 0
      ),
      pTEE_adj = pTEE + Pregnancy_correction
    )

  # 6) EI kcal -> MJ
  d <- d |>
    dplyr::mutate(
      Reported_EI_MJ = {{ EI_kcal_col }} / kcal_to_mj
    )

  # 7) PI bounds + misreporting flags
  d <- d |>
    dplyr::mutate(
      Lower_95_PI = (pTEE_adj * pi_lower_mult) + pi_lower_int,
      Upper_95_PI = (pTEE_adj * pi_upper_mult) + pi_upper_int,
      Underreporting = Reported_EI_MJ < Lower_95_PI,
      Overreporting  = Reported_EI_MJ > Upper_95_PI,
      Misreporting   = Underreporting | Overreporting
    )

  return(d)
}

