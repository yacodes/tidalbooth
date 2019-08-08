const chalk = require('chalk');
const osc = require('node-osc');
const throttle = require('lodash.throttle');

const SERVER_PORT = 8765;
const SERVER_HOST = '127.0.0.1';

const CLIENT_PORT = 10000;
const CLIENT_HOST = '192.168.0.100';

const server = new osc.Server(SERVER_PORT, SERVER_HOST);
const client = new osc.Client(CLIENT_HOST, CLIENT_PORT);

const toPairs = values => values.reduce((acc, value, index) => index % 2 === 0 ? [...acc, [value, values[index + 1]]] : acc, [])
const KEYS_TO_FILTER = ['cps', 'delta', 'sec', 'usec'];

const handler = throttle(([path, ...values]) => {
  const {orbit, ...data} = Object.fromEntries(toPairs(values));
  Object.keys(data)
    .filter(key => !KEYS_TO_FILTER.includes(key))
    .forEach(key => key === 'cycle' ? client.send(`/orbit/${orbit}/${key}`, data[key] % 8) : client.send(`/orbit/${orbit}/${key}`, data[key]));
  log(data);
}, 100);

const log = throttle(data => {
  const log = Object.keys(data)
    .filter(key => !['usec', 'delta', 'sec'].includes(key))
    .reduce((acc, key) => `${acc}${chalk.blue(`${key}:`)} ${typeof data[key] === 'number' ? Number.parseFloat(data[key]).toFixed(2) : data[key]} `, '');

  console.log(log);
}, 500);

server.on('message', handler);

console.log(`Listening Tidal on ${SERVER_HOST}:${SERVER_PORT}`);
