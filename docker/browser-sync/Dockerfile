FROM node:14-alpine

RUN npm install --global browser-sync 
COPY bs-config.js  /workspace/
WORKDIR /workspace
VOLUME ["/workspace/html"]
EXPOSE 3000 3001
CMD ["browser-sync", "start", "--config", "bs-config.js"]

