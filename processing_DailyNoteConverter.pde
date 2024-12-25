PImage img, result;

void setup() {
  // スケッチサイズ（仮のサイズ）
  size(100, 100);

  // ディレクトリから全てのPNGファイルを取得
  File dataFolder = new File(dataPath(""));
  String[] pngFiles = dataFolder.list((dir, name) -> name.endsWith(".png"));

  if (pngFiles == null || pngFiles.length == 0) {
    println("PNGファイルが見つかりません！");
    exit();
    return;
  }

  println("見つかったPNGファイル:");
  println(pngFiles);

  // 各画像に処理を適用
  for (String fileName : pngFiles) {
    println("処理中: " + fileName);

    // 画像を読み込み
    img = loadImage(fileName);
    if (img == null) {
      println("画像の読み込みに失敗しました: " + fileName);
      continue;
    }

    img.loadPixels();

    // 茶色化処理
    for (int i = 0; i < img.pixels.length; i++) {
      float grayPx = brightness(img.pixels[i]);
      if (grayPx < 50) {
        img.pixels[i] = color(36, 26, 8);
      }
    }

    // アンチエイリアス処理（ガウシアンフィルタ）
    result = createImage(img.width, img.height, RGB);
    result.loadPixels();

    // ガウシアンカーネルのサイズと重み
    int kernelSize = 7; // 奇数が望ましい（3, 5, 7, ...）
    float sigma = 1.0; // ガウス分布の標準偏差
    int halfKernel = kernelSize / 2;

    // ガウシアンカーネルを生成
    float[][] kernel = new float[kernelSize][kernelSize];
    float sum = 0;

    for (int ky = 0; ky < kernelSize; ky++) {
      for (int kx = 0; kx < kernelSize; kx++) {
        float x = kx - halfKernel;
        float y = ky - halfKernel;
        kernel[ky][kx] = exp(-(x * x + y * y) / (2 * sigma * sigma)) / (2 * PI * sigma * sigma);
        sum += kernel[ky][kx];
      }
    }

    // カーネルを正規化（合計が1になるように）
    for (int ky = 0; ky < kernelSize; ky++) {
      for (int kx = 0; kx < kernelSize; kx++) {
        kernel[ky][kx] /= sum;
      }
    }

    // ガウシアンフィルタの適用
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        float r = 0, g = 0, b = 0;

        for (int ky = -halfKernel; ky <= halfKernel; ky++) {
          for (int kx = -halfKernel; kx <= halfKernel; kx++) {
            int nx = x + kx;
            int ny = y + ky;

            if (nx >= 0 && nx < img.width && ny >= 0 && ny < img.height) {
              int index = nx + ny * img.width;
              color c = img.pixels[index];
              float weight = kernel[ky + halfKernel][kx + halfKernel];
              r += red(c) * weight;
              g += green(c) * weight;
              b += blue(c) * weight;
            }
          }
        }

        int index = x + y * img.width;
        result.pixels[index] = color(r, g, b);
      }
    }

    result.updatePixels();

//    // アンチエイリアス処理
//    result = createImage(img.width, img.height, RGB);
//    result.loadPixels();

//    int kernelSize = 4;
//    int halfKernel = kernelSize / 2;

//    for (int y = 0; y < img.height; y++) {
//      for (int x = 0; x < img.width; x++) {
//        float r = 0, g = 0, b = 0;
//        int count = 0;

//        for (int ky = -halfKernel; ky <= halfKernel; ky++) {
//          for (int kx = -halfKernel; kx <= halfKernel; kx++) {
//            int nx = x + kx;
//            int ny = y + ky;

//            if (nx >= 0 && nx < img.width && ny >= 0 && ny < img.height) {
//              int index = nx + ny * img.width;
//              color c = img.pixels[index];
//              r += red(c);
//              g += green(c);
//              b += blue(c);
//              count++;
//            }
//          }
//        }

//        r /= count;
//        g /= count;
//        b /= count;

//        int index = x + y * img.width;
//        result.pixels[index] = color(r, g, b);
//      }
//    }

//    result.updatePixels();

    // 処理済み画像を保存
    String outputFileName = "output_" + fileName;
    result.save(outputFileName);
    println("保存しました: " + outputFileName);
  }

  println("すべての画像の処理が完了しました！");
  exit();
}

void draw() {
  // 描画処理は不要なので空にしておく
}
