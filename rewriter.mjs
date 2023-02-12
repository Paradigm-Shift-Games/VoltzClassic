import fs from 'fs/promises'
import path from 'path'

async function discover(rootPath) {
    const stat = await fs.stat(rootPath);

    if (stat.isFile()) {
        return [rootPath];
    }

    if (stat.isDirectory()) {
        const filePaths = await fs.readdir(rootPath);
        
        const subfilePathPromises = filePaths.map(filePath => {
            return discover(`${rootPath}/${filePath}`);
        });

        const subfilePaths = await Promise.all(subfilePathPromises);

        return subfilePaths.flat();
    }
}

function changeExtension(file, extension) {
    const parsed = path.parse(file);
    const newName = `${parsed.dir}/${parsed.name}.${extension}`;
    fs.rename(file, newName)
}

function isLuaSource(file) {
    if (file.endsWith('.lua')) {
        return true;
    }

    if (file.endsWith('.luau')) {
        return true;
    }

    return false;
}

const files = await discover('./Game/src');
const luaSources = files.filter(isLuaSource);

for (const file of luaSources) {
    changeExtension(file, 'luau');
}