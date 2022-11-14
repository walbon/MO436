import sys
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import jax.numpy as jnp
import jax.scipy as jsp

M = jnp.array([[1, 3],
               [5, 2]])

assert sp.linalg.det(M) == -13.0



