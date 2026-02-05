import { Router } from "express";
import { booksRouter } from "./books.js";
import { membersRouter } from "./members.js";
import { borrowsRouter } from "./borrows.js";

export const apiRouter = Router();

apiRouter.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

apiRouter.use("/books", booksRouter);
apiRouter.use("/members", membersRouter);
apiRouter.use("/borrows", borrowsRouter);
