#! /bin/bash

cd "$(dirname "$0")"
P9=../p9

# Stacked bar plot with counts, similar to
# https://plotnine.readthedocs.io/en/stable/tutorials/miscellaneous-show-counts-on-a-stacked-bar-plot.html
# The counts have overlapping labels, which is a shame. position=dodge might
# avoid that but then I'm not sure how to get the effect of position=fill. Also,
# position_dodge would need parameters, in python `position=position_dodge(...)`
# not `position='dodge'`, and p9-cli has no way to do that.

$P9 --dataset=mpg x='factor(cyl)' fill=drv \
    -g bar position=fill \
    -g text mapping.label=..count.. stat=count position=fill \
    -o stacked-bar-plot.png

# Smoothed conditional means, similar to
# https://plotnine.readthedocs.io/en/stable/generated/plotnine.geoms.geom_smooth.html#smoothed-conditional-means
# We adjust the right margin to make more space for the legend. With -o the size
# gets expanded anyway, but it improves the windowed render.

$P9 --dataset mpg x=displ y=hwy color=drv \
    -g point -s smooth method=lm \
    --xlab displacement --ylab 'mpg (highway)' \
    --scale color-discrete name=drive \
    -t subplots-adjust.right=0.85 \
    -o smoothed-conditional-means.png

# Faceting, similar to
# https://www.r-graph-gallery.com/223-faceting-with-ggplot2.html

$P9 --dataset mtcars x=mpg y=wt -f grid facets='cyl ~ gear' -o faceting.png

# Time series. We use grep to select twelve countries (plus the header line)
# from the full dataset, which kind of sucks. It would be nice to use a tool
# like `q` here (https://github.com/harelba/q/) but I don't want to add a
# dependency. Twelve is the largest number of classes supported by a color
# brewer palette.

COUNTRIES='^(iso_code|BEL|CZE|DEU|ESP|FRA|GBR|IRL|NLD|PRT|SWE|USA|OWID_EUN)'
cat owid-covid-data.csv \
    | grep -E "$COUNTRIES" \
    | $P9 x=date y=total_cases_per_million color=location \
          -g line \
          --scale color-brewer type=qual palette=Paired \
          --scale x-date date-breaks='3 months' \
          --csv dtype.date=datetime64 \
          -t subplots-adjust.right=0.8 \
          -o time-series.png

# Change in rank, similar to
# https://plotnine.readthedocs.io/en/stable/generated/plotnine.geoms.geom_segment.html#change-in-rank
# This is pretty awful. The input data isn't in the right shape, and we have no
# way to transform it. (Again, using something like `q` would make our job much
# easier.) We can get ranked data by restricting to a date, but this only puts
# the ranks on the rows with that date. To get two ranks on a row we need to
# play around with indices. This would fail if the original data was improperly
# sorted, and as-is it means we get warnings about removing many rows with
# missing values.
#
# Some notes:
#
# * min= and max= are p9-cli ways to set the lower and upper limits separately.
#   Here we use them together, but `limits,=0.35 ,=2.65` would also have worked.
#
# * The background of this is transparent, because that's what theme_void()
#   sets. p9-cli has no way to override that, since it can't construct the
#   `element_` classes.

cpm () { echo "total_cases_per_million[date==\"$1\"]"; }
M_Y1="$(cpm 2020-09-01).rank()"
M_Y2="pd.Series(list($(cpm 2021-03-15).rank()), index=$(cpm 2020-09-01).index)"

cat owid-covid-data.csv \
    | grep -E "$COUNTRIES" \
    | $P9 -g segment \
             mapping.x=1 .xend=2 .y="$M_Y1" .yend="$M_Y2" .color=location \
          -g text mapping.x=1 .y="$M_Y1" .label=location \
             ha=right nudge-x=-0.05 size=9 \
          -g text mapping.x=2 .y="$M_Y2" .label=location \
             ha=left nudge-x=0.05 size=9 \
          -g point mapping.x=1 .y="$M_Y1" \
          -g point mapping.x=2 .y="$M_Y2" \
          --ann text x=0.8 y=12.5 label='Rank 01-Sep-2020' size=8 \
          --ann text x=2.2 y=12.5 label='Rank 15-Mar-2021' size=8 \
          --scale x-continuous min=0.35 max=2.65 \
          --scale color-brewer type=qual palette=Paired guide=n \
          -t void \
          -t figure_size,=4 ,=6 \
          --title 'Ranked confirmed covid cases per million' \
          --csv dtype.date=datetime64 \
          -o change-in-rank.png
