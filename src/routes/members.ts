import { Router } from "express";

export const membersRouter = Router();

membersRouter.get("/", (_req, res) => {
  res.status(501).json({ message: "List members not implemented" });
});

membersRouter.post("/", (_req, res) => {
  res.status(501).json({ message: "Create member not implemented" });
});
