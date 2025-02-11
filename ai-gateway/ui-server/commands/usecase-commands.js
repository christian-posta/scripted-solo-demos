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
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 1')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 01-demo-hidecred.sh --run 0 -y')}`,
  ],
  '02-demo-mngcred': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 2')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 02-demo-mngcred.sh --run 0 -y')}`,
  ],
  '03-demo-ratelimit': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 3')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 03-demo-ratelimit.sh --run 0 -y')}`,
  ],
  '04-demo-model-failover': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 4')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 04-demo-model-failover.sh --run 0 -y')}`,
  ],
  '05-demo-prompt-guard-reject': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 5')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 05-demo-prompt-guard.sh --run 0 -y')}`,
  ],
  '05-demo-prompt-guard-mask': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 5')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 05-demo-prompt-guard.sh --run 0 -y')}`,
  ],  
  '05-demo-prompt-guard-moderation': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 5')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 05-demo-prompt-guard.sh --run 0 -y')}`,
  ],  
  '05-demo-prompt-guard-custom': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 5')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 05-demo-prompt-guard.sh --run 0 -y')}`,
  ],    
  '06-demo-semantic-cache': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 6')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 06-demo-semantic-cache.sh --run 0 -y')}`,
  ],
  '07-demo-rag': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 7')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 07-demo-rag.sh --run 0 -y')}`,
  ],
  '08-traffic-shift': [
    `${path.join(SCRIPTS_ROOT_DIR, './reset-demo.sh --for 8')}`,
    `${path.join(SCRIPTS_ROOT_DIR, './kubectl_finder.py 08-demo-traffic-shift.sh --run 0 -y')}`,
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