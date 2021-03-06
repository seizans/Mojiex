defmodule Mojiex do
  @moduledoc """
  Documentation for Mojiex.
  """

  @doc """
  Japanese strings - Wide/Half "Kana" charactors Conversion Library for Elixir lang

  ## Examples

      iex> Mojiex.convert("ＡＢＣＤ　０１２３４あいうアイウABCD 01234ｱｲｳ",{:hk, :zk})
      "ＡＢＣＤ　０１２３４あいうあいうABCD 01234あいう"            

  """

  @zenhan_list     [
    ze: [start: 0xff01, end: 0xff5e], # 全角英数
    he: [start: 0x0021, end: 0x007e], # 半角英数
    hg: [start: 0x3041, end: 0x3096], # ひらがな
    kk: [start: 0x30a1, end: 0x30f6], # カタカナ
    zs: [{"　"," "}],
    zk: [
        {"。","｡"},    {"「","｢"},    {"」","｣"},    {"、","､"},    {"・","･"},    {"ヲ","ｦ"},
        {"ァ","ｧ"},    {"ィ","ｨ"},    {"ゥ","ｩ"},    {"ェ","ｪ"},    {"ォ","ｫ"},    {"ャ","ｬ"},
        {"ュ","ｭ"},    {"ョ","ｮ"},    {"ッ","ｯ"},    {"ー","ｰ"},    {"ア","ｱ"},    {"イ","ｲ"},
        {"ウ","ｳ"},    {"エ","ｴ"},    {"オ","ｵ"},    {"カ","ｶ"},    {"キ","ｷ"},    {"ク","ｸ"},
        {"ケ","ｹ"},    {"コ","ｺ"},    {"サ","ｻ"},    {"シ","ｼ"},    {"ス","ｽ"},    {"セ","ｾ"},
        {"ソ","ｿ"},    {"タ","ﾀ"},    {"チ","ﾁ"},    {"ツ","ﾂ"},    {"テ","ﾃ"},    {"ト","ﾄ"},
        {"ナ","ﾅ"},    {"ニ","ﾆ"},    {"ヌ","ﾇ"},    {"ネ","ﾈ"},    {"ノ","ﾉ"},    {"ハ","ﾊ"},
        {"ヒ","ﾋ"},    {"フ","ﾌ"},    {"ヘ","ﾍ"},    {"ホ","ﾎ"},    {"マ","ﾏ"},    {"ミ","ﾐ"},
        {"ム","ﾑ"},    {"メ","ﾒ"},    {"モ","ﾓ"},    {"ヤ","ﾔ"},    {"ユ","ﾕ"},    {"ヨ","ﾖ"},
        {"ラ","ﾗ"},    {"リ","ﾘ"},    {"ル","ﾙ"},    {"レ","ﾚ"},    {"ロ","ﾛ"},    {"ワ","ﾜ"},
        {"ン","ﾝ"},    {"゛","ﾞ"},    {"゜","ﾟ"},    {"ヺ","ｦﾞ"},   {"ヴ","ｳﾞ"},   {"ガ","ｶﾞ"},
        {"ギ","ｷﾞ"},   {"グ","ｸﾞ"},   {"ゲ","ｹﾞ"},   {"ゴ","ｺﾞ"},   {"ザ","ｻﾞ"},   {"ジ","ｼﾞ"},
        {"ズ","ｽﾞ"},   {"ゼ","ｾﾞ"},   {"ゾ","ｿﾞ"},   {"ダ","ﾀﾞ"},   {"ヂ","ﾁﾞ"},   {"ヅ","ﾂﾞ"},
        {"デ","ﾃﾞ"},   {"ド","ﾄﾞ"},   {"バ","ﾊﾞ"},   {"パ","ﾊﾟ"},   {"ビ","ﾋﾞ"},   {"ピ","ﾋﾟ"},
        {"ブ","ﾌﾞ"},   {"プ","ﾌﾟ"},   {"ベ","ﾍﾞ"},   {"ペ","ﾍﾟ"},   {"ボ","ﾎﾞ"},   {"ポ","ﾎﾟ"},
        {"ヷ","ﾜﾞ"}
     ]
  ]
  def convert(str, {from, to} ) do
    case {from, to} do
      { :zk, :hk } -> zh_map(&ch_zk_hk/1, str) 
      { :hk, :zk } -> zh_map(&ch_hk_zk/1, str)
      { :hs, :zs } -> zh_map(&ch_hs_zs/1, str)
      { :zs, :hs } -> zh_map(&ch_zs_hs/1, str)
      { :ze, :he } -> conv_range(str, from, to) 
      { :he, :ze } -> conv_range(str, from, to) 
      { :hg, :kk } -> conv_range(str, from, to) 
      { :kk, :hg } -> conv_range(str, from, to) 
      _ -> str
    end
  end
  defp conv_range(str, from_kind, to_kind) do
    dist     = @zenhan_list[from_kind][:start] - @zenhan_list[to_kind][:start]
    start_ch = @zenhan_list[from_kind][:start]
    to_charlist(str)
    |> Enum.map( fn c ->
         if c >= start_ch && c <= @zenhan_list[from_kind][:end] do
           c - dist
         else
           c
         end
       end)
    |> to_string
  end
  defp zh_map( map_fn, str  ) do
    to_charlist(str)
    |> Enum.map( &map_fn.(<<&1::utf8>>) )
    |> to_string
  end
  defp ch_zk_hk(code) do
    List.keyfind(@zenhan_list[:zk], code, 0, {nil, code}) |> elem(1)
  end
  defp ch_hk_zk(code) do
    List.keyfind(@zenhan_list[:zk], code, 1, {code, nil}) |> elem(0)
  end
  def ch_zs_hs(code) do
    List.keyfind(@zenhan_list[:zs], code, 0, {nil, code}) |> elem(1)
  end
  defp ch_hs_zs(code) do
    List.keyfind(@zenhan_list[:zs], code, 1, {code, nil}) |> elem(0)
  end
  def list() do
    @zenhan_list  
  end
  def test() do
    :timer.tc(fn -> Enum.reduce( 0..100_000, 
              fn _,_-> convert( "あいう123オ",{:he, :ze})  |> convert({:hg, :kk}) end)
    end)  
  end
end
