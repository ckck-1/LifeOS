const axios = require("axios");

const AI_SERVER = "http://localhost:5001/generate";

async function callLocalModel(prompt) {
  try {
    const { data } = await axios.post(AI_SERVER, { prompt });
    return data.text;
  } catch (error) {
    console.error("AI Server Error:", error.message);
    throw new Error("AI model not responding");
  }
}

async function generateWeeklyPlan(userData) {
  const prompt = `
You are an advanced life strategist AI.

User Goals:
${JSON.stringify(userData.goals, null, 2)}

User Tasks:
${JSON.stringify(userData.tasks, null, 2)}

Create a structured weekly plan.
Return:
- 5 tasks
- Each with title
- description
- suggested ISO date
Respond clearly and briefly.
`;

  return await callLocalModel(prompt);
}

async function generateDailyFocus(userData) {
  const prompt = `
You are a productivity strategist.

User Tasks:
${JSON.stringify(userData.tasks, null, 2)}

Select the most important task for today.
Return:
- Title
- Why it matters
- Suggested time block.
`;

  return await callLocalModel(prompt);
}

async function generateOpportunities(userData) {
  const prompt = `
You are a growth strategist AI.

User Data:
${JSON.stringify(userData, null, 2)}

Suggest:
- 3 actionable opportunities
- Each with explanation
- Full map for each opportunity.
`;

  return await callLocalModel(prompt);
}

module.exports = {
  generateWeeklyPlan,
  generateDailyFocus,
  generateOpportunities,
};