'use strict';

const puppeteer = require('puppeteer');

const confluenceBase = "http://localhost:8090/";
const licenseString = `AAABkg0ODAoPeNp1kUFv4jAQhe/+FZH20h5SOUmBBslSWyd0CQnZYmC1Ehc3GsAiMdR2oPTXr0mKa
Cv1lryx3pv3zS9WSyfh0vFDB/f6HdzHdw5lU8fHfoA2cJyD0mIridfFuIfvgsBDdCsNL8yYV0CAK
7N+rfkGNJf3q4qL8qbYVqjYyuWNfST2QIyqAf2pVbHmGiJugJzMXey5AUapKEBqiN92Qh0/DU/zc
1KcWdsfoxioPahhRB6HQejexvOe+xyFMzf8141R2dr/5npNMnqgg6ij2YgVh/LxdjZSs4SlOuJis
MkS87CeVMk+6OqcJn8nT5nZHOh08HYcvb/m+LAgC9LWsltyCtKAaqux+kUXSuzMiVOj2H3tWHJZ/
FCs8RnX1QuofDnTljFxP1RmbE9rveSlhjMe2y4dRiweu6kXegH2ex1k/8hXJVcrLoXm7SKgjZArR
BU0wnfwTdiH/fS4g+acNM+yeEKHD+mZ3Pn+Porg0tIeZlnWYPs5VyccTsvjetF34j0v6yYRXT5bL
P8BalnOJTAsAhQ10TYlHJaDIF3hGMWwR6Y20+UcsgIUfm+/tQZqaY78phdqZ5qzkKTZrk0=X02jf`;

// database is running inside the same network space as the app container
// i.e. localhost will work for connecting between the docker-compose services
const database = {
  "hostname": "postgres",
  "port": "5432",
  "name": "confluence",
  "username": "confluence",
  "password": "confluence",
};

const admin = {
  "username": "admin",
  "fullname": "admin",
  "email": "user@example.com",
  "password": "confluence"
};

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  const navigationPromise = page.waitForNavigation({waitUntil: 'networkidle0'});
  await page.setRequestInterception(true);
  page.on('request', request => {
    if (request.resourceType() === 'image') {
      request.abort();
    } else {
      request.continue();
    }
  });
  await page.goto(confluenceBase);

  await page.screenshot({path: 'screenshots/before.png', fullPage: true});

  const trialInstallationElement = await page.waitForSelector('text/Trial Installation');
  await trialInstallationElement.click();

  const nextButton = await page.waitForSelector('#setup-next-button');
  await nextButton.click();

  const licenseTextArea = await page.waitForSelector('#confLicenseString');
  await licenseTextArea.type(licenseString);

  const nextButtonLicense = await page.waitForSelector('.setup-next-button');
  await nextButtonLicense.click();

  const nextButtonDeploymentType = await page.waitForSelector('#skip-button');
  await nextButtonDeploymentType.click();

  const databaseNextButton = await page.waitForSelector('#setup-next-button');
  await databaseNextButton.click();

  const dbHostnameField = await page.waitForSelector('#dbConfigInfo-hostname');
  await dbHostnameField.type(database.hostname);
  
  const dbPortField = await page.waitForSelector('#dbConfigInfo-port');
  await dbPortField.type(database.port);

  const dbNameField = await page.waitForSelector('#dbConfigInfo-databaseName');
  await dbNameField.type(database.name);

  const dbUsernameField = await page.waitForSelector('#dbConfigInfo-username');
  await dbUsernameField.type(database.username);

  const dbPasswordField = await page.waitForSelector('#dbConfigInfo-password');
  await dbPasswordField.type(database.password);

  const afterDatabaseSettingNextButton = await page.waitForSelector('#setup-next-button');
  await afterDatabaseSettingNextButton.click();

  // need to wait here for 10 more seconds
  // waitForNavigation of removing the timeouts did not help =\
  const timer = ms => new Promise( res => setTimeout(res, ms));
  await timer(15000);
  const exampleSiteButton = await page.waitForSelector('#demoChoiceForm > input');
  await exampleSiteButton.click();

  const manageUsersWithConfluence = await page.waitForSelector('#internal');
  await manageUsersWithConfluence.click();

  const usernameField = await page.waitForSelector('#username');
  //'admin' is default value, no need to type anything here
  //await usernameField.type(admin.username);

  const nameField = await page.waitForSelector('#fullName');
  await nameField.type(admin.fullname);

  const emailField = await page.waitForSelector('#email');
  await emailField.type(admin.email);
  
  const passwordField = await page.waitForSelector('#password');
  await passwordField.type(admin.password);

  const confirmPasswordField = await page.waitForSelector('#confirm');
  await confirmPasswordField.type(admin.password);

  await page.screenshot({path: 'screenshots/admin.png', fullPage: true});

  const createAdminNextButton = await page.waitForSelector('#setup-next-button');
  await createAdminNextButton.click();

  await browser.close();
})();
