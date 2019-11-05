SHELL = /bin/bash -o pipefail

include env.list

data      := data
processed := $(data)/processed
post      := posterior

v1_raw_files     := $(wildcard $(data)/v1/*.csv.gz)
legacy_raw_files := $(wildcard $(data)/legacy/**/*.csv.zip)
processed_files  := $(v1_raw_files:$(data)/%.csv.gz=$(processed)/%.csv) \
			$(legacy_raw_files:$(data)/%.csv.zip=$(processed)/%.csv)

all: slides.pdf
.PHONY: clean download

clean:
	rm -rf $(processed) \
		$(post) \
		$(data)/{db,weather.rds,dataset.rds} \
		slides.pdf

download:
	@mkdir $(data)
	scripts/download.sh

$(processed)/v1/%.csv: $(data)/v1/%.csv.gz
	@mkdir -p $(@D)
	gunzip -c $< | \
		xsv select started_at | \
		sed -E 's/(:[0-9]+)[.][0-9]+/\1/' > $@

$(processed)/legacy/%.csv: $(data)/legacy//%.csv.zip
	@mkdir -p $(@D)
	unzip -p $< | \
		xsv select 'Start time' | \
		sed -E -e 's/Start time/started_at/' \
			-e 's/[[:space:]]\+([0-9][0-9])([0-9][0-9])/\+\1:\2/' > $@

$(processed)/full_data.csv.gz: $(processed_files)
	xsv cat rows $^ | \
		xsv slice --no-headers -s 1 | \
		gzip > $@

$(data)/db: $(processed)/full_data.csv.gz scripts/import.sh scripts/create.sql
	@rm -f $@ sqlite_pipe
	scripts/import.sh $< $@

$(data)/weather.rds: R/weather.R
	Rscript R/weather.R

$(data)/dataset.rds: R/merge.R $(data)/db $(data)/weather.rds
	Rscript R/merge.R

# There's way more output files than just fit.rds from this script;
# however, to keep this simple track only the main posterior rds
$(post)/fit.rds: R/model.R stan/negbin.stan
	@mkdir -p $(@D)
	Rscript R/model.R

%.pdf: %.Rmd $(post)/fit.rds
	Rscript -e "rmarkdown::render('$<')"
