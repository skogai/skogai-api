import { Hono } from "hono";
import { fromHono } from "chanfana";
import { HealthCheck } from "./health";
import { Echo } from "./echo";
import { ErrorDemo } from "./errorDemo";

export const examplesRouter = fromHono(new Hono());

examplesRouter.get("/health", HealthCheck);
examplesRouter.get("/echo/:message", Echo);
examplesRouter.get("/error/:kind", ErrorDemo);
