#!/bin/bash

# 引数チェック
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 input.pdf"
  exit 1
fi

# 入力PDFファイル
input_pdf="$1"

# 中間ディレクトリ
output_dir="/Users/endo/GitHub/processing_DailyNoteConverter/data"
processed_dir="/Users/endo/GitHub/processing_DailyNoteConverter"
final_output_pdf=$(basename "$input_pdf" .pdf)_processed.pdf

# 必要なディレクトリを作成
mkdir -p "$output_dir"

# 1. PDFをページごとに分割して /data に保存
echo "Splitting PDF into pages..."
pdftk "$input_pdf" burst output "$output_dir/page_%04d.pdf"
if [ $? -ne 0 ]; then
  echo "Error: Failed to split PDF."
  exit 1
fi

# 2. 分割されたPDFをPNGに変換
echo "Converting split PDFs to PNG..."
for pdf in "$output_dir"/*.pdf; do
  png="${pdf%.pdf}.png"
  convert -density 300 "$pdf" "$png"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to convert $pdf to PNG."
    exit 1
  fi
done

# 3. Processingを実行
echo "Running Processing..."
processing-java --sketch="$processed_dir" --run
if [ $? -ne 0 ]; then
  echo "Error: Failed to run Processing sketch."
  exit 1
fi

# 4. PNGファイルを連番で収集
echo "Collecting PNG files..."
png_files=$(ls "$processed_dir"/*.png | sort)
if [ -z "$png_files" ]; then
  echo "Error: No PNG files generated."
  exit 1
fi

# 5. PNGをPDFに結合
echo "Combining PNG files into a single PDF..."
convert $png_files "$final_output_pdf"
if [ $? -ne 0 ]; then
  echo "Error: Failed to combine PNG files into a PDF."
  exit 1
fi

# 6. 一時PNGファイルを削除
echo "Cleaning up temporary PNG files..."
rm -f $png_files
if [ $? -ne 0 ]; then
  echo "Error: Failed to delete temporary PNG files."
fi

# 7. /data の一時ファイルを削除
echo "Cleaning up temporary files in /data..."
rm -f "$output_dir"/*.pdf "$output_dir"/*.png
if [ $? -ne 0 ]; then
  echo "Error: Failed to delete temporary files in /data."
fi

# 8. 完了メッセージ
echo "Processing complete! Output PDF: $final_output_pdf"
