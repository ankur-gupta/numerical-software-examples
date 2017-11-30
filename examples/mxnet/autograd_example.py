# Examples based on http://gluon.mxnet.io/chapter01_crashcourse/autograd.html

from __future__ import absolute_import
from __future__ import print_function
from __future__ import division
from builtins import range

import mxnet as mx
mx.random.seed(1)

# Define a specific matrix "x" of size 2 x 2
x = mx.nd.array([[1, 2], [3, 4]])
print(type(x))

# Tell the NDArray (the class of x) that we plan to store the gradient.
x.attach_grad()

# Start recording the computation graph.
# We want to define a function of the form f(x) = 2 * x^2.
# Typically, this function takes in a scalar value and returns a scalar value.
# We extend this definition to non-scalars: If x is a tensor of any shape,
# then f(x) is a tensor of the same shape as x. Given a scalar element x[I]
# of the tensor x, the corresponding scalar element of the tensor f(X) is
# f(x)[I]. Note that the index I can have any suitable dimensions.
# x[I] and f(x)[I] are related as follows: f(x)[I] = 2 * x[I]^2.
with mx.autograd.record():
    y = x * 2  # x must be defined before this
    z = y * x  # z = 2 * x^2

# Do backprop
z.backward()

# Note that y and z are tensors of the same shape as x.
# Let's define two derivatives. Note that the definition of these
# derivatives may not match the standard matrix derivative notation.
# dy/dx is a tensor of the same shape as x. (dy/dx)[I] is the scalar element
# of the tensor dy/dx and is defined as: (dy/dx)[I] = d(y[I])/d(x[I]), in which
# y[I] = x[I] * 2. In other words, dy/dx is a tensor containing
# "element-wise" derivatives with no "cross derivatives".
# dz/dx is a tensor of the same shape as x.
# (dz/dx)[I] = d(z[I])/d(x[I]), in which, z[I] = 2 * x[I]^2.
# As a result, (dy/dx)[I] = 2, (dz/dx)[I] = 4 * x[I] for all suitable values
# of I.

# Supposedly, x.grad contains the tensor dz/dx = 4 * x.
print(x.grad)


# # The following is very weird!
# # Define a specific matrix "x" of size 2 x 2
# x = mx.nd.array([[1, 2], [3, 4]])
# print(type(x))
# x.attach_grad()

# with mx.autograd.record():
#     y = x * 2  # x must be defined before this
#     z = y * x  # z = 2 * x^2

# head_gradient = mx.nd.array([[10, 1.], [.1, .01]])
# z.backward(head_gradient)
# print(x.grad)



