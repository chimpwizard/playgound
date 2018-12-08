FROM golang as builder

WORKDIR /var/app
ADD ./src .
RUN go build -o main . 
RUN ls -la

FROM scratch
COPY --from=builder /var/app/main /main
CMD ["/main"]