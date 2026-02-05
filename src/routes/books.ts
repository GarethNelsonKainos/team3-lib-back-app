import { Router } from "express";
import { pool } from "../db/pool.js";

export const booksRouter = Router();

booksRouter.get("/", async (req, res) => {
  const page = Number(req.query.page ?? "1");
  const pageSize = Number(req.query.pageSize ?? "20");

  if (!Number.isInteger(page) || page < 1 || !Number.isInteger(pageSize) || pageSize < 1) {
    res.status(400).json({ message: "Invalid pagination parameters" });
    return;
  }

  const filters: string[] = [];
  const values: Array<string | number> = [];

  const addFilter = (sql: string, value: string | number | undefined) => {
    if (value === undefined || value === "") {
      return;
    }
    values.push(value);
    filters.push(sql.replace("$", `$${values.length}`));
  };

  addFilter("isbn = $", req.query.isbn as string | undefined);

  const publicationYear = req.query.year ? Number(req.query.year) : undefined;
  if (req.query.year && !Number.isInteger(publicationYear)) {
    res.status(400).json({ message: "Invalid year" });
    return;
  }
  if (publicationYear !== undefined) {
    addFilter("publication_year = $", publicationYear);
  }

  const genre = (req.query.genre as string | undefined) ?? "";
  if (genre.trim()) {
    values.push(`%${genre.trim()}%`);
    const index = values.length;
    filters.push(`genre ILIKE $${index}`);
  }

  const q = (req.query.q as string | undefined) ?? "";
  if (q.trim()) {
    values.push(`%${q.trim()}%`);
    const index = values.length;
    filters.push(`(title ILIKE $${index} OR description ILIKE $${index})`);
  }

  const whereClause = filters.length ? `WHERE ${filters.join(" AND ")}` : "";

  const limit = pageSize;
  const offset = (page - 1) * pageSize;

  const countSql = `SELECT COUNT(*) AS total FROM books ${whereClause}`;
  const listSql = `
    SELECT id, title, isbn, genre, publication_year, description, created_at, updated_at
    FROM books
    ${whereClause}
    ORDER BY title ASC
    LIMIT $${values.length + 1}
    OFFSET $${values.length + 2}
  `;

  try {
    const countResult = await pool.query<{ total: string }>(countSql, values);
    const total = Number(countResult.rows[0]?.total ?? 0);

    const listValues = [...values, limit, offset];
    const listResult = await pool.query(listSql, listValues);

    res.json({
      data: listResult.rows,
      meta: {
        page,
        pageSize,
        total
      }
    });
  } catch (error) {
    console.error("Failed to fetch books", error);
    res.status(500).json({ message: "Failed to fetch books" });
  }
});

booksRouter.post("/", (_req, res) => {
  res.status(501).json({ message: "Create book not implemented" });
});
