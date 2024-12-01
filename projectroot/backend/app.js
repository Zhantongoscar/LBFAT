const express = require("express");
const cors = require("cors");
const deviceRoutes = require("./routes/device.routes");

const app = express();

// 中间件
app.use(cors());
app.use(express.json());

// 路由
app.use("/api/devices", deviceRoutes);

// 错误处理
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Something broke!" });
});

// 启动服务器
const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on port ${PORT}`);
});
