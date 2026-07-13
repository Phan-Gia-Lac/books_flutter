// scripts/backfillPinecone.js
const { getComicsList } = require('../services/comic.service')
const { upsertComicData } = require('../services/search-model')

async function backfill() {
    console.log('Fetching all comics from database...');

    // Fetch everything, no pagination limit
    const { comics }  = await getComicsList({
        limit: 100, 
        offset: 0,
    });

    if(comics.length == 0) {
        console.log('Size 0. Please insert data in seeding folder');
        return 0;
    }

    console.log(`Found ${comics.length} comics. Upserting to Pinecone...`);

    // Batch it — don't send thousands at once in one call
    const batchSize = 50;
    for (let i = 0; i < comics.length; i += batchSize) {
        const batch = comics.slice(i, i + batchSize);
        await upsertComicData(batch);
        console.log(`Upserted ${i + batch.length}/${comics.length}`);
    }

    console.log('Backfill complete.');
    process.exit(0);
}

backfill().catch((err) => {
    console.error('Backfill failed:', err);
    process.exit(1);
});