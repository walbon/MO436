#include <cblas.h>
#include <string.h>

static void Im2ColNHWC(
    const int channels,
    const int height,
    const int width,
    const int kernel_h,
    const int kernel_w,
    const int dilation_h,
    const int dilation_w,
    const int pad_t,
    const int pad_l,
    const int pad_b,
    const int pad_r,
    const int stride_h,
    const int stride_w,
    const float* data_im,
    float* data_col,
    const int groups,
    const float& zero_point) {
  const int dkernel_h = dilation_h * (kernel_h - 1) + 1;
  const int dkernel_w = dilation_w * (kernel_w - 1) + 1;

  int height_col = (height + pad_t + pad_b - dkernel_h) / stride_h + 1;
  int width_col = (width + pad_l + pad_r - dkernel_w) / stride_w + 1;

  for (int h = 0; h < height_col; ++h) {
    int h_pad = -pad_t + h * stride_h;
    float* data_col_temp =
        data_col + h * width_col * kernel_h * kernel_w * channels;
    int w_pad = -pad_l;
    for (auto w = 0 ; w < width_col ; w++) {
      int r = 0;
      for (int ih = h_pad; ih < h_pad + dkernel_h; ih += dilation_h, ++r) {
        int s = 0;
        for (int iw = w_pad; iw < w_pad + dkernel_w; iw += dilation_w, ++s) {
          if (ih >= 0 && ih < height && iw >= 0 && iw < width) {
            for (auto g = 0 ; g < groups; g++) {
              memcpy(
                  data_col_temp +
                      ((g * kernel_h + r) * kernel_w + s) * (channels / groups),
                  data_im + (ih * width + iw) * channels +
                      g * (channels / groups),
                  sizeof(float) * (channels / groups));
            }
          } else {
            // This should be simply padded with zero.
            for (auto g = 0 ; g < groups ; g++ ) {
              for (int i = 0; i < channels / groups; ++i) {
                data_col_temp
                    [(((g * kernel_h + r) * kernel_w) + s) *
                         (channels / groups) +
                     i] = zero_point;
              }
            }
          }
        } // for each iw
      } // for each ih
      data_col_temp += kernel_h * kernel_w * channels;
      w_pad += stride_w;
    } // for each output pixel
  } // for each image row
}

int main(void){

	return 0;
}

