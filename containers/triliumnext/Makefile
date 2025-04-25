install:
	cd
	git clone -b master https://github.com/triliumnext/notes.git triliumnext
	cd triliumnext
	npm install
	npm rebuild
	npm run build:webpack
	npm run build:ts
	npm run server:start

# TRILIUM_NETWORK_PORT=8080 TRILIUM_DATA_DIR=/path/to/your/data-dir-A /opt/trilium/trilium.sh
