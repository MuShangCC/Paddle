// Copyright (c) 2022 PaddlePaddle Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "paddle/phi/kernels/take_along_axis_grad_kernel.h"

#include "paddle/phi/backends/gpu/gpu_context.h"
#include "paddle/phi/common/place.h"
#include "paddle/phi/core/kernel_registry.h"
#include "paddle/phi/core/utils/data_type.h"
#include "paddle/phi/kernels/funcs/gather_scatter_functor.h"
#include "paddle/phi/kernels/funcs/math_function.h"

namespace phi {

template <typename T, typename Context>
void TakeAlongAxisGradKernel(const Context& dev_ctx,
                             const DenseTensor& x,
                             const DenseTensor& index,
                             const DenseTensor& out_grad,
                             int axis,
                             DenseTensor* x_grad) {
  // We need to know the shape of input matrix to determine the shape of grad
  // matrix of input.
  x_grad->Resize(x.dims());
  dev_ctx.template Alloc<T>(x_grad);

  // Set to zero tensor.
  phi::funcs::SetConstant<Context, T> functor;
  functor(dev_ctx, x_grad, static_cast<T>(0));
  const auto& index_type = index.dtype();

  if (index_type == DataType::INT32) {
    phi::funcs::gpu_scatter_add_kernel<T, int32_t>(
        *x_grad,
        axis,
        index,
        out_grad,
        dev_ctx);  // the gradient of gather is scatter
  } else if (index_type == DataType::INT64) {
    phi::funcs::gpu_scatter_add_kernel<T, int64_t>(
        *x_grad, axis, index, out_grad, dev_ctx);
  } else {
    PADDLE_THROW(
        phi::errors::InvalidArgument("The data type of input index is expected "
                                     "to be int32 or int64, but recieved %s.",
                                     phi::DataTypeToString(index_type)));
  }
}

}  // namespace phi

PD_REGISTER_KERNEL(take_along_axis_grad,
                   GPU,
                   ALL_LAYOUT,
                   phi::TakeAlongAxisGradKernel,
                   float,
                   double,
                   int64_t,
                   int,
                   phi::dtype::float16,
                   phi::dtype::bfloat16) {}
