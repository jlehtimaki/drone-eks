FROM golang:alpine AS builder
ENV GOARCH=amd64 GOOS=linux CGO_ENABLED=0

RUN apk add --no-cache curl unzip

WORKDIR /build
COPY . .

# Fetch Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.3/bin/linux/amd64/kubectl
RUN chmod +x kubectl

# Fetch awscli installation
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip

# Build binary
RUN go build

FROM ubuntu:18.04

# Install AWSCli needed binaries & certs
RUN apt update && apt install -y less ca-certificates

# Copy binaries
COPY --from=builder /build/drone-eks-kubernetes /bin/
COPY --from=builder /build/kubectl /bin/
COPY --from=builder /build/aws .

# Install AWSCli
RUN ./install -b /bin/

ENTRYPOINT ["/bin/drone-eks-kubernetes"]