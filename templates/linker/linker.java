
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
				System.err.println("usage: java linker [src1] [src2] ... [dst]");
				return;
			}

			System.err.print("<link> ");
			for (int i = 0; i < cnt - 1; i++)
			{
				System.err.print(args[i] + " ");
			}
			System.err.println("=> " + args[cnt - 1]);

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
			
			// 各ソースファイルのヒープサイズを読み込む
			int heapSum = 0;
			int[] heapSizes = new int[args.length - 1];
			Pattern heapSizePat = Pattern.compile("[.]init[_]heap[_]size[ \t]+(\\d+)");

			for (int i = 0; i < cnt - 1; i++)
			{
				String line = srcs[i].readLine();
				Matcher matcher = heapSizePat.matcher(line);
				if (matcher.find())
				{
					heapSizes[i] = Integer.parseInt(matcher.group(1));
					heapSum += heapSizes[i];
				}
				else
				{
					System.err.println("couldn't get heap size");
					return;
				}
			}

			dst.write(".init_heap_size\t" + heapSum + "\n");

			// 各ファイルのヒープ初期化部分を書き込む
			for (int i = 0; i < cnt - 1; i++)
			{
				while (heapSizes[i] > 0)
				{
					String line = srcs[i].readLine();
					if (line == null)
					{
						System.err.println("ヒープサイズとデータの数が一致しません");
						System.err.println("「ヒープサイズ / 32 = データの数」とならなければなりません");
						break;
					}	
					dst.write(line + "\n");
					line = line.trim();
					if (line.startsWith(".long") || line.startsWith(".float") || line.startsWith(".int")) 
					{
						heapSizes[i] -= 32;
					}
				}
			}

			dst.write("\tjmp\tmin_caml_start\n");
			Pattern gotoMainPat = Pattern.compile("jmp[ \t]+min[_]caml[_]start");
			
			// その他の部分を書き込んでファイルを閉じる
			for (int i = 0; i < cnt - 1; i++)
			{
				while (true)
				{
					String line = srcs[i].readLine();
					if (line == null) break;
					if (gotoMainPat.matcher(line).find() == false)
					{
						dst.write(line + "\n");
					}
				}
				srcs[i].close();
			}
			dst.close();
		}
		catch (IOException e)
		{
			System.out.println(e);
		}
	}
}

