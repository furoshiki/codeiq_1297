#!/usr/bin/perl

#####################################################################
# CodeIQの問題(https://codeiq.jp/ace/furoshiki/q1297)に対して、
# フィードバックコメントを出力するスクリプト
#
# 標準入力：以下のカラムを持つCSV(カンマ区切り形式)
#   1: 識別子
#   2: ユーザID
#   3: 年齢
#   4: タイムスタンプ(形式: 2015年1月25日 11時52分21秒 -> 20150125115221)
#   5: 解答(形式: a,b -> "ab", C -> "c")
# 標準出力：以下のカラムを持つCSV(カンマ区切り)
#   1: フィードバックコメント
#

use strict;

my $CORRECT_ANSWER = "ac"; # 正しい答え
my $DEADLINE = "20150125"; # 出題終了日

my @in = <STDIN>; # パイプされたCSVの入力

######################################################
# 解答順序を年齢(最年少、最年長)を導出する

my $okCount=0; # 正解数
my %timeOrderedNo; # 識別子を添え字として、正解者の解答順序を記録
my $lowestAge = undef; # 正解者の最年少の年齢
my $highestAge = undef; # 正解者の最年長の年齢
my %ansCount; # 解答の種類別の人数 abと答えた人は5名、cと答えた人は10名、など。
{
	# 解答日時でソートしたリストを作る
	my @orderedIn; # ソートしたリスト
	{
		my $dupAvoidCount = 0;
		my %unorderedIn;
		foreach( @in ) {
			my($no,$uid,$age,$time,$ans) = split/,/;
			$time = int(sprintf("%12d%04d",$time,$dupAvoidCount));
			$unorderedIn{$time} = $_;
			$dupAvoidCount++;
		}
		foreach( sort keys %unorderedIn ) {
			push @orderedIn, $unorderedIn{$_};
		}
	}
	foreach( @orderedIn ) {
		chomp;
		my($no,$uid,$age,$time,$ans) = split/,/;
		$ansCount{$ans} = $ansCount{$ans}?$ansCount{$ans}+1:1;
		if( $ans eq $CORRECT_ANSWER ) {
			$timeOrderedNo{$no} = $okCount+1;
			$okCount++;
			if( undef == $lowestAge ) {
				$lowestAge = $age;
				$highestAge = $age;
			}
			if( $age < $lowestAge ) {
				$lowestAge = $age;
			}
			if ( $highestAge < $age ) {
				$highestAge = $age;
			}

		}
	}
}

######################################################
# フィードバックコメントを出力する
foreach( @in ) {

	chomp $_;
	my($no,$uid,$age,$time,$ans) = split/,/,$_;

	# 解答の選択肢をカンマ区切りの文字列に変換する
	my $ansCsv ="";
	for( my $i=0 ; $i<length($ans) ; $i++ ) {
		if( $i ) {
			$ansCsv .= ",";
		}
		$ansCsv .= substr($ans,$i,1);
	}

	# 冒頭の定型文
	print "\"出題者の川田です。問題を解いて頂きありがとうございます。".
	      "時期がだいぶ離れ、問題の内容を覚えていないと思われますので、こちらに転載させて頂きます。\n\n".
	      "2014年にHTML5がW3C勧告となったが、そのスペックに含まれているタグをすべて答えよ。\n".
	      "a. rubyタグ\n".
	      "b. bgsoundタグ\n".
	      "c. legendタグ\n\n";

	# ☆ 解答が正解している場合
	if( $ans eq $CORRECT_ANSWER ) {
		my $order = $timeOrderedNo{$no};
		print "この問題に対して、あなたは【".$ansCsv."】と解答しましたが、『正解』です。おめでとうございます！\n\n".
		      "なお、今回の正解率は".substr(100*$okCount/(scalar @in),0,5)."%で、".
		      "あなたは全体で".$order."番目に正解しています。";

		# 解答の順序で褒める
		if( $order %10 == 0 ) {
			print "いわゆる、キリ番ってやつですね！";
		} elsif( $order == 1 ) {
			print "1番目、どんだけ速いんですか。明らかにトップ、狙ってますよね！";

		} elsif( $order < 10 ) {
			print "一桁台！！なんという速さ！";
		} elsif( $order == 111 || ($order/10)%10 == $order%10 ) {
			print "いわゆる、ゾロ番ってやつですね！！";			
		}

		# 解答の時期で褒める
		if( substr($time,0,8) eq $DEADLINE ) {
			print "HTML5 Conferenceの当日にご登録されたようで、電波が混み合っている中、".
			      "モバイルという劣悪な環境でご解答頂いたようで、本当にありがとうございます。";
		} elsif( int(substr($time,0,8)) < int($DEADLINE) ) {
			print "HTML5 Conference開催前に解いていただいたようで、スタッフをホッとさせて頂きありがとうございます。";			
		}

		# 年齢で褒める
		if( $age == $lowestAge ) {
			print "また、CodeIQには".$age."歳と登録されていましたが、".
			      "今回正解された方の中では最年少でした。素晴らしい、将来有望ですね！";	
		} elsif( $age == $highestAge ) {
			print "また、CodeIQには".$age."歳と登録されていましたが、".
			      "今回正解された方の中では最年長のようです。いつになっても、学び続ける意欲は大切ですね。素晴らしいです。";	
		}

		# 締めの褒め
		print "ここまでキッチリと正解していると「なにをいまさら！」と突っ込まれそうなので、".
		      "解説は省略させて頂きます。一応ですが、";

    # ☆ 解答内容が異常な場合
	} elsif( $ans eq "-" ) {
		print "【Todo】\n\n";

    # ☆ 解答が不正解の場合
	} else {
		print "この問題に対して、あなたは【".$ansCsv."】と解答しましたが、『不正解』です。残念です！\n\n".
		      "正解は【a,c】になります。";

		# 正解している場所でフォローする＆間違っている場所を解説する
		my $ansSum = scalar @in;
		print "あなたと全く同じ解答をした方が、".$ansSum."人中".$ansCount{$ans}."人".
		      "(".sprintf("%02.2f",100*$ansCount{$ans}/$ansSum)."%)ほどいます。";
		if( index($ans,"a") == -1 && index($ans,"b") != -1 && index($ans,"c") == -1 ) {
			print "真逆の解答をしていることから、問題を完全に誤解釈している可能性があります。".
			      "「HTML5の仕様に含まれてないものはどれか」と、勘違いしていませんか。".
			      "今回、複数解答を許可したのですが、見落としてはいませんでしょうか。".
			      "わかりにくい問題となってしまい、申し訳ございません。";
		}
		print "それでは、間違った箇所の解説をさせて頂きます。\n\n";
		if( index($ans,"a") == -1 ) {
			print "aの「rubyタグ」について。エンジニアの方だと、プログラミング言語「Ruby」を思いつく方がいるようですが、".
			       "このrubyは漢字などのフリガナとして使われる「るび」を意味します。どちらも語源は同じですが、".
			       "意味は全く異なります。IEでも古くからサポートされ、ChromeやSafariでもサポートされていますが、".
			       "Firefoxだけはなかなかサポートされません。JSライブラリを使わずにフォールバックができるため手軽です。".
			       "出版業界の組版技術のHTMLフォーマット化においても、重要な役割を担ったタグと言えます。".
			       "日本に限定される仕様なため、標準化には日本人である我々が積極的に関わっていく必要があります。\n\n";
		}
		if( index($ans,"b") != -1 ) {
			print "bの「bgsoundタグ」について。このタグは、IE8までサポートされたIE独自機能です。".
			      "かつて、Webが1.0と呼ばれていた時代、多くのホームページ(「Webサイト」のことです)でMIDIのバックグラウンドサウンドが再生されたのは、".
			      "間違いなくこのタグのポテンシャルが高かったからといえるでしょう。".
			      "過去の遺産のような言い方はしていますが、代替となるaudioタグのサポートはIE9以降になるため、".
			      "8をサポートする場合、未だにフォールバックの用途として活用されることがあったりします。".
			      "HTML5の仕様ではありませんが、まだ現役として扱っている現場もあるはずです。\n\n";
		}
		if( index($ans,"c") == -1 ) {
			print "cの「legendタグ」について。和訳すると「伝説」みたいに見えますが、そんな崇高な意味付けは持っていません。".
			      "fieldsetタグで囲まれた要素の「タイトル」を意味しています。".
			      "ただ、実態としてあまり活用されているように見えません。知らなくても、生きていけるように思えます。".
			      "CSSを全く使わなければ、古いWindowsネイティブアプリを思わせる旧世代的なビジュアルとなるこのタグは、".
			      "UIをしっかり作りこみたい人なんかにはデザインの制約が非常に強く、divタグに逃げられても仕方が無いといった次第です。".
			      "とはいえ、使いくいからなんとかしようぜ(https://www.w3.org/Bugs/Public/show_bug.cgi?id=12834)なんて議論がされており、".
			      "一時は改善に向かうかにみえました…が。アクセシビリティの観点からは、".
			      "二度と「labelタグ」のような緩いマークアップを許すわけにはいかないということで、".
			      "なかなかに辛い状況に置かれているようです。私も個人的に、応援しています。\n\n";
		}
	}

	# 締めにソースを貼っておく
	print "各タグの定義、廃止タグは言及されている箇所のURLを載せておきますので、ご確認下さい。\n\n".
	      "rubyタグ - 4.5.21 The ruby element\n".
	      "  http://www.w3.org/TR/2014/REC-html5-20141028/text-level-semantics.html#the-ruby-element\n".
	      "bgsoundタグ - 11.2 Non-conforming features\n".
	      "  http://www.w3.org/TR/2014/REC-html5-20141028/obsolete.html#non-conforming-features\n".
	      "legendタグ - 4.10.17 The legend element\n".
	      "  http://www.w3.org/TR/2014/REC-html5-20141028/forms.html#the-legend-element\n\n";

	print "宝石の名前やら伝説やら、失われた音やら、スーパーファミコンの「ゼ◯ダの伝説」を思わせる内容と化していますが、".
	      "なんとか収集がつきました。いかがだったでしょうか、楽しんで頂けましたか？\n\n".
	      "ご協力、ありがとうございました！";

	print "\"\n";
}
