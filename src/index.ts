import express from 'express';
import { AuthorController } from './controllers/AuthorController.js';
import { BookController } from './controllers/BookController.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Initialize controllers
const authorController = new AuthorController();
const bookController = new BookController();

// Register routes
app.use('/api/authors', authorController.router);
app.use('/api/books', bookController.router);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Library Management System API',
    version: '1.0.0',
    endpoints: {
      authors: '/api/authors',
      books: '/api/books',
      health: '/health'
    }
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`Library API server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
