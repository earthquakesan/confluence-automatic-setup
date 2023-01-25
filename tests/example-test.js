'use strict';

const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setRequestInterception(true);
  page.on('request', request => {
    if (request.resourceType() === 'image') {
      request.abort();
    } else {
      request.continue();
    }
  });
  await page.goto('https://news.ycombinator.com/');
  const element = await page.waitForSelector('a');
  await element.click();
  await page.screenshot({path: 'news.png', fullPage: true});

  await element.dispose();
  await browser.close();
})();
