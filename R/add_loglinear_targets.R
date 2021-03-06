#' @include internal.R pproto.R ConservationProblem-proto.R loglinear_interpolation.R
NULL

#' Add targets using log-linear scaling
#'
#' Add targets to a conservation planning [problem()] by log-linearly
#' interpolating the targets between thresholds based on the total amount of
#' each feature in the study area (Rodrigues *et al.* 2004). Additionally,
#' caps can be applied to targets to prevent features with massive
#' distributions from being over-represented
#' in solutions (Butchart *et al.* 2015).
#'
#' @param x [problem()] (i.e. [`ConservationProblem-class`]) object.
#'
#' @param lower_bound_amount `numeric` threshold.
#'
#' @param lower_bound_target `numeric` relative target that should be
#'   applied to features with a total amount that is less
#'   than or equal to `lower_bound_amount`.
#'
#' @param upper_bound_amount `numeric` threshold.
#'
#' @param upper_bound_target `numeric` relative target that should be
#'   applied to features with a total amount that is greater
#'   than or equal to `upper_bound_amount`.
#'
#' @param cap_amount `numeric` total amount at which targets should be
#'   capped. Defaults to `NULL` so that targets are not capped.
#'
#' @param cap_target `numeric` amount-based target to apply to features
#'   which have a total amount greater than argument to `cap_amount`.
#'   Defaults to `NULL` so that targets are not capped.
#'
#' @param abundances `numeric` total amount of each feature to
#'  use when calculating the targets. Defaults to the feature abundances in the
#'  study area (calculated using the [feature_abundances()] function.
#'
#' @details Targets are used to specify the minimum amount or proportion of a
#'   feature's distribution that needs to be protected. All conservation
#'   planning problems require adding targets with the exception of the maximum
#'   cover problem (see [add_max_cover_objective()]), which maximizes
#'   all features in the solution and therefore does not require targets.
#'
#'   Seven parameters are used to calculate the targets:
#'   `lower_bound_amount` specifies the first range size threshold,
#'   `lower_bound_target` specifies the relative target required for
#'   species with a range size equal to or less than the first threshold,
#'   `upper_bound_amount` specifies the second range size threshold,
#'   `upper_bound_target` specifies the relative target required for
#'   species with a range size equal to or greater than the second threshold,
#'   `cap_amount` specifies the third range size threshold,
#'   `cap_target` specifies the absolute target that is uniformly applied
#'   to species with a range size larger than that third threshold, and finally
#'   `abundances` specifies the range size for each feature
#'   that should be used when calculating the targets.
#'
#'   The target calculations do not account for the
#'   size of each planning unit. Therefore, the feature data should account for
#'   the size of each planning unit if this is important (e.g. pixel values in
#'   the argument to `features` in the function [problem()] could
#'   correspond to amount of land occupied by the feature in \eqn{km^2} units).
#'   Additionally, the function can only be applied to
#'   [`ConservationProblem-class`] objects that are associated with a
#'   single zone.
#'
#' @section Notes:
#' Early versions (< 5.0.0) used different equations for calculating
#' targets.
#'
#' @inherit add_relative_targets return
#'
#' @seealso [targets], [loglinear_interpolation()].
#'
#' @references
#' Rodrigues ASL, Akcakaya HR, Andelman SJ, Bakarr MI, Boitani L, Brooks TM,
#' Chanson JS, Fishpool LDC, da Fonseca GAB, Gaston KJ, and others (2004)
#' Global gap analysis: priority regions for expanding the global
#' protected-area network. *BioScience*, 54: 1092--1100.
#'
#' Butchart SHM, Clarke M, Smith RJ, Sykes RE, Scharlemann JPW, Harfoot M,
#' Buchanan, GM, Angulo A, Balmford A, Bertzky B, and others (2015) Shortfalls
#' and solutions for meeting national and global conservation area targets.
#' *Conservation Letters*, 8: 329--337.
#'
#' @examples
#' # load data
#' data(sim_pu_raster, sim_features)
#'
#' # create problem using loglinear targets
#' p <- problem(sim_pu_raster, sim_features) %>%
#'      add_min_set_objective() %>%
#'      add_loglinear_targets(10, 0.9, 100, 0.2) %>%
#'      add_binary_decisions()
#' \dontrun{
#' # solve problem
#' s <- solve(p)
#'
#' # plot solution
#' plot(s, main = "solution", axes = FALSE, box = FALSE)
#' }
#' @name add_loglinear_targets
#'
#' @docType methods
NULL

#' @rdname add_loglinear_targets
#' @export
add_loglinear_targets <- function(x, lower_bound_amount, lower_bound_target,
  upper_bound_amount, upper_bound_target, cap_amount = NULL, cap_target = NULL,
  abundances = feature_abundances(x, na.rm = FALSE)$absolute_abundance) {
  # assert that arguments are valid
  assertthat::assert_that(inherits(x, "ConservationProblem"),
                          x$number_of_zones() == 1,
                          isTRUE(all(is.finite(lower_bound_amount))),
                          assertthat::is.scalar(lower_bound_amount),
                          isTRUE(lower_bound_amount >= 0),
                          isTRUE(all(is.finite(upper_bound_amount))),
                          assertthat::is.scalar(upper_bound_amount),
                          isTRUE(upper_bound_amount >= 0),
                          isTRUE(all(is.finite(lower_bound_target))),
                          assertthat::is.scalar(lower_bound_target),
                          isTRUE(lower_bound_target >= 0),
                          isTRUE(lower_bound_target <= 1),
                          isTRUE(all(is.finite(upper_bound_target))),
                          assertthat::is.scalar(upper_bound_target),
                          isTRUE(upper_bound_target >= 0),
                          isTRUE(upper_bound_target <= 1),
                          isTRUE(lower_bound_amount <= upper_bound_amount),
                          is.null(cap_amount) ||
                            assertthat::is.scalar(cap_amount),
                          is.null(cap_target) ||
                            assertthat::is.scalar(cap_target),
                          is.null(cap_amount) == is.null(cap_target),
                          is.numeric(cap_amount) == is.numeric(cap_target),
                          is.numeric(abundances),
                          assertthat::noNA(abundances),
                          isTRUE(min(abundances) >= 0),
                          length(abundances) == x$number_of_features())
  if (is.numeric(cap_amount))
    assertthat::assert_that(is.finite(cap_amount), is.finite(cap_target),
                            isTRUE(cap_amount >= 0), isTRUE(cap_target >= 0))
  # create targets as data.frame
  target_data <- expand.grid(feature = x$feature_names(), type = "absolute")
  # calculate targets as absolute amounts
  target_data$target <- loglinear_interpolation(abundances,
                                                lower_bound_amount,
                                                lower_bound_target,
                                                upper_bound_amount,
                                                upper_bound_target) *
                        abundances
  # apply targets
  if (is.numeric(cap_amount))
    target_data$target[abundances >= cap_amount] <- cap_target
  # add targets to problem
  add_manual_targets(x, target_data)
}
