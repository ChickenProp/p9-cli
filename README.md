`p9-cli` lets you draw graphs from the command line, building them up piece-by-piece.

It's a command line interface to [plotnine](https://plotnine.readthedocs.io/en/stable/), which is a Python adaptation of [ggplot2](https://ggplot2.tidyverse.org/). It won't let you do anything that you couldn't do with a simple python script. But it might be more convenient than writing one of those.

```
usage: p9 [-h]
          [--dataset DATASET | --input FILE]
          [--csv ARG=VAL [ARG=VAL ...]]
          [--output FILE [ARG=VAL ...]]
          [--geom GEOM [ARG=VAL ...]]
          [--stat STAT [ARG=VAL ...]]
          [--scale SCALE [ARG=VAL ...]]
          [--facet TYPE [ARG=VAL ...]]
          [--theme [NAME] [ARG=VAL ...]]
          [--xlab XLAB] [--ylab YLAB] [--title TITLE]
          [mapping [mapping ...]]

positional arguments:
  mapping

optional arguments:
  -h, --help            show this help message and exit
  --dataset DATASET
  --input FILE, -i FILE
  --csv ARG=VAL [ARG=VAL ...]
  --output FILE [ARG=VAL ...], -o FILE [ARG=VAL ...]
  --geom GEOM [ARG=VAL ...], -g GEOM [ARG=VAL ...]
  --stat STAT [ARG=VAL ...], -s STAT [ARG=VAL ...]
  --scale SCALE [ARG=VAL ...]
  --facet TYPE [ARG=VAL ...], -f TYPE [ARG=VAL ...]
  --theme [NAME] [ARG=VAL ...], -t [NAME] [ARG=VAL ...]
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

There's support, at least on some level, for geoms (`-g`, `--geom`), stats (`-s`, `--stat`), scales (`--scale`), facets (`-f`, `--facet`), themes (`-t`, `--theme`), annotations (`--ann`), labels (`--xlab`, `--ylab`), title (`--title`). You can take input from a file (`-i`), stdin (default), or one of the builtin datasets (`--dataset`).

The general model is that you pass aesthetic mappings in the form `key=value` and add plot elements with the optional arguments. For `--geom`, `--stat`, `--scale` and `--facet`, you specify a name and keyword parameters in the form `key=value`. The name (with `-` replaced with `_`) is looked up in the relevant part of the plotnine API, the keyword parameters are passed to it, and that's added to the plot. So `-g point size=0.2` is the same as adding `geom_point(size=0.2)` if you were writing Python. `--scale x-date` is `scale_x_date()`. `--ann` is similar, except the name and args are passed directly to `plotnine.annotate`.

When parsing keyword parameters, including aesthetic mappings, any `-` in keys are replaced with `_`. Ints are interpreted as ints, floats as floats. `y`, `n`, `-` are interpreted as `True`, `False`, `None`. A leading `:` is dropped and forces string interpretation. You can insert into a dict by appending `.key` to the key, or a list by appending `,`, and then you can leave off the name beforehand in future. So

```
a=3 b=4.5 dict-val.dict-key1=y .dict-key2=:n .dict-key3=- list-val,=foo ,=bar
==> { 'a': 3,
      'b': 4.5,
      'dict_val': {'dict_key1': True, 'dict_key2': 'n', 'dict_key3': None},
      'list_val': ['foo', 'bar']
    }
```

Plotnine has a number of built-in configurable themes, which you can select with `--theme name key=val ...`. You can also override specific parts of the theme by not providing a name, like `--theme key=val ...`.

Here are some things it lacks:

* There's no way to pass a dataset to a specific layer.

* Many theme elements aren't configurable because they're required to be specific `element_*` types that p9-cli can't construct.

* It should be possible to use `..foo..` and (equivalently) `stat(foo)` in your aesthetics. But it looks like those are deprecated features of plotnine. The current way to do these in python would be `y=after_stat('foo')` (instead of `y='..foo..'` or `y='stat(foo)'`), but p9-cli doesn't support that yet.

* This file, plus the file examples.sh, is the full extent of the documentation.

* I haven't put serious thought into how to define the interface.

* It's not on pip or anything, you just have to install it from here. You need to install plotnine, too.

I make no commitment to future development.
