% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/number_of_planning_units.R
\name{number_of_planning_units}
\alias{number_of_planning_units}
\alias{number_of_planning_units,ConservationProblem-method}
\alias{number_of_planning_units,OptimizationProblem-method}
\title{Number of planning units}
\usage{
number_of_planning_units(x)

\S4method{number_of_planning_units}{ConservationProblem}(x)

\S4method{number_of_planning_units}{OptimizationProblem}(x)
}
\arguments{
\item{x}{\code{\link[=problem]{problem()}} (i.e. \code{\linkS4class{ConservationProblem}}),
\code{\linkS4class{OptimizationProblem}}, or \code{\link[=Zones]{Zones()}} object.}
}
\value{
\code{integer} number of planning units.
}
\description{
Extract the number of planning units in an object.
}
\examples{
# load data
data(sim_pu_raster, sim_features)

# create problem
p <- problem(sim_pu_raster, sim_features) \%>\%
     add_min_set_objective() \%>\%
     add_relative_targets(0.2) \%>\%
     add_binary_decisions()

# print number of planning units
print(number_of_planning_units(p))
}
