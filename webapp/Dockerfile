FROM --platform=linux/amd64 node:lts-alpine AS buildapp
ENV NODE_ENV=production
WORKDIR /app
COPY ["package.json", "package-lock.json*", "./"]
RUN npm i --production
COPY . .
RUN npm install -g @nestjs/cli
RUN npm run build


FROM --platform=linux/amd64 node:lts-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY ["package.json", "package-lock.json*", "./"]
RUN npm i --production
COPY --from=buildapp /app/dist ./dist
COPY --from=buildapp /app/views ./views
COPY --from=buildapp /app/public ./public
ARG PORT
EXPOSE $PORT
CMD [ "npm", "run", "start:prod" ]