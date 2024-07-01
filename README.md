# Odigos OpAMP Fork

This opamp protos fork is used to experiment with the OpAMP protocol for the odigos project.

## Odigos OpAMP

Odigos implements OpAMP works like this:
The opamp client is implemented in the various Odigos SDKs, and connect to an opamp server on the odiglet which is a daemonset.

The reasons are:
- The cluster can set up various network policies that might block communication between different nodes.
- Odigos uses devices to inject the instrumentation into the pods, and the mapping of k8s allocated device id is available from the kubelet on the node itself

Due to this architecture, odigos implementation enjoys the following benefits:
- Odigos implements both the client and server, and only guarantees compatibility between the two:
  - There is no need to support arbitrary OpAMP implementations which simplifies the code.
  - We can come up with custom conventions that are honored in the Odigos ecosystem but are not speced in the OpAMP protocol.
- As OpAMP server is a daemonset, there is only one instance which only controls the processes on the node which is roughly the number of instrumented pods:
  - Since the number of pods is at most a few dozen, we can store the state of all the connections in memory.
  - We know that each client will connect to exactly one server, so no need to synchronize the state between multiple server instances.
  - low number of clients means we do not need to worry too much about the performance of the server, as it will not handle an unbounded number of connections.
- Since all the communication is to local host, there is no need for encryption, authentication, and compression.

## Server Implementation

The server currently implements the following features:
- It accepts connections from clients over http only (no websockets).
- The server assumes that the client sends the "DeviceId" allocated by kubelet when the instrumentation device is created. It expects the id over the `X-Odigos-DeviceId` http header, for example: `8497ec75-8928-4e80-90e0-4f29642a0fea`.
- The server maintains a list of all the connected clients and their device ids, and periodically monitors the last heartbeat time to detect disconnected clients.
- When a client sends it's description, the server persists it into the `instrumentationinstance` CRD to record that the agent is up and it's description.
- On the first message from the client, the server responds with resource attributes which should be merged into the agent resource to report useful information about the instrumented service.



## buf.build

To generate clients for the various Odigos SDKs in multiple languages, this fork uses the `buf` build system. To generate the clients, run the following command:

```bash
make generate
```

The client code will be generated inside the `gen` directory.

Temporarily workflow: copy the files directly into the odigos project according to your language. This should be automated in the future.

