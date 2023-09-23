import { data } from "@ampt/data";
import { SocketConnection, http, task, ws } from "@ampt/sdk";
import cors from "cors";
import express, { NextFunction, Request, Response, Router } from "express";
import { getCounter, updateCounter } from "./counterStorage";

ws.on("connected", async (connection: SocketConnection) => {
  console.log("connected", JSON.stringify(connection.connectionId));
  const { connectionId, meta } = connection;
  const { connectedAt, queryStringParams } = meta;
  await data.set(`connection:${connectionId}`, {
    connectionId,
    connectedAt,
    username: queryStringParams?.name,
  });
});

ws.on("disconnected", async (connection: SocketConnection, reason?: string) => {
  await data.remove(`connection:${connection.connectionId}`);
});

// remove unused connections
const removeOldConnectionsTask = task(
  "removeOldConnections",
  async (_event) => {
    const connections = (await data.get("connection:*")) as unknown as {
      items: { value: { connectionId: string } }[]; // types are not good in ampt data right now, so I have to cheat a little
    };
    connections.items.forEach(async (connection) => {
      const isConnected = await ws.isConnected(connection.value.connectionId);
      if (!isConnected) {
        console.log("removing connection", connection.value.connectionId);
        await data.remove(`connection:${connection.value.connectionId}`);
      }
    });
  }
);
removeOldConnectionsTask.every("15 minutes", { foo: "bar" });

const auth = (req: Request, res: Response, next: NextFunction) => {
  const { headers } = req;

  if (!headers["authorization"]) {
    //TODO: implement auth
    //return res.status(401).send("Unauthorized");
  }

  res.locals = {
    userId: "ElmLand",
  };

  next();
};

const corsOptions = {
  origin: "*",
  methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  allowedHeaders: "Content-Type,Authorization",
};

const app = express();
//app.use("*", auth);
app.options("*", cors(corsOptions));
app.use(express.json());
app.use(cors(corsOptions));
app.use(express.json());

const counter = Router({ mergeParams: true });

app.use("/counter", counter);

counter.get("/:id", async (req: Request, res: Response) => {
  const counterId = req.params.id ?? "global";
  const counter = await getCounter(counterId);

  return res.json({ count: counter });
});

counter.post("/:id", async (req: Request, res: Response) => {
  const props = req.body;
  const counterId = req.params.id ?? "global";

  if (!props) {
    return res.sendStatus(400);
  }

  if (!props.amount) {
    return res.sendStatus(400);
  }

  const counter = await updateCounter(counterId, props.amount);

  return res.json({ count: counter });
});

http.useNodeHandler(app);
