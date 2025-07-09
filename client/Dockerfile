FROM node:18

WORKDIR /app

# Copy only package files first (for caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# ✅ Install a compatible TypeScript version
RUN npm install --save-dev typescript@4.9.5


# Copy the rest of the app
COPY . .

# Prevent OpenSSL errors
ENV NODE_OPTIONS=--openssl-legacy-provider

# Build React app
RUN npm run build

# Expose port for React dev server or Nginx
EXPOSE 3000

# Start the app (adjust this if you're using a production server like serve or nginx)
CMD ["npm", "start"]

