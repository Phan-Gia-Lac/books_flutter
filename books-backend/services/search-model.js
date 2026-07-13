const { Pinecone } = require('@pinecone-database/pinecone');
const dotenv = require('dotenv');

dotenv.config();

const pc = new Pinecone({ apiKey: process.env.PINECONE_API_KEY });

const indexName = 'comic-search';
const MODEL = 'llama-text-embed-v2';

function normalizeText(value, fallback = '') {
    if (value === null || value === undefined) {
        return fallback;
    }

    return String(value);
}

async function createIndex() {
    await pc.createIndexForModel({
        name: indexName,
        cloud: 'aws',
        region: 'us-east-1',
        embed: {
            model: MODEL,
            fieldMap: { text: 'description' },
        },
        waitUntilReady: true,
    });
}

async function upsertComicData(comicData) {
    const index = pc.index(indexName);

    const records = comicData.map((comic) => ({
        id: comic.id.toString(),
        volume: comic.volume,
        price: comic.price,
        title: normalizeText(comic.title),
        description: normalizeText(comic.description),
    }));

    await index.upsertRecords({ records });
}

async function searchComics(queryText) {
    const index = pc.index(indexName);

    const results = await index.searchRecords({
        query: {
            inputs: { text: queryText },
            topK: 50,
        },
        fields: ['title', 'description'],
    });

    return results?.result?.hits ?? [];
}

module.exports = {
    createIndex,
    upsertComicData,
    searchComics,
};