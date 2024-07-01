
clean:
	rm -rf gen

generate: clean
	docker run -v $(shell pwd):/work --workdir /work bufbuild/buf:1.33.0 generate
