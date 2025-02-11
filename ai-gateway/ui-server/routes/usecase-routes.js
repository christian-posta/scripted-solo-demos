const express = require('express');
const router = express.Router();
const { executeUsecaseCommands } = require('../commands/usecase-commands');

router.post('/configure-usecase', async (req, res) => {
  try {
    const { usecaseId } = req.body;
    
    if (!usecaseId) {
      return res.status(400).json({ error: 'usecaseId is required' });
    }

    const results = await executeUsecaseCommands(usecaseId);
    res.json({ 
      success: true, 
      results 
    });
  } catch (error) {
    console.error('Error configuring usecase:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

module.exports = router; 