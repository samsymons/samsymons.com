---

title: "Math Notes: Ray-Plane Intersection"
date: "2017-08-17"
tags: [ "math", "ray tracing", "graphics", "rust" ]

---

As part of working on ray tracing recently, I spent some time brushing up on how to calculate intersections between rays and different types of 3D objects. In preparation for blogging about actually _creating_ a ray tracer, I thought it would be nice to spend some time covering some of the math.

<!--more-->

## Vectors & Rays

Let's quickly cover the tools in our toolbox. All we have to worry about is a mathematical definition for each object, and a _ray_, consisting of a point in 3D space and a direction vector.

First, a refresher on vectors (and subsequently, rays). A vector is nothing more than a line segment in space, with a head and a tail. For example, you could have the 2D vector \\(\vec{v} = (10, 12.5)\\). This vector denotes a point with \\(x\\) coordinate \\(10\\), and \\(y\\) coordinate \\(12.5\\), with the tail at the origin.

A ray is built atop vectors. It is a point in space, with a direction; think of a ray as a [semi-infinite](https://en.wikipedia.org/wiki/Semi-infinite) line. In ray tracing, you might think of a ray as the line-of-sight from your camera, where the origin is the location of your lens and the direction is the way your camera is facing.

Here is the most basic implementation of a vector and ray in Rust:

{{< highlight rust>}}
struct Vector3D {
    x: f32,
    y: f32,
    z: f32,
}

struct Ray {
    origin: Vector3D,
    direction: Vector3D,
}
{{< / highlight >}}

Let's think of the ray's origin as \\(r_0\\), and its direction as \\(\vec{d}\\). We can find any point \\(p\\) along the ray:

$$r_0 + (\vec{d} * t) = p$$

Put more simply, any point along the ray can be found by starting at its origin and add the result of multiplying the direction vector by some real number \\(t\\). In a ray tracer, you would have an operator for vector-float multiplication which returns a point at the calculated location.

## Plane Intersection

Before we get started here, we have to think about _how_ to define a plane in 3D space. We can create a plane with only two pieces of information: its center point in 3D space, and its _normal_. The normal is the direction vector which faces _away_ from an object, so for a plane that is facing directly upwards, the normal would be \\((0, 1, 0)\\).

{{< highlight rust>}}
struct Plane {
    center: Vector3D,
    normal: Vector3D,
}
{{< / highlight >}}

Now our next question: given some point \\(p\\), how can we tell if it exists in the plane? We can use the dot product! It lets us determine if two vectors are orthogonal, so if we have a point on the plane, a vector from the plane's center to that point must be orthogonal to the plane's normal. If the point \\(p\\) exists in the plane, then this equality must hold:

$$
(p - p_0) \cdot n = 0
$$

In the last section, we found a way to get a point along a ray, and now we have a way to tell if a point exists in the plane! Let's combine these two equations and see if we can use these to determine what the value of the point actually _is_.

$$
((r\_0 + \vec{d} * t) - p_0) \cdot n = 0
$$

Now we can work through this algebraically and try to isolate the \\(t\\).

$$
((r\_0 + \vec{d} * t) - p_0) \cdot n = 0
$$

$$
(\vec{d} * t + (r\_0 - p_0)) \cdot n = 0
$$

$$
(\vec{d} * t) \cdot n + (r\_0 - p_0) \cdot n = 0
$$

$$
t * \vec{d} \cdot n = -(r\_0 - p_0) \cdot n
$$

$$
t = -\frac{(r\_0 - p_0) \cdot n}{\vec{d} \cdot n}
$$

$$
t = \frac{(p_0 - r\_0) \cdot n}{\vec{d} \cdot n}
$$

We have to be wary about the denominator here — if the ray's direction and the plane's normal vector are orthogonal (which would happen if the ray is parallel to the plane), then it will equal 0. It's not a big problem, we just know that the ray and plane do not intersect if that dot product is 0, or very close to it.

With the pieces in place, we can write an intersection function:

{{< highlight rust>}}
impl Plane {
    fn intersect(&self, ray: Ray) -> Option<f32> {
        let denominator = dot(self.normal, ray.direction);

        // 0.0001 is an arbitrary epsilon value. We just want
        // to avoid working with intersections that are almost
        // orthogonal.
        if denominator.abs() > 0.0001 {
            let difference = self.center - ray.origin;
            let t = dot(difference, self.normal) / denominator;

            if t > 0.0001 {
                return Some(t);
            }
        }

        return None
    }
}
{{< / highlight >}}

We'd better test this out to make sure it works as advertised.

{{< highlight rust>}}
let plane = Plane { center: Vector3D::new(0.0, 0.0, 0.0), normal: Vector3D::new(0.0, 1.0, 0.0) };

// Test that a ray pointed the wrong way does not intersect. This ray sits
// above the plane and points in the opposite direction.

let missed_ray = Ray { origin: Vector3D::new(0.0, 3.0, 0.0), direction: Vector3D::new(0.0, 1.0, 0.0) };
let miss_result = plane.intersect(&missed_ray);

println!("Miss result: {:?}", miss_result); // Miss result: None

// Test that a ray pointing at the plane will intersect. This ray sits 3
// points above the plane and points directly down — if all goes well, the t value
// will equal 3.

let hitting_ray = Ray { origin: Vector3D::new(0.0, 3.0, 0.0), direction: Vector3D::new(0.0, -1.0, 0.0) };
let hit_result = plane.intersect(&hitting_ray);

println!("Hit result: {:?}", hit_result); // Hit result: Some(3)
{{< / highlight >}}

With that, ray-plane intersection is working. In the next article, we can cover sphere intersections before moving onto triangles and more complex objects.
