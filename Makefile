all:
	dmd source/gproject.d -O -Ilib/ lib/*.d
install:
	chmod +x ./gproject
	cp ./gproject /usr/local/bin/gproject
