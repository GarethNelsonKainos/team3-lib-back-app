import express from 'express';
import { AuthorController } from './controllers/AuthorController.js';
import { BookController } from './controllers/BookController.js';
import { GenreController } from './controllers/GenreController.js';
import { MemberController } from './controllers/MemberController.js';
import { CopyController } from './controllers/CopyController.js';
import { TransactionController } from './controllers/TransactionController.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Initialize controllers
const authorController = new AuthorController();
const bookController = new BookController();
const genreController = new GenreController();
const memberController = new MemberController();
const copyController = new CopyController();
const transactionController = new TransactionController();

// Register routes
app.use('/api/authors', authorController.router);
app.use('/api/books', bookController.router);
app.use('/api/genres', genreController.router);
app.use('/api/members', memberController.router);
app.use('/api/copies', copyController.router); 
app.use('/api/transactions', transactionController.router);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Library Management System API',
    version: '1.0.0',
    endpoints: {
      authors: '/api/authors',
      books: '/api/books',
      genres: '/api/genres',
      members: '/api/members',
      copies: '/api/copies',
      transactions: '/api/transactions',
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
