#!/usr/bin/env python3

import keras
import tensorflow as tf
import tf2onnx
from tensorflow.keras.datasets import mnist
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.callbacks import ModelCheckpoint
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import MaxPooling2D
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense

print("--- Handles input data ---")

(train_images, train_labels), (test_images, test_labels) = mnist.load_data()

train_images = train_images.reshape((train_images.shape[0], 28, 28, 1))
train_images = train_images.astype('float32') / 255
test_images = test_images.reshape((test_images.shape[0], 28, 28, 1))
test_images = test_images.astype('float32') / 255
train_labels = to_categorical(train_labels)
test_labels = to_categorical(test_labels)

print("--- Design the model ---")
model = Sequential()


print("--- Layer 1 ---")
print("--Conv layer 1 --")
model.add(Conv2D(filters = 6, 
                 kernel_size = 5, 
                 strides = 1, 
                 activation = 'relu', 
                 input_shape = (28,28,1)))

print("-- Pooling Layer 1 --")
model.add(MaxPooling2D(pool_size = 2, strides = 2))

print("--- Layer 2 ---")
print("-- Conv layer 2--")
model.add(Conv2D(filters = 16,
                 kernel_size = 5,
                 strides = 1,
                 activation = 'relu',
                 input_shape = (14,14,6)))

print("-- Pooling layer 2--")
model.add(MaxPooling2D(pool_size = 2, strides = 2))

print("-- Flatten --")
model.add(Flatten())

print("--- Layer 3 ---")
print("-- Fully Connected Layer 3 --")
model.add(Dense(units = 120, activation = 'relu'))

print("--- Layer 4 ---")
print("-- Fully Connected Layer 4 --")
model.add(Dense(units = 84, activation = 'relu'))

print("--- Layer 5 ---")
print("-- Output layer --")

model.add(Dense(units = 10, activation = 'softmax'))
model.summary()

#define lossy optimization function
filepath = "mnist-lenet-weights-{epoch:02d}-{loss:.4f}.hdf5"
checkpoint = ModelCheckpoint(filepath, monitor='loss', verbose=1,
                                 save_best_only=True, mode='min')
callbacks_list = [checkpoint]
model.compile(optimizer='adam', loss='mean_squared_error',
        metrics=['accuracy'])

print("--- Perform the training ---")
model.fit(train_images, train_labels, epochs=5, batch_size=64,
              callbacks=callbacks_list)

print("--- Convert model from keras (h5) to ONNX (onnx) ---")
tf2onnx.convert.from_keras(model, inputs_as_nchw=[model.inputs[0].name],
        output_path = "lenet.onnx")

print("Finished")
