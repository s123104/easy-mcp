FROM node:22.12-alpine AS builder
WORKDIR /app

# 複製整個 package.json 和 tsconfig.json
COPY package.json package-lock.json tsconfig.json ./

# 安裝所有依賴
RUN npm install

# 複製源代碼
COPY . .

# 構建特定的 workspace 包
RUN npm run build --workspace=@modelcontextprotocol/server-memory

FROM node:22-alpine AS release
WORKDIR /app

# 複製構建產物和配置檔案
COPY --from=builder /app/node_modules/@modelcontextprotocol/server-memory/dist /app/dist
COPY --from=builder /app/node_modules/@modelcontextprotocol/server-memory/package.json /app/package.json

ENV NODE_ENV=production
ENV PORT=8085

RUN npm install --omit=dev --ignore-scripts

ENTRYPOINT ["node", "/app/dist/index.js"]
EXPOSE ${PORT} 