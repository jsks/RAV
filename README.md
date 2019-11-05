## Dependencies

Besides standard coreutils and Make, the following additional software
is required:

- [LaTeX](https://latex-project.org)
- [pandoc](https://pandoc.org)
- [R](https://www.r-project.org/)
- [sqlite](https://sqlite.org)
- [xsv](https://github.com/BurntSushi/xsv)
- [zsh](https://www.zsh.org)

R package dependencies can be found in `Rpkg.csv`.

## Data

Weather data will be downloaded automatically according to the Frost
API as part of the pipeline; however, it requires a registered client
id saved in `./env.list` according to the following format:

```sh
export client_id=<id>
```

Bicycle data will need to be downloaded manually. There's an available
script for all data between 2016 and 2019 that should work at least
until the download links change.

By default, the data will be downloaded in parallel by four separate
sessions of `wget` and saved automatically in `./data/v1/` for 2019
and `./data/legacy/` for 2016-2018 legacy data.

```sh
$ scripts/download.sh
```

## Pipeline

Invoke `make` to run the included model and generate the final
presentation as `slides.pdf`.

```sh
# Assuming 4 available cpu cores
$ make -j4
```
