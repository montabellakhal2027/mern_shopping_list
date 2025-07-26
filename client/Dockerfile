FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

RUN npm install --save-dev typescript@4.9.5


COPY . .

ENV NODE_OPTIONS=--openssl-legacy-provider

RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]

