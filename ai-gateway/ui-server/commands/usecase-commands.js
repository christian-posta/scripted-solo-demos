require('dotenv').config();
const { exec } = require('child_process');
const util = require('util');
const path = require('path');
require('dotenv').config();

const execPromise = util.promisify(exec);

// Get scripts root dir from env var, default to 'scripts' directory in project root
const SCRIPTS_ROOT_DIR = process.env.SCRIPTS_ROOT_DIR || path.join(__dirname, '..', 'scripts');

// Define allowed commands for each usecase
const USECASE_COMMANDS = {
  '01-demo-hidecred': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 01-demo-hidecred')}`
  ],
  '02-demo-mngcred': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 02-demo-mngcred')}`
  ],
  '03-demo-ratelimit': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 03-demo-ratelimit')}`
  ],
  '04-demo-model-failover': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 04-demo-model-failover')}`
  ],
  '05-demo-prompt-guard-reject': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 05-demo-prompt-guard-reject')}`
  ],
  '05-demo-prompt-guard-mask': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 05-demo-prompt-guard-mask')}`
  ],
  '05-demo-prompt-guard-moderation': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 05-demo-prompt-guard-moderation')}`
  ],
  '05-demo-prompt-guard-custom': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 05-demo-prompt-guard-custom')}`
  ],
  '06-demo-semantic-cache': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 06-demo-semantic-cache')}`
  ],
  '07-demo-rag': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 07-demo-rag')}`
  ],
  '08-demo-traffic-shift': [
    `${path.join(SCRIPTS_ROOT_DIR, './run-demo.sh 08-demo-traffic-shift')}`
  ]
  // Add more usecases as needed
};

async function executeUsecaseCommands(usecaseId) {
  if (!USECASE_COMMANDS[usecaseId]) {
    throw new Error(`Invalid usecase ID: ${usecaseId}`);
  }

  const results = [];
  for (const command of USECASE_COMMANDS[usecaseId]) {
    try {
      const { stdout, stderr } = await execPromise(command);
      results.push({
        command,
        success: true,
        output: stdout,
        error: stderr
      });
    } catch (error) {
      results.push({
        command,
        success: false,
        error: error.message
      });
      // Depending on your requirements, you might want to break here
      // throw error;
    }
  }
  return results;
}

module.exports = {
  executeUsecaseCommands
}; 