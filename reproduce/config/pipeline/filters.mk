# `filters' are the possible different parts of the survey, for
# example filters in broad or narrow-band astronomical imaging
# datasets. Since a generic term for them (to apply other types of
# surveys/datasets) hasn't been considered yet, we'll stick with the
# `filters' name. But feel free to correct it (or propose a
# suggestion).
#
# If your dataset only has a single filter, or this concept is not
# defined for your type of input dataset, you can ignore this
# variable.
#
# The values can be any string to identify different parts of a survey
# separated by white space characters (for example `f125w f160w' or `J
# H' if you want to specify two filters).
#
# To be clean and also help in readability of the pipeline, it is good
# practice to define a separate `filter-XXXX' variable for each
# survey/dataset, even if they have overlapping filters.
#
# These `filters' are used in the initial downloading of the data and
# it is good practice (for avoiding bugs) to keep the same filter (and
# survey) names in the filenames of the intermediate/output files
# also. This will make sure that the raw input and intermediate/final
# output are exactly related.
filters-survey = a b c d e f g h i
