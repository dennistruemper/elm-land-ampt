import { http } from "@ampt/sdk";
import cors from "cors";
import express, { NextFunction, Request, Response, Router } from "express";
import { getCounter, updateCounter } from "./counterStorage";

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
