[コンパイル]

・事前にjavacとpythonをapt-getなどでインストールしてください

・以下のようにしてリンクを行います
	
	make SOURCES=(入力アセンブリファイル群) DEST=(出力ファイル名)

・linker.java・linker.classだけ生成したいときは以下のコマンドを使ってください

	make linker.class

・linker.java.tmpl と ../architecture.xml からlinker.java、linker.classを生成しています。
