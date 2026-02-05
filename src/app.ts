import express, { type Request, type Response, type NextFunction } from "express";
import cors from "cors";
import helmet from "helmet";
import { apiRouter } from "./routes/index.js";

export const createApp = () => {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());

  app.use("/api", apiRouter);

  app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
    // Minimal error handler; expand with logging later.
    res.status(500).json({ message: "Internal server error" });
  });

  return app;
};
