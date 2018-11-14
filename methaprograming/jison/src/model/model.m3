//Constants
var DEFAULT_MIN = 1;
var DEFAULT_MAX = 100;
var EMAIL_MASK = "([a-z]*@[a-z].[a-z])";

//Enumeratins
enum Status {
  DRAFT,
  INREVIEW,
  PUBLISHED
}

//Types
type Address {
  address1 string;
  address2 string;
  city string;
  state string;
  country string;
}

@Auth(roles="*", action="*", access="restrict")
@Route(path="/books", handler="CRUD")
@Route(path="/authors/:author/books/:book", handler="CRUD")
entity Book is IEntity {
  title string required;
  pages number min(1) max(1000);
  status Status;
}

@Auth(roles="*", action="*", access="restrict")
@Route(path="/authors", handler="CRUD")
entity Author is IEntity {
  
  name string required;
  email string "${EMAIL_MASK}";
  address Address;
}

//@Route(path="/authors/:author/books", handler="CRUD")
relationship OneToMany {
  Author{book(title)} to Book{editor}
}