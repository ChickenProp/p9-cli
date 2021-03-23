`p9-cli` lets you draw graphs from the command line, building them up piece-by-piece.

It's a command line interface to [plotnine](https://plotnine.readthedocs.io/en/stable/), which is a Python adaptation of [ggplot2](https://ggplot2.tidyverse.org/). It won't let you do anything that you couldn't do with a simple python script. But it might be more convenient than writing one of those.

```
usage: p9 [-h] [--dataset DATASET | --input INPUT] [--geom GEOM [GEOM ...]]
          [--stat STAT [STAT ...]] [--scale SCALE [SCALE ...]]
          [--facet FACET [FACET ...]] [--xlab XLAB] [--ylab YLAB]
          [--title TITLE]
          [aes [aes ...]]

positional arguments:
  aes

optional arguments:
  -h, --help            show this help message and exit
  --dataset DATASET
  --input INPUT, -i INPUT
  --geom GEOM [GEOM ...], -g GEOM [GEOM ...]
  --stat STAT [STAT ...], -s STAT [STAT ...]
  --scale SCALE [SCALE ...]
  --facet FACET [FACET ...], -f FACET [FACET ...]
  --xlab XLAB
  --ylab YLAB
  --title TITLE
```

For example, you can do

```
# scatter plot (default), with points colored and faceted
python -m plotnine --dataset mpg \
    x=displ y=hwy color=class \
    -f grid facets='drv ~ cyl'

# scatter plot with joined-up dots, plus a smoothed curve
python -m plotnine --dataset economics \
    x=date y='unemploy/pop' \
    -g point size=0.2 \
    -g line \
    -s smooth method=glm
```

There's support, at least on some level, for geoms (`-g`, `--geom`), stats (`-s`, `--stat`), scales (`--scale`), facets (`-f`, `--facet`), labels (`--xlab`, `--ylab`), title (`--title`). You can take input from a file (`-i`), stdin (default), or one of the builtin datasets (`--dataset`).

The general model, right now, is that after `-g`, `-s` and `-f`, you specify a name and keyword parameters in the form `key=value`. The name is looked up in the relevant part of the plotnine API, the keyword parameters are passed to it, and that's added to the grid. So `-g point size=0.2` is the same as adding `geom_point(size=0.2)` if you were writing Python.

For scales it's slightly different, instead of a name you specify the aesthetic and the specific scale in the form `aes=scale`. So `--scale x=date date_breaks='1 year'` gives you `scale_x_date(date_breaks='1 year')`.

Here are some things it lacks:

* For non-builtin datasets, there's no way to configure csv parsing. It's implemented with pandas' `read_csv` function, autodetecting the format, so it will hopefully do the right thing but who knows. A header is required. You can't specify data types or parsing details, if they aren't detected correctly. (Though you can still do, e.g., `x='date_col.astype("datetime64")'`.)
* There's no way to pass an aes or a dataset to a specific layer.
* In general, there's no way to pass parameters other than strings, ints and floats to anything.
* It should be possible to use `..foo..` and (equivalently) `stat(foo)` in your aesthetics. But it looks like those are deprecated features of plotnine. The current way to do these in python would be `y=after_stat('foo')` (instead of `y='..foo..'` or `y='stat(foo)'`), but p9-cli doesn't support that yet.
* There's no support for themes.
* This file is the full extent of the documentation.
* I haven't put serious thought into how to define the interface.
* It's not on pip or anything, you just have to install it from here. You need to install plotnine, too.

I make no commitment to future development.
