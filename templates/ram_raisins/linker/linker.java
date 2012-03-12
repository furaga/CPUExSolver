import java.util.regex.*;
import java.io.*;

class linker
{
	public static void main(String args[])
	{
		try
		{
			int cnt = args.length;
			if (cnt < 2)
			{
				System.err.println("usage: java linker src1 [src2 src3 ...] dst");
				return;
			}

			System.err.print("<link> ");

			// ソースファイルを開く
			BufferedReader[] srcs = new BufferedReader[cnt - 1];
			for (int i = 0; i < cnt - 1; i++)
			{
				FileInputStream srcStream = new FileInputStream(args[i]);
				srcs[i] = new BufferedReader(new InputStreamReader(srcStream, "UTF-8"));
			}

			// 出力ファイルを開く
			FileOutputStream dstStream = new FileOutputStream(args[cnt - 1]);
			OutputStreamWriter dst = new OutputStreamWriter(dstStream, "UTF-8");

			// メイン関数へジャンプ
			dst.write("\tj\tmin_caml_start\n");
			
			// その他の部分を書き込んでファイルを閉じる
			Pattern gotoMainPat = Pattern.compile("j[ \t]+min[_]caml[_]start");
			for (int i = 0; i < cnt - 1; i++)
			{
				while (true)
				{
					String line = srcs[i].readLine();
					if (line == null) break;
					// メイン関数へのジャンプ「jmp min_caml_start」は無視する
					if (gotoMainPat.matcher(line).find() == false)
					{
						dst.write(line + "\n");
					}
				}
				srcs[i].close();
			}
			dst.close();
	
			for (int i = 0; i < cnt - 1; i++)
			{
				System.err.print(args[i] + " ");
			}
			System.err.println("=> " + args[cnt - 1]);
		}
		catch (IOException e)
		{
			// 例外を検出したらエラー終了する。Makefileが止まる
			System.out.println(e);
			System.exit(1);
		}
	}
}


