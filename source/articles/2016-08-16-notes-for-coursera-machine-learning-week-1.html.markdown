---
title: Notes for Coursera Machine Learning, Week 1
date: 2016-08-16 01:48 UTC
tags: machine learning
---

Some time ago, I started [Andrew Ng's Machine Learning course on Coursera](https://www.coursera.org/learn/machine-learning). I loved every bit of it, but I only got halfway through before I started a new job and it ended up falling by the wayside.

Since time is more or less on my side again, I've since started going back through it from week 1 with a couple friends. We've been taking notes as we go, which I'll be polishing up and posting here!

_These notes were written by myself and Rob Hemingray._

## Linear Algebra Review

Matrices and vectors are used almost everywhere throughout machine learning. They are how we represent sets of values in a way that is efficient to compute upon — modern GPUs are designed to calculate this stuff extremely efficiently, so running machine learning algorithms on a graphics card is a great idea!

If you’re more familiar with programming than linear algebra, think of a vector as an array, and a matrix as a two-dimensional array.

Here’s an example:

\\(\begin{bmatrix} 1 & 2 & 3 \end{bmatrix}\\) ← *vector* 

\\(
\begin{bmatrix} 1 & 2 & 3
\\cr
4 & 5 & 6
\end{bmatrix}
\\) ← *matrix* 

Matrices are measured by their number of rows and columns. The matrix above would be a \\(2 \times 3\\) matrix. Likewise, a vector is just a \\(1 \times n\\) matrix (or \\(n \times 1\\) depending on whether you want a row or column vector).

**Addition and Scalar Multiplication**

Vectors and matrices can be added and multiplied with scalars pretty easily. They can be added together if they have the same dimensions.

$$
\begin{bmatrix}
1 \\cr 2 \\cr 3
\end{bmatrix} +
\begin{bmatrix}
4 \\cr 5 \\cr 6
\end{bmatrix} =
\begin{bmatrix}
5 \\cr 7 \\cr 9
\end{bmatrix}
$$

This works with multiplication as well. If you’re multiple a matrix by a scalar, you do it element-wise, taking each element and multiplying it individually. You want to be careful to mention whether you are multiplying element-wise with a matrix, because multiplying a matrix by a vector is a different thing entirely.

**Matrix-Vector Multiplication**

Let’s start with multiplying a matrix with a vector. In order for this to work at all, your matrix needs to have the same number of columns as the vector has rows. You’ll see why in a second.

$$
\begin{bmatrix} 1 & 3 \\cr 4 & 0 \\cr 2 & 1 \end{bmatrix}
\times
\begin{bmatrix} 1 \\cr 5 \end{bmatrix}
= Something
$$ 

So we have our matrix and our vector. The matrix is \\(3 \times 2\\), and the vector is \\(2 \times 1\\). Notice: the matrix’s column count matches up with the vector’s row count. Let’s work through this multiplication and you’ll see why the element totals matter.

For each **row** in this matrix, multiply it element-wise by the vector and sum the result (this is the dot product). For \\(\begin{bmatrix} 1 & 3 \end{bmatrix}\\), the first row, multiply that by \\(\begin{bmatrix} 1 & 5 \end{bmatrix}\\) (the transpose of the vector we’re using) and sum the result. This gives us \\(16\\).

Now, do the same with the second row to get a result of \\(4\\). Finally, the last row gives us \\(7\\). As you go, each row you multiply becomes a new row in a new vector; here’s what ours looks like.

$$\begin{bmatrix} 16 \\cr 4 \\cr 7 \end{bmatrix}$$

So our \\(3 \times 2\\) matrix multiplied by our \\(2 \times 1\\) vector gave us a new \\(3 \times 1\\) vector. This might make sense! Our matrix had three rows, and we are creating a new row for each row we calculate!

**Matrix-Matrix Multiplication**

So matrix-vector multiplication is easy enough. What about multiplying a matrix by *another matrix*? As it happens, this is pretty similar to matrix-vector multiplication, except that you’re effectively multiplying your matrix by \\(n\\) vectors. Perhaps an example would help.

$$
\begin{bmatrix} 1 & 3 & 2 \\cr 4 & 0 & 1 \end{bmatrix}
\times
\begin{bmatrix} 1 & 3 \\cr 0 & 1 \\cr 5 & 2 \end{bmatrix}
$$

Going by our matrix-vector definition of multiplication, if we have a \\(2 \times 3\\) matrix then we want a \\(3 \times 1\\) vector to go with it, right? As long as the matrix columns match the vector rows, we’re in business. That’s still the case here! The only thing is, now we’re dealing with *multiple* \\(3 \times 1\\) vectors.

For the first row in the first column of the new matrix, we have to work out \\((1 \cdot 1 + 3 \cdot 0 + 2 \cdot 5)\\). For the second row of the first column: \\((4 \cdot 1 + 0 \cdot 0 + 1 \cdot 5)\\).

Putting this together, we get \\(\begin{bmatrix} 11 \\cr 9 \end{bmatrix}\\).

Easy! Now you have to do the same with the next vector, \\(\begin{bmatrix} 3 \\cr 1 \\cr 2 \end{bmatrix}\\).

The final result gets us a brand new \\(2 \times 2\\) matrix:

$$\begin{bmatrix} 11 & 10 \\cr 9 & 14 \end{bmatrix}$$

Remember how the previous matrix-vector multiplication gave us a \\(3 \times 1\\) vector? This is the same deal! We started with a \\(2 \times 3\\) matrix and a \\(3 \times 2\\) matrix, and we got a \\(2 \times 2\\) result. The outside integers represent the size of the result, and the inside integers have to be equal.

## Linear Regression with One Variable

For linear regression with one variable, we effectively have a vector of some variables, and then a vector of their expected values. Let’s say we’re trying to predict house prices based on the size of the house in square feet (just one variable).


    house_size = [1000, 1500, 750, 2000, 3500]
    selling_price = [10000, 15000, 7500, 20000, 35000]

This is a very contrived example. The goal here is to find some function that can generalize these values: `f(house size) = selling price` . This function will end up being the equation for the line of best fit for the data. Keep in mind: the line of best fit changes based on the data. Some house prices may be different in one area to those in another, so the whole goal is to find the selling price *based on* the training set of data.

It’s important to note that function we find won’t be perfect in all cases. The idea is to just get as close to matching these values as possible — once we have a function which can do that, we can input any arbitrary `house size` to get a good `selling price` .

To start on this, we need a way to figure out how good our current equation is. Since the equation for a line is \\(y=mx + b\\) *(in this case, \\(y\\) is the selling price and \\(x\\) is the house size)*, we need to find \\(m\\) and \\(b\\) — to do that we have to start with a way to determine the accuracy of our current \\(m\\) and \\(b\\) values.

**Hypothesis Function**

So, we have a vector of training examples, and then a vector of \\(y\\) (target) values. We want the line \\(y=mx + b\\). Here, \\(m\\) is some constant which we use to multiply by our training value to get a line of best fit. \\(m\\) is in a vector called theta, or \\(\theta\\). All theta is is a vector of extra variables which we have to determine ourselves to get it to estimate the output correctly. Ideally, each of our training variables multiplied by its corresponding theta value will result in the corresponding \\(y\\) value.


    training = [1, 2, 3]
    theta = [0.5, 2, 3]
    expected_values = [0.5, 4, 9]

You see in the above case, theta is exactly what we want. Each value multiplied by the corresponding theta value gives exactly the value we expected. However, you usually don’t start with the perfect theta values. You might start with each theta set to 1, for example. From there, we can *train* our linear regression algorithm with the training examples to tune each theta value to be more accurate.

Our equation to guess at the price for a house given a size is called the *hypothesis function*. It takes in our variable \\(x\\) and returns its best guess, \\(y\\). Going back to theta, it can be defined like this:

$$
h(x) = \theta\_0 + \theta\_1 x
$$

So we have our function which sums up the our theta values multiplied by our x value, plus the y-intercept value, represented at \\(\theta_0\\) here.

**Cost Function**

As mentioned, the goal is to get our hypothesis function to match the training examples as closely as possible. We do this by finding some way to choose \\(\theta_0\\) and \\(\theta_1\\) as well as possible. Our \\(h_\theta(x)\\) function should match the target \\(y\\) as closely as possible.  

$$
h_\theta (x) - y \approx 0
$$

This equation works for a single example, but we want to make sure that *all* of our training examples are matched closely. Instead, we want to do something like this:

$$
\sum\limits\_{I=1}^m (h\_\theta(x^{(i)}) - y^{(i)})^2
$$

We’re just taking the sum of the squared difference between each input (\\(m\\) is the number of training examples) and its expected output. Each difference is squared so that there are no negative values — adding a negative value to the sum is obviously going to be a bad time.

What we want to do is find the values for \\(\theta\\) and \\(\theta_1\\) which minimise the sum of the equation above. If we find the perfect values for theta, then the sum will be 0; there will be no difference between any of our hypothesis functions and the actual values.

That equation is called the *cost function*. Instead of having to write out the whole thing each time, we can define it like this:

$$
J(\theta\_0, \theta\_1) = \frac{1}{2m} \sum\limits\_{i=1}^m (h\_\theta(x^{(i)}) - y^{(i)})^2
$$

We’re taking the sum and averaging it, with the \\(\frac{1}{2m}\\). Dividing a number by 2 is the same as multiplying it by the inverse of 2, which is \\(\frac{1}{2}\\). Since we have \\(m\\) examples, the inverse is \\(\frac{1}{m}\\). The fraction is then divided by 2 for reasons I'm not entirely sure of yet.

So we have our cost function. We pass in the values of theta that we have so far (remember, these are arbitrary and we’re changing them to find the best fit) and get back the *cost* of those values. The higher the cost, the worse our hypothesis is. If the cost is 0, then we nailed it.

**Calculating the Hypothesis with Vectors**

So if we have a vector of training variables, and then a vector of theta values, we want to calculate the dot product. However, If we have 3 training variables, then we need 3 theta values, *in addition to* the \\(\theta\_0\\) value. An easy way to get around this is to add an extra element of value \\(1\\) to our training examples. Then, when we calculate the dot product, \\(\theta\_0\\) will be multiplied by \\(1\\).


## Gradient Descent

We now have a way to evaluate our hypothesis function, and see how well it performs using the cost function. This is all well and good, but we need a way to optimize our theta values so that we find the ones which *minimize* our cost function.

The idea of the gradient descent algorithm is this:


1. Start with some guesses for our theta values
2. For each iteration, change our theta values in a way that causes \\(J(\theta\_0, \theta\_1)\\) to be minimized until we end up at a minimum

So we have our two theta values to start with. What we do is we want to look at where we are with these theta values (that is, what our cost function outputs with these theta values) and see if we can make a step somewhere to *reduce* the output of the cost function. If there is a direction we can go to reduce the output, we take that step, and try again. Keep going until you can’t do any better!

Here’s gradient descent, as written by people smarter than I am:

$$
\theta\_j := \theta\_j - \alpha \frac{\partial}{\partial \theta\_j} J(\theta\_0, \theta\_1)
$$

This is basically saying: for each theta value \\(\theta\_j\\), take \\(\theta\_j\\) and subtract the learning rate \\(\alpha\\) multiplied by the partial derivative of the cost function. Because the derivative is the slope of the line tangent to the function, subtracting its value will make sure we are heading in the right direction. If the slope is positive (as in, the point at \\(\theta\_j\\) is increasing), we subtract it to go back and find a value where it is decreasing. Similarly, if the slope is decreasing, we subtract by a negative, which means our value heads in that direction — we want it to get smaller.

Let’s walk through some of these details, starting with the learning rate, \\(\alpha\\). The learning rate does nothing more than control how fast our gradient descent algorithm converges; it’s completely arbitrary. We don’t need to step by just the value of the derivative each time — for large data sets that would take too long. Instead, we can speed things up by multiplying that derivative by some learning rate. You do have to be careful with the learning rate; picking a value which is too small will take a while, whereas a large value might end up skipping right over the minimum values.

You also want to be careful about *how* \\(\theta\_j\\) is updated. In our case we have two theta values, so we want to make sure they are updates *simultaneously*. By that, I mean calculate the new \\(\theta\_j\\) value for each theta variable, and then update them. Don’t update \\(\theta\_0\\) and then \\(\theta\_1\\), because then your calculation for \\(\theta\_1\\) will be using the value for \\(\theta\_0\\) which has already been modified.


----------

**Gradient descent pop quiz!**

Say we have \\(\theta\_0 = 1, \theta\_1 = 2\\). If we update \\(\theta\_j\\) using \\(\theta\_j := \theta\_j + \sqrt{\theta\_0 \theta\_1}\\), what do we get?

Well, for each one we want to calculate its value plus the square root of *both* theta values added. So in each case, we get \\(\theta\_j = \theta\_j + \sqrt{2}\\), since we have \\(1 \cdot 2\\) inside the square root. The thing here is to notice that we are using the original theta values for both calculations, not the post-calculation values.

----------


## Gradient Descent Intuition

When we want to find the derivative of a function, we have to look at see whether or not it takes more than one parameter. If we’re just dealing with one parameter, we take the derivative of that function and call it a day. However, in the case of the cost function, we never have just one parameter — there is always \\(\theta\_0\\) and then any other theta values. This is why we take the partial derivative — we care about the derivative for some \\(\theta\_j\\), and can ignore the other parameters.

One other thing to thing about is what the derivative is when you’re already at the local minimum. When you’re at the lowest point available, the slope of that point is going to be \\(0\\) — one step of gradient descent is going to do nothing, so you’re done!

## Summary

- The hypothesis function takes an input value and returns its best guess for the output. For house prices, it would take the size of a house and give us a price estimate.
- The cost function calculates the difference between the hypothesis and actual values and sums them. The higher than value, the worse our hypothesis is.
- Linear regression is all about figuring out the line of best fit for our data, so that we can make future predictions.



