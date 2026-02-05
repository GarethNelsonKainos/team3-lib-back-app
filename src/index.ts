import { createApp } from "./app.js";
import { loadEnv } from "./config/env.js";

const env = loadEnv();
const app = createApp();

app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on :${env.port}`);
});
