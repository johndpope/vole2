# export the Fossil repository to git.

dir=../../vole-git
marks=/tmp/marks

all: directory-check
	mkdir -p ${dir}
	fossil export --git  > /tmp/vex
	cat /tmp/vex \
		| ( cd ${dir} && git init && git fast-import --quiet  )
	-(cd ${dir} && git remote add origin git@github.com:snowflake/vole2.git)

push: directory-check
	cd ${dir} && git push --mirror

# check that we are in the right folder - the master source for fossil
directory-check:
	[ `pwd` = /Users/davidevans/Vienna-source/xxx/mk ]
