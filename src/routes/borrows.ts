import { Router } from "express";

export const borrowsRouter = Router();

borrowsRouter.post("/checkout", (_req, res) => {
  res.status(501).json({ message: "Checkout not implemented" });
});

borrowsRouter.post("/checkin", (_req, res) => {
  res.status(501).json({ message: "Checkin not implemented" });
});
