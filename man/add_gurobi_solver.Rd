% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_gurobi_solver.R
\name{add_gurobi_solver}
\alias{add_gurobi_solver}
\title{Add a \emph{Gurobi} solver}
\usage{
add_gurobi_solver(
  x,
  gap = 0.1,
  time_limit = .Machine$integer.max,
  presolve = 2,
  threads = 1,
  first_feasible = 0,
  numeric_focus = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{x}{\code{\link[=problem]{problem()}} (i.e. \code{\linkS4class{ConservationProblem}}) object.}

\item{gap}{\code{numeric} gap to optimality. This gap is relative when
solving problems using \pkg{gurobi}, and will cause the optimizer to
terminate when the difference between the upper and lower objective
function bounds is less than the gap times the upper bound. For example, a
value of 0.01 will result in the optimizer stopping when the difference
between the bounds is 1 percent of the upper bound.}

\item{time_limit}{\code{numeric} time limit in seconds to run the optimizer.
The solver will return the current best solution when this time limit is
exceeded.}

\item{presolve}{\code{integer} number indicating how intensively the
solver should try to simplify the problem before solving it. Available
options are: (-1) automatically determine the intensity of
pre-solving, (0) disable pre-solving, (1) conservative
level of pre-solving, and (2) very aggressive level of pre-solving .
The default value is 2.}

\item{threads}{\code{integer} number of threads to use for the
optimization algorithm. The default value of 1 will result in only
one thread being used.}

\item{first_feasible}{\code{logical} should the first feasible solution be
be returned? If \code{first_feasible} is set to \code{TRUE}, the solver
will return the first solution it encounters that meets all the
constraints, regardless of solution quality. Note that the first feasible
solution is not an arbitrary solution, rather it is derived from the
relaxed solution, and is therefore often reasonably close to optimality.
Defaults to \code{FALSE}.}

\item{numeric_focus}{\code{logical} should extra attention be paid
to verifying the accuracy of numerical calculations? This may be
useful when dealing problems that may suffer from numerical instability
issues. Beware that it will likely substantially increase run time
(sets the \emph{Gurobi} \code{NumericFocus} parameter
to 3). Defaults to \code{FALSE}.}

\item{verbose}{\code{logical} should information be printed while solving
optimization problems?}
}
\value{
Object (i.e. \code{\linkS4class{ConservationProblem}}) with the solver
added to it.
}
\description{
Specify that the \emph{Gurobi} software should be used to solve a
conservation planning problem. This function can also be used to
customize the behavior of the solver. It requires the \pkg{gurobi} package.
}
\details{
\href{http://gurobi.com}{\emph{Gurobi}} is a
state-of-the-art commercial optimization software with an R package
interface. It is by far the fastest of the solvers available in this
package, however, it is also the only solver that is not freely
available. That said, licenses are available to academics at no cost. The
\pkg{gurobi} package is distributed with the \emph{Gurobi} software suite.
This solver uses the \pkg{gurobi} package to solve problems.
}
\examples{
# load data
data(sim_pu_raster, sim_features)

# create problem
p <- problem(sim_pu_raster, sim_features) \%>\%
  add_min_set_objective() \%>\%
  add_relative_targets(0.1) \%>\%
  add_binary_decisions()
\dontrun{
# if the package is installed then add solver and generate solution
if (require("gurobi")) {
  # specify solver and generate solution
  s <- p \%>\% add_gurobi_solver(gap = 0.1, presolve = 2, time_limit = 5) \%>\%
             solve()

  # plot solutions
  plot(stack(sim_pu_raster, s), main = c("planning units", "solution"),
       axes = FALSE, box = FALSE)
}
}
}
\seealso{
\link{solvers}.
}
