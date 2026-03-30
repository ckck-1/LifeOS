const { OpenAI } = require('openai');

// Pointing to your local GPT4All instance
const openai = new OpenAI({
  baseURL: 'http://localhost:4891/v1',
  apiKey: 'local-no-key-required', // GPT4All doesn't validate this
});

const getAIResponse = async (modelName, systemPrompt, userPrompt) => {
  try {
    const response = await openai.chat.completions.create({
      model: modelName, // e.g., "Reasoner v1" or "Llama 3.2 3B Instruct"
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      temperature: 0.28, // Low temp for structured tasks like strategy generation
    });
    return response.choices[0].message.content;
  } catch (error) {
    console.error(`Error with ${modelName}:`, error);
    throw error;
  }
};


module.exports = { getAIResponse };     