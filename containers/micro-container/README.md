
# Build the smallest docker image

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 12.04.2018
version: draft
```

****

The goal of this POC is to have a a small as possible container blueprint
There are several samples of this on the internet. But wasnted to have one available in my library

The best way to do this is to cerate a binary file and added to a "scratch" image. We will be using GO for this exercise.

The Code

```go
package main

import (
    "fmt"
)

func main() {
    fmt.Println("Hello World!!!")
}
```

The Dockerfile

```dockerfile
FROM golang as builder

WORKDIR /var/app
ADD ./src .
RUN go build -o main . 
RUN ls -la

FROM scratch
COPY --from=builder /var/app/main /main
CMD ["/main"]
```

To build the image just do
```
docker-compose build app
```

To test the image do

```
docker-compose run app
```


## Additioal references while doing this

- https://blog.iron.io/microcontainers-tiny-portable-containers/
- https://blog.codeship.com/building-minimal-docker-containers-for-go-applications/




<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43465642-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-43465642-1');
</script>