const mongoose = require('mongoose');

const connectDB = async () => {
  // Reuse existing connection (important for serverless - connection persists across warm invocations)
  if (mongoose.connection.readyState === 1) {
    return mongoose;
  }

  const isServerless = !!process.env.VERCEL;
  const maxRetries = isServerless ? 2 : 5;
  let retries = 0;

  while (retries < maxRetries) {
    try {
      const conn = await mongoose.connect(process.env.MONGODB_URI, {
        serverSelectionTimeoutMS: isServerless ? 3000 : 5000,
        socketTimeoutMS: isServerless ? 10000 : 45000,
      });

      console.log(`✅ MongoDB connected: ${conn.connection.host}`);

      mongoose.connection.on('error', (err) => {
        console.error('MongoDB connection error:', err.message);
      });

      mongoose.connection.on('disconnected', () => {
        console.warn('MongoDB disconnected. Attempting to reconnect...');
      });

      return conn;
    } catch (error) {
      retries++;
      console.error(
        `❌ MongoDB connection attempt ${retries}/${maxRetries} failed:`,
        error.message
      );

      if (retries >= maxRetries) {
        throw new Error('Max retries reached. Could not connect to MongoDB.');
      }

      const delay = Math.pow(2, retries) * 500;
      console.log(`Retrying in ${delay / 1000}s...`);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
};

module.exports = connectDB;
