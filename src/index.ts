import express from 'express';
import { AuthorController } from './controllers/AuthorController.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Initialize controllers
const authorController = new AuthorController();

// Register routes
app.use('/api/authors', authorController.router);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Library Management System API',
    version: '1.0.0',
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Library API server running on port ${PORT}`);
});
 