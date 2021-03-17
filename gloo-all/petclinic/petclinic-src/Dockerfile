FROM golang:1-alpine as build_base

WORKDIR /src

RUN apk add --no-cache git

COPY ./go.mod ./go.sum ./

RUN go mod download

FROM build_base AS builder

COPY . ./

RUN GOOS=linux CGO_ENABLED=0 go build \
    -gcflags "-N -l" \
    -o /app

FROM alpine

COPY --from=builder /app ./

EXPOSE 8080

# Create a group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Perform any further action as an unprivileged user.
USER appuser

CMD ["./app"]
