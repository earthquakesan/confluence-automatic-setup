const {join} = require('path');

const homedir = require('os').homedir();

/**
 * @type {import("puppeteer").Configuration}
 */
module.exports = {
  // Changes the cache location for Puppeteer.
  cacheDirectory: join(homedir, '.cache', 'puppeteer'),
};
