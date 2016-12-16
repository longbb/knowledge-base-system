User.create(
  name: "Expert",
  email: "expert@gmail.com",
  password: "expert123",
  password_confirmation: "expert123",
  status: "active",
  is_expert: "true"
)
Rule.create([
  { before: "cos(x+y)", after: "cos(x)*cos(y) - sin(x)*sin(y)", status: "active" },
  { before: "sin(x+y)", after: "sin(x)*cos(x) - sin(x)*cos(x)", status: "active" },
  { before: "tan(x+y)", after: "[tan(x) + tan(y)] / [1 - tan(x)*tan(y)", status: "active" },
  { before: "sin(2*x)", after: "2*sin(x)*cos(x)", status: "active" },
  { before: "cos(2*x)", after: "cos(x)^2 - sin(x)^2", status: "active" },
  { before: "cos(2*x)", after: "2*cos(x)^2 - 1", status: "active" },
  { before: "cos(2*x)", after: "1 - 2*sin(x)^2", status: "active" },
  { before: "sin(x)^2", after: "[1 - cos(2*x)] / 2", status: "active" },
  { before: "cos(x)^2", after: "[1 + cos(2*x)] / 2", status: "active" },
  { before: "sin(x)*cos(x)", after: "0.5 * sin(2*x)", status: "active" },
  { before: "sin(x)^2", after: "1 - cos(x)^2", status: "active" },
  { before: "cos(x)^2", after: "1 - sin(x)^2", status: "active" }
])
